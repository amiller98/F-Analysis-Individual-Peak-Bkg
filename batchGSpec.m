function batchGSpec(folderDir)
%% Input Currents
currents = [50.3 49.2 46.1];
currents_file = [2 4 8]; % which number run does each current correspond to
% chronological order please

%% File set up
set(0,'DefaultFigureWindowStyle','docked')

d = struct2cell(dir([fullfile(folderDir),'/*.spe']));
nameList = d(1,:);

file_count = numel(nameList);

%% Information on peaks of interest
peaksOI = [109 197 770]; % list of peaks of interest in keV
sigma = [14 14 20]; % uncertainty in energy
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

%% Currents
file_num = 1:file_count;
inter_currents = interp1(currents_file, currents,file_num, 'linear','extrap')';

%% Continuing Analysis
fluorine1 = AUC_allfiles(:,1);
fluorine2 = AUC_allfiles(:,2);
argon = AUC_allfiles(:,3);
livetimes = AUC_allfiles(:,end);

% sum fluorine counts and error
totalF = fluorine1+fluorine2;
totalF_err = sqrt(sqrt(fluorine1).^2 + sqrt(fluorine2).^2)./totalF;

% divide argon counts by live time
ar_rate = argon./livetimes;
ar_rate_err = sqrt(argon)./argon./livetimes;

% take each Ar/s and divide by average Ar/s. multiply result by current
ar_I_norm = ar_rate./mean(ar_rate).*inter_currents;
ar_I_norm_err = ar_rate_err;

% (total F counts)/(Ar-Norm Current) * 1000 / livetime
ar_norm_counts_uC = totalF./ar_I_norm*1000./livetimes;
ar_norm_counts_uC_err = 1.96*sqrt(totalF_err.^2 + ar_I_norm_err.^2).*ar_norm_counts_uC*1000./livetimes;

%% Formatting Output
% filename, livetime, argon counts, Ar norm, Ar norm err
sz = [file_count 6];
vartypes = ["string" "double" "double" "double" "double" "double"];
varnames = ["Sample" "Livetime (s)" "770 keV counts" "Ar-Norm counts/uC" "error" "Current"];
output = table('Size',sz, 'VariableTypes', vartypes, 'VariableNames', varnames);
output.(1) = sorted_namelist;
output.(2) = livetimes;
output.(3) = argon;
output.(4) = ar_norm_counts_uC;
output.(5) = ar_norm_counts_uC_err;
output.(6) = inter_currents;

file = string(fullfile(folderDir, 'PIGEanalysis.xlsx'));
writetable(output,file,'Sheet',1);
end