function output = batchGSpec(folderDir)

set(0,'DefaultFigureWindowStyle','docked')

d = struct2cell(dir([fullfile(folderDir),'/*.spe']));
nameList = d(1,:);

file_count = numel(nameList);

%% Information on peaks of interest
peaksOI = [109 197 770];
holder = [];

%% Pull Count Rates for Peaks Of Interest
for i=1:file_count
    %clf
    figure(i);
    file = string(fullfile(folderDir, nameList(i)));
    spectrum = readspe(file);
    AUC = peakFit(spectrum,peaksOI);

    countrate = AUC'./spectrum.livetime;
  
    holder = [holder ; countrate];
    
end

end