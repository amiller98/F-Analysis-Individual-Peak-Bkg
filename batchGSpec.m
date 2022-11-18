function batchGSpec(folderDir)
%% Input Currents

current = 45; % single current value in nA
current_index = 5; % single value of which file corresponds to this current

% which number run does each current correspond to
% chronological order please

%% File set up
set(0,'DefaultFigureWindowStyle','docked')

d = struct2cell(dir([fullfile(folderDir),'/*.spe']));
nameList = d(1,:);

file_count = numel(nameList);

%% Information on peaks of interest
peaksOI = [383 688 2694]; % based on channels
%peaksOI = [109 197 770]; % list of peaks of interest in keV
sigma = [14 14 14]; % uncertainty in energy
AUC_allfiles = [];
datetime_allfiles = [];

%% Pull Count Rates for Peaks Of Interest
for i=1:file_count
    %clf
    figure(i);
    file = string(fullfile(folderDir, nameList(i)));
    spectrum = readspe(file);
    AUC = AUC_finder(spectrum,peaksOI, sigma);

    AUC_allfiles = [AUC_allfiles ; AUC];
    datetime_allfiles = [datetime_allfiles ; spectrum.time];
    
end

%% Sort files by time measurement took place
[~, key] = sort(datetime_allfiles);
r = 1:file_count;
r(key) = r;
termin = width(AUC_allfiles) + 1;
AUC_allfiles = sortrows([AUC_allfiles,r'],termin);
AUC_allfiles = AUC_allfiles(:,1:end-1);
AUC_allfiles = max(AUC_allfiles,0);
sorted_namelist = nameList(key)';

%% Continuing Analysis
fluorine1 = AUC_allfiles(:,1);
fluorine2 = AUC_allfiles(:,2);
argon = AUC_allfiles(:,3);
livetimes = AUC_allfiles(:,end-1);
realtimes = AUC_allfiles(:,end);

% sum fluorine counts and error
totalF = fluorine1+fluorine2;
totalF_err = sqrt(sqrt(fluorine1).^2 + sqrt(fluorine2).^2)./totalF; %relative err

% divide argon counts by live time
argon_error = sqrt(argon)./argon; %relative err

% calculate counts/uC
denominator = current.*livetimes(current_index).*argon;
norm_C_uC = 1000.*totalF.*argon(current_index)./denominator;
norm_C_uC_err = norm_C_uC.*sqrt(argon_error.^2 + totalF_err.^2);


%% Formatting Output
% filename, livetime, argon counts, Ar norm, Ar norm err
sz = [file_count 6];
vartypes = ["string" "double" "double" "double" "double" "double"];
varnames = ["Sample" "Realtime (s)" "770 keV counts" "Ar-Norm counts/uC" "error" "Fluorine Counts"];
output = table('Size',sz, 'VariableTypes', vartypes, 'VariableNames', varnames);
output.(1) = sorted_namelist;
output.(2) = realtimes;
output.(3) = argon;
output.(4) = norm_C_uC;
output.(5) = norm_C_uC_err;
output.(6) = totalF;
splitDir = split(folderDir,{'\' '/'});
properFileName = [splitDir{end,1} '_F_results.xlsx'];
file = string(fullfile(folderDir, properFileName));

writetable(output,file,'Sheet',1);
end