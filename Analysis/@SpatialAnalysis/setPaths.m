function obj = setPaths(obj, path)
% List of subject paths/available data.
% .import() will run actual import and subject-specific preprocessing -
% this is subject number based and must also be updated if numbers are
% changed by subject addition/removal.


%% Set data path

if ~exist('path', 'var')
    % Assume data\ is in directory above.
    dPath = [fileparts(pwd), '\Data\'];
else
    dPath = path;
end


%% Set output graph path 

% Just using [path]/Graphs/
gPath = 'Graphs\';


%% List of subjects

s = 1;
ex.(['s', num2str(s)]) = ... 1 (8)
    [dPath, 'ShriyaEye2\03-Mar-2017 14_55_20\SpatialCapture_ShriyaEye2.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 2 (9)
    [dPath, 'KatEye1\15-Mar-2017 12_32_08\SpatialCapture_KatEye1_backup.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 3 (10)
    [dPath, 'GarethEye3\22-Mar-2017 11_04_38\SpatialCapture_GarethEye3.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 4 (11)
    [dPath, '11XY\05-Apr-2017 09_57_28\SpatialCapture_11XY.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 5 (12)
    [dPath, '12NB\05-Apr-2017 14_53_36\SpatialCapture_12NB.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 6 (13)
    [dPath, '13SR\06-Apr-2017 15_20_21\SpatialCapture_13SR.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 7 (14)
    [dPath, '14JD\07-Apr-2017 10_11_53\SpatialCapture_14JD.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 8 (15)
    [dPath, '15SI\07-Apr-2017 16_08_46\SpatialCapture_15SI.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 9 (new)
    [dPath, '16J\23-Aug-2017 14_28_08\SpatialCapture_16J.mat']; ...
    s = s+1;
ex.(['s', num2str(s)]) = ... 10 (new)
    [dPath, '17D\30-Aug-2017 13_18_41\SpatialCapture_17D.mat']; ...
    % s = s+1; % Increment number and add here


%% List of available eye data

s = 1;
ey.(['s', num2str(s)]) = ... 1
    [dPath, 'ShriyaEye2\03-Mar-2017 14_55_20\ShriyaEye2.mat']; s = s+1;
ey.(['s', num2str(s)]) = ... 2
    [dPath, 'KatEye1\15-Mar-2017 12_32_08\KatEye1.mat']; s = s+1;
ey.(['s', num2str(s)]) = ... 3
    [dPath, 'GarethEye3\22-Mar-2017 11_04_38\GarethEye3.mat']; s = s+1;
ey.(['s', num2str(s)]) = ''; s = s+1; % 4
ey.(['s', num2str(s)]) = ... 5
    [dPath, '12NB\05-Apr-2017 14_53_36\12NB.mat']; s = s+1;
ey.(['s', num2str(s)]) = ... 6
    [dPath, '13SR\06-Apr-2017 15_20_21\13SR.mat']; s = s+1;
ey.(['s', num2str(s)]) = ''; s = s+1; % 7 - space issues
ey.(['s', num2str(s)]) = ... 8
    [dPath, '15SI\07-Apr-2017 16_08_46\15SI.mat']; s = s+1;
ey.(['s', num2str(s)]) = ... 9
    [dPath, '16J\23-Aug-2017 14_28_08\16J.mat']; s = s+1;
ey.(['s', num2str(s)]) = ... 10
    [dPath, '17D\30-Aug-2017 13_18_41\17D.mat']; s = s+1;

obj.eye = ey;
obj.exp = ex;
obj.paths.dPath = dPath;
obj.paths.gPath = gPath;
