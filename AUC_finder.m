function data = AUC_finder(spectrum,peaksOI, sigma)

num_peaks = length(peaksOI);
AUC = zeros(1,num_peaks+1);
counts = spectrum.counts;
for i = 1:num_peaks
    mean_cn = round((peaksOI(i) - spectrum.intercept)/spectrum.slope);
    idxrng = mean_cn-2*sigma:mean_cn+2*sigma;
    
    total_auc = counts(idxrng);
    
    low_counts = counts(mean_cn-2*sigma);
    high_counts = counts(mean_cn+2*sigma);
    
    x = [(mean_cn-2*sigma) (mean_cn+2*sigma)];
    y = [low_counts high_counts];
    
    fit = polyfit(x,y,1);
    
    background = polyval(fit,idxrng);
    
    AUC(1,i) = sum(total_auc - background');
    
end
AUC(1,num_peaks+1) = spectrum.livetime;
data = AUC;
end

