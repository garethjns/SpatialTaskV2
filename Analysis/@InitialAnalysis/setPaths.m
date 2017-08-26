function obj = setPaths(obj, path)

% Data\ is in directory above.
dPath = [fileparts(path), '\Data\'];

% Historical list of exps - add new to end. Will be reassigned numbers in
% processing.
% Paths can be changed here
s = 1;
ex.(['s', num2str(s)]) = ... 1
    [dPath, 'Nicole\07-Apr-2016 16_24_11\SpatialCapture_Nicole.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 2
    [dPath, 'Gareth\21-Apr-2016 15_56_01\SpatialCapture_Gareth.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 3
    [dPath, '2\26-Apr-2016 17_04_28\SpatialCapture_2.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 4
    [dPath, '4.2\08-Jul-2016 12_45_35\SpatialCapture_4.2.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 5
    [dPath, '5.2\08-Jul-2016 15_03_32\SpatialCapture_5.2.mat'];...
    s=s+1;
ex.(['s', num2str(s)]) = ... 6
    [dPath, '6.1\08-Jul-2016 16_19_28\SpatialCapture_6.1.mat'];...
    s=s+1;
ex.(['s', num2str(s)]) = ... 7
    [dPath, 'GarethEye\21-Feb-2017 15_53_30\SpatialCapture_GarethEye.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 8
    [dPath, 'ShriyaEye2\03-Mar-2017 14_55_20\SpatialCapture_ShriyaEye2.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 9
    [dPath, 'KatEye1\15-Mar-2017 12_32_08\SpatialCapture_KatEye1_backup.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 10
    [dPath, 'GarethEye3\22-Mar-2017 11_04_38\SpatialCapture_GarethEye3.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 11
    [dPath, '11XY\05-Apr-2017 09_57_28\SpatialCapture_11XY.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 12
    [dPath, '12NB\05-Apr-2017 14_53_36\SpatialCapture_12NB.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 13
    [dPath, '13SR\06-Apr-2017 15_20_21\SpatialCapture_13SR.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 14
    [dPath, '14JD\07-Apr-2017 10_11_53\SpatialCapture_14JD.mat']; ...
    s=s+1;
ex.(['s', num2str(s)]) = ... 15
    [dPath, '15SI\07-Apr-2017 16_08_46\SpatialCapture_15SI.mat']; ...
    s=s+1;
% Corresponding list of eyedata paths
s = 1;
ey.(['s', num2str(s)]) = ''; s=s+1; % 1
ey.(['s', num2str(s)]) = ''; s=s+1; % 2
ey.(['s', num2str(s)]) = ''; s=s+1; % 3
ey.(['s', num2str(s)]) = ''; s=s+1; % 4
ey.(['s', num2str(s)]) = ''; s=s+1; % 5
ey.(['s', num2str(s)]) = ''; s=s+1; % 6
ey.(['s', num2str(s)]) = ''; s=s+1; % 7, Recording, but time sync failed
ey.(['s', num2str(s)]) = ... 8
    [dPath, 'ShriyaEye2\03-Mar-2017 14_55_20\ShriyaEye2.mat']; s=s+1;
ey.(['s', num2str(s)]) = ... 9
    [dPath, 'KatEye1\15-Mar-2017 12_32_08\KatEye1.mat']; s=s+1;
ey.(['s', num2str(s)]) = ... 10
    [dPath, 'GarethEye3\22-Mar-2017 11_04_38\GarethEye3.mat']; s=s+1;
ey.(['s', num2str(s)]) = ''; s=s+1; % 11 processing
ey.(['s', num2str(s)]) = ... 12
    [dPath, '12NB\05-Apr-2017 14_53_36\12NB.mat']; s=s+1;
ey.(['s', num2str(s)]) = ... 13
    [dPath, '13SR\06-Apr-2017 15_20_21\13SR.mat']; s=s+1;
ey.(['s', num2str(s)]) = ''; s=s+1; % 14 - space issues
ey.(['s', num2str(s)]) = ... 15
    [dPath, '15SI\07-Apr-2017 16_08_46\15SI.mat']; s=s+1;

obj.eye = ey;
obj.exp = ex;
