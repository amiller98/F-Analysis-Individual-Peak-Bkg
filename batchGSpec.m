function batchGSpec(folderDir)

set(0,'DefaultFigureWindowStyle','docked')

d = struct2cell(dir([fullfile(folderDir),'/*.spe']));
nameList = d(1,:);

file_count = numel(nameList);

%% Information on peaks of interest
peaksOI = [109 197 770 1219]; % list of peaks of interest in keV
sigma = [14 14 14 7]; % uncertainty in energy
AUC_allfiles = [];

%% Pull Count Rates for Peaks Of Interest
for i=1:file_count
    %clf
    %figure(i);
    file = string(fullfile(folderDir, nameList(i)));
    spectrum = readspe(file);
    AUC = AUC_finder(spectrum,peaksOI, sigma);

    AUC_allfiles = [AUC_allfiles ; AUC];
    
end

%% Errors and Currents

% Generate currents for each file
file_num = 1:file_count;
currents = [50.3 49.2 46.1];
currents_file = [2 5 7];
inter_currents = interp1(currents_file, currents,file_num, 'linear','extrap')';

% calculate error of peak
% calculate error of background
% combine errors

%% Continuing Analysis
fluorine1 = AUC_allfiles(:,1);
fluorine2 = AUC_allfiles(:,2);
argon = AUC_allfiles(:,3);
chlorine = AUC_allfiles(:,4);
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
varnames = ["Sample" "Livetime (s)" "770 keV counts" "Ar-Norm counts/uC" "error" "1219 keV counts"];
output = table('Size',sz, 'VariableTypes', vartypes, 'VariableNames', varnames);
output.(1) = nameList';
output.(2) = livetimes;
output.(3) = argon;
output.(4) = ar_norm_counts_uC;
output.(5) = ar_norm_counts_uC_err;
output.(6) = chlorine;

writetable(output,'PIGEanalysis.xlsx','Sheet',1);
end