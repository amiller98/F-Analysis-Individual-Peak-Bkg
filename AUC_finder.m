function data = AUC_finder(spectrum,peaksOI, sigma)

num_peaks = length(peaksOI);
AUC = zeros(1,num_peaks+1);
counts = spectrum.counts;
hold on
for i = 1:num_peaks
    mean_cn = peaksOI(i);
    %mean_cn = round((peaksOI(i) - spectrum.intercept)/spectrum.slope);
    lowidx = (mean_cn-2*sigma(i));
    highidx = (mean_cn+2*sigma(i));
    idxrng = lowidx:highidx;
    
    total_auc = counts(idxrng);
    
    avg_width = 3;
    low_counts = mean(counts(lowidx-avg_width:lowidx+avg_width));
    high_counts = mean(counts(highidx-avg_width:highidx+avg_width));
    
    x = [lowidx highidx];
    y = [low_counts high_counts];
    
    fit = polyfit(x,y,1);
    
    background = polyval(fit,idxrng);
    
    AUC(1,i) = sum(total_auc - background');
    plot(idxrng,total_auc - background');
    
end
hold off
AUC(1,num_peaks+1) = spectrum.livetime;
data = AUC;
end

