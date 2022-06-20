function output = batchGSpec(folderDir)

set(0,'DefaultFigureWindowStyle','docked')

d = struct2cell(dir([fullfile(folderDir),'/*.chn']));
nameList = d(1,:);

file_count = numel(nameList);

EOB_time = datetime("14:15:00"); % target 1
%EOB_time = datetime("16:13:00"); % target 2

%% Information on peaks of interest, branching ratios, and efficiencies
br_dataset = [271 1156 373; 1 0.999 0.225; 0.00213247284674966,0.000696709888999648,0.00169131310801699];
% isotopes = ["44mSc" "44gSc" "43Sc"];

%% Set up table of activity data
% sz = [0,num_peaks+1];
% types = ["double" "double" "double" "double"];
% names = ["TimeSinceEOB(s)" isotopes];
% output = table('Size',sz,'VariableTypes',types,'VariableNames',names);

holder = {};
%% Begin Execution of Analysis
for i=1:file_count
    %clf
    figure(i);
    file = string(fullfile(folderDir, nameList(i)));
    spectrum = readchn(file);
    AUC = peakFit(spectrum,br_dataset(1,:));
    dtstring = strsplit(spectrum.dtstamp, ' ');
    time_stamp = datetime(dtstring(1,2),'InputFormat','HH:mm:ss');
    
    %disp(time_stamp)
    elapsed_time = seconds(time(between(EOB_time,time_stamp)));
    
    if elapsed_time < 0
        elapsed_time = elapsed_time + 24*3600;
    end
    
    activity = AUC'./br_dataset(2,:)./br_dataset(3,:)./spectrum.livetime;
    
    new_row = [elapsed_time activity];
    holder = [holder ; new_row];
    
end

output = cell2table(holder);
output = sortrows(output,1);

end