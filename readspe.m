function spedat = readspe(fname)
    data = struct;
    oneline = fileread(fname); % import as character vector 
    multiline =  transpose(strsplit(oneline, "\n")); % split by \n
    
    %% Pull Timing Information
    timing = split(multiline(10),' ');
    data.livetime = str2num(timing{1,1});
    data.realtime = str2num(timing{2,1});
    
    %% Pull Energy Fit
    
    e_idx = find(contains(multiline,'ENER'))+1;
    fit = split(multiline(e_idx),' ');
    intercept = str2num(fit{1,1});
    slope = str2num(fit{2,1});
    
    channels = 1:8192;
    data.channels = channels;
    data.energy = (slope * channels + intercept)';
    data.slope = slope;
    data.intercept = intercept;
    
    %% Pull Data
    idxstart = 13;
    idxend = 8204;
    counts = multiline(idxstart:idxend,1);
    data.counts = str2double(counts);
    
    %% Sending Data
    spedat = data;
    % This contains: livetime, realtime, energy, counts
end

