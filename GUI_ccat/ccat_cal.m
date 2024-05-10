function FC_image = ccat_cal(ROIPath, TR, TimePoints, InputPath, OutputPath)
% %------------------------------------------------------------------------
% % This is the processing pipline of STN coordinates converting
% %------------------------------------------------------------------------
% % Revised by Yang Qiao and Na Zhao on July 28, 2021
% % E-mail: joe16.psyc@foxmail.com

ccat_mPath = which('ccat');
ccatPath = ccat_mPath(1:end-7);
cd(ccatPath)
load('PipeParameters.mat')
InputParameter.TR = TR;
rawPath = get(InputPath, 'string');
OutDir = get(OutputPath, 'string');

cd(rawPath)

% Remove first 10 time points
mkdir ('FunImgA')
InputParameter.RemoveFirstTimePoints.InDirFunImg = [rawPath filesep 'FunImg'];
InputParameter.RemoveFirstTimePoints.OutDirFunImg = [rawPath filesep 'FunImgA'];
pipeline_kernel('REMOVEFIRSTTIMEPOINTS', InputParameter)

% % Slice timing
% mkdir ('FunImgA')
% InputParameter.SliceTiming.InDirFunImg = [rawPath filesep 'FunImgT'];
% InputParameter.SliceTiming.OutDirFunImg = [rawPath filesep 'FunImgA'];
% InputParameter.SliceTiming.TR = TR;
% InputParameter.SliceTiming.SliceNumber = Slices;
% InputParameter.SliceTiming.SliceOrder = [1:2:Slices 2:2:(Slices-1)];
% InputParameter.SliceTiming.ReferenceSlice = Slices;
% pipeline_kernel('SLICETIMING',InputParameter)

% Realign
mkdir ('FunImgAR')
mkdir ('RealignParameter')
InputParameter.Realign.RealignParameterDir  = [rawPath filesep 'RealignParameter'];
InputParameter.Realign.InDirFunImg = [rawPath filesep 'FunImgA'];
InputParameter.Realign.OutDirFunImg = [rawPath filesep 'FunImgAR'];
pipeline_kernel('REALIGN', InputParameter)

% Fun Coregisterd to T1
Funlist = dir('FunImgAR');
FunName=[rawPath filesep 'FunImgAR' filesep Funlist(3).name];
FunFile=spm_select('FPList',FunName,'^R.*\.nii');
for j=1:(TimePoints-10)
    jnum = num2str(j);
    scans_path = strcat(FunFile,',',jnum);
    scans_allfile{j,1} = scans_path;
end
source=[FunFile,',' num2str(1)];
ref=spm_select('FPList', [rawPath filesep 'T1Img' filesep Funlist(3).name],'^.*\.nii');
matlabbatch{1}.spm.spatial.coreg.estimate.ref = {ref};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {source};
matlabbatch{1}.spm.spatial.coreg.estimate.other =  scans_allfile;
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = ...
    [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
spm_jobman('run',matlabbatch)
clear matlabbatch

% FunCorg_Dir = [rawPath filesep 'FunImgAR'];
% InputParameter.T1CoregisterFun.InDirT1Img
% InputParameter.T1CoregisterFun.InDirRealignParameter
% InputParameter.T1CoregisterFun.OutDirT1CoregisterFun
% pipeline_kernel('T1COREGISTERFUN', InputParameter)

% New segment
mkdir ('T1ImgS')
InputParameter.NewSegment.InDirT1 = [rawPath filesep 'T1Img'];
InputParameter.NewSegment.OutDirT1NewSegment = [rawPath filesep 'T1ImgS'];
InputParameter.NewSegment.Parameter.AffineRegularisation = 'mni';
pipeline_kernel('NEWSEGMENT', InputParameter)

% Normalize
mkdir ('FunImgARW')
mkdir ('ChekNormPic')
InputParameter.Normalize.EPI.InDirFunImg = [rawPath filesep 'FunImgAR'];
InputParameter.Normalize.EPI.OutDirFunImg  = [rawPath filesep 'FunImgARW'];
InputParameter.Normalize.EPI.InDirRealignParameter  = [rawPath filesep 'RealignParameter'];
InputParameter.Normalize.EPI.InFodrChekNormPic = [rawPath filesep 'ChekNormPic'];
pipeline_kernel('NORMALIZEEPI', InputParameter)

% InputParameter.NormalizeNewSeg.InDir_Img = [rawPath filesep 'FunImgAR'];
% InputParameter.NormalizeNewSeg.OutDir_Img = [rawPath filesep 'FunImgARW'];
% InputParameter.NormalizeNewSeg.InDir_NewT1Seg = [rawPath filesep 'T1ImgS'];
% InputParameter.NormalizeNewSeg.outfodr_ChekNorm = [rawPath filesep 'ChekNormPic'];
% pipeline_kernel('NORMALIZENEWSEG', InputParameter)

% Regression
mkdir ('FunImgARWC')
mkdir ('CovParameter')
InputParameter.RegressOutCovariates.InDirFunImg = [rawPath filesep 'FunImgARW'];
InputParameter.RegressOutCovariates.OutDirFunImg = [rawPath filesep 'FunImgARWC'];
InputParameter.RegressOutCovariates.OutDirCov = [rawPath filesep 'CovParameter'];
InputParameter.RegressOutCovariates.InDirRealignParameter = [rawPath filesep 'RealignParameter'];
pipeline_kernel('REGRESSOUTCOVARIATES', InputParameter)

% Filter
mkdir ('FunImgARWCF')
InputParameter.Filter.InDirFunImg = [rawPath filesep 'FunImgARWC'];
InputParameter.Filter.OutDirFunImg = [rawPath filesep 'FunImgARWCF'];
pipeline_kernel('FILTER', InputParameter)

% Smooth
mkdir ('FunImgARWCFS')
InputParameter.Smooth.Gaussian.InDirFunImg = [rawPath filesep 'FunImgARWCF'];
InputParameter.Smooth.Gaussian.OutDirFunImg = [rawPath filesep 'FunImgARWCFS'];
pipeline_kernel('SMOOTH', InputParameter)

%%
% Post-processing

if isequal(ROIPath,ccatPath)
    % Functional Connectivity
    InputParameter.FunctionalConnectivity.InDirFunImg = [rawPath filesep 'FunImgARWCFS'];
    InputParameter.FunctionalConnectivity.OutFodrFC = OutDir;
    InputParameter.FunctionalConnectivity.ROIDef{1, 1} = [ccatPath filesep 'LSTN_MNI_Reslice.nii'];
    InputParameter.FunctionalConnectivity.ROIDef{2, 1} = [ccatPath filesep 'RSTN_MNI_Reslice.nii'];
    pipeline_kernel('FUNCTIONALCONNECTIVITY', InputParameter)
    clear matlabbatch
    
    % ROI converting
    T1SegDir = [rawPath filesep 'T1ImgS'];
    cd(T1SegDir)
    sublist = dir();
    % %==============Write the STN coordinates to original space===============
    LROI = strcat(ccatPath, filesep, 'LSTN_MNI.nii'); % Select the ROI
    def = spm_select('FPList',[T1SegDir filesep sublist(3).name],'^iy_.*\.nii');
    matlabbatch{1}.spm.spatial.normalise.write.subj.def ={def} ;
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {LROI};
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -90 -108
        90 126 72];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'rev_';
    spm_jobman('run',matlabbatch)
    clear matlabbatch
    movefile([ccatPath filesep 'rev*.nii'], OutDir)
    % %==============Write the STN coordinates to original space===============
    RROI = strcat(ccatPath, filesep, 'RSTN_MNI.nii'); % Select the ROI
    def = spm_select('FPList',[T1SegDir filesep sublist(3).name],'^iy_.*\.nii');
    matlabbatch{1}.spm.spatial.normalise.write.subj.def ={def} ;
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {RROI};
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -90 -108
        90 126 72];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'rev_';
    spm_jobman('run',matlabbatch)
    clear matlabbatch
    movefile([ccatPath filesep 'rev*.nii'], OutDir)
    
    % %=====================Save the STN coordinates ==========================
    cd(OutDir)
    [LROI_orig, Header_LROI] = rp_ReadNiftiImage('rev_LSTN_MNI.nii');
    LROI_Coor = find(LROI_orig~=0);
    [i,j,k] = ind2sub(size(LROI_orig),LROI_Coor);
    SumImg1 = sum(LROI_orig(LROI_Coor(:)));
    wei_FC1 = LROI_orig(LROI_Coor);
    x1 = i(1:length(LROI_Coor))';
    x1 = round(sum(wei_FC1.*x1')/SumImg1);
    y1 = j(1:length(LROI_Coor))';
    y1 = round(sum(wei_FC1.*y1')/SumImg1);
    z1 = k(1:length(LROI_Coor))';
    z1 = round(sum(wei_FC1.*z1')/SumImg1);
    COG1 = [x1,y1,z1];
    
    TransMat = Header_LROI.mat;
    MNI_Coor = round(TransMat*[x1;y1;z1;1]);
    x = MNI_Coor(1,1);
    y = MNI_Coor(2,1);
    z = MNI_Coor(3,1);
    LOrig_Coord = [i,j,k];
    LMNI = [x,y,z];
    dlmwrite([OutDir '\rev_LROI_Coordinate.txt'], LMNI);
    clear i j k x y z TransMat MNI_Coor
    
    [RROI_orig, Header_RROI] = rp_ReadNiftiImage('rev_RSTN_MNI.nii');
    RROI_Coor = find(RROI_orig~=0);
    [i,j,k] = ind2sub(size(RROI_orig),RROI_Coor);
    SumImg2 = sum(RROI_orig(RROI_Coor(:)));
    wei_FC2 = RROI_orig(RROI_Coor);
    x2 = i(1:length(RROI_Coor))';
    x2 = round(sum(wei_FC2.*x2')/SumImg2);
    y2 = j(1:length(RROI_Coor))';
    y2 = round(sum(wei_FC2.*y2')/SumImg2);
    z2 = k(1:length(RROI_Coor))';
    z2 = round(sum(wei_FC2.*z2')/SumImg2);
    COG2 = [x2,y2,z2];
    
    TransMat = Header_RROI.mat;
    MNI_Coor = round(TransMat*[x2;y2;z2;1]);
    x = MNI_Coor(1,1);
    y = MNI_Coor(2,1);
    z = MNI_Coor(3,1);
    ROrig_Coord = [i,j,k];
    RMNI = [x,y,z];
    dlmwrite([OutDir '\rev_RROI_Coordinate.txt'], RMNI);
    clear i j k x y z TransMat MNI_Coor
    
    % FC map converting
    OrigFCmap_L = strcat(OutDir,['\ROI1FC_', sublist(3).name, '.nii']); % Select the FC map
    def = spm_select('FPList',[T1SegDir filesep sublist(3).name],'^iy_.*\.nii');
    matlabbatch{1}.spm.spatial.normalise.write.subj.def ={def} ;
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {OrigFCmap_L};
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -90 -108
        90 126 72];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'rev_L';
    spm_jobman('run',matlabbatch)
    clear matlabbatch
    
    OrigFCmap_R = strcat(OutDir, ['\ROI2FC_', sublist(3).name, '.nii']); % Select the FC map
    def = spm_select('FPList',[T1SegDir filesep sublist(3).name],'^iy_.*\.nii');
    matlabbatch{1}.spm.spatial.normalise.write.subj.def ={def} ;
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {OrigFCmap_R};
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -90 -108
        90 126 72];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'rev_R';
    spm_jobman('run',matlabbatch)
    clear matlabbatch
    
    fprintf('\n Converting Finished!! \n')
    
    
else
    % Functional Connectivity
    cd(ROIPath)
    ROI_defined = dir('*.nii');
    InputParameter.FunctionalConnectivity.InDirFunImg = [rawPath filesep 'FunImgARWCFS'];
    InputParameter.FunctionalConnectivity.OutFodrFC = OutDir;
    for rois = 1:length(ROI_defined)
        InputParameter.FunctionalConnectivity.ROIDef{rois, 1} = [ROIPath filesep ROI_defined(rois).name];
    end
    pipeline_kernel('FUNCTIONALCONNECTIVITY', InputParameter)
    clear matlabbatch
    
    % ROI converting
    T1SegDir = [rawPath filesep 'T1ImgS'];
    cd(T1SegDir)
    sublist = dir();
    % %==============Write the coordinates to original space===============
    for i = 1:rois
        ROI = strcat(ROIPath, filesep, ROI_defined(i).name); % Select the ROI
        def = spm_select('FPList',[T1SegDir filesep sublist(3).name],'^iy_.*\.nii');
        matlabbatch{1}.spm.spatial.normalise.write.subj.def ={def} ;
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {ROI};
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -90 -108
            90 126 72];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'rev_';
        spm_jobman('run',matlabbatch)
        clear matlabbatch
        movefile([ROIPath filesep 'rev*.nii'], OutDir)
    end
    
    % FC map converting
    if rois == 1
        OrigFCmap = strcat(OutDir,['\FC_', sublist(3).name, '.nii']); % Select the FC map
        def = spm_select('FPList',[T1SegDir filesep sublist(3).name],'^iy_.*\.nii');
        matlabbatch{1}.spm.spatial.normalise.write.subj.def ={def} ;
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {OrigFCmap};
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -90 -108
            90 126 72];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'rev_';
        spm_jobman('run',matlabbatch)
        clear matlabbatch
    else
        for i = 1:rois
            OrigFCmap = strcat(OutDir,['\ROI', num2str(i), 'FC_', sublist(3).name, '.nii']); % Select the FC map
            def = spm_select('FPList',[T1SegDir filesep sublist(3).name],'^iy_.*\.nii');
            matlabbatch{1}.spm.spatial.normalise.write.subj.def ={def} ;
            matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {OrigFCmap};
            matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -90 -108
                90 126 72];
            matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
            matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
            matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'rev_';
            spm_jobman('run',matlabbatch)
            clear matlabbatch
        end
    end
    
    fprintf('\n Converting Finished!! \n')
    
end

end




