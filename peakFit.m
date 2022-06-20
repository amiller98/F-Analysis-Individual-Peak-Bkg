function output = peakFit(data,peaks_OI)
x = data.energy';
y = data.count;
gausfcn = @(b,x) b(1) .* exp(-((x-b(2)).^2)./b(3));                         
SSECF = @(b,x,y) sum((y - gausfcn(b,x)).^2);

%smooth_y = movmean(y,10);

[pks,locs,w,p] = findpeaks(y, 'MinPeakDist',10, 'MinPeakHeight',20, 'Threshold', 0, ...
    'MinPeakProminence', 100, 'WidthReference','halfheight');          

q = x(locs); % energy of peaks
%peaks_OI = [271 1156 373];
%% Select Peaks of Interest
peaksfound = zeros(1,length(peaks_OI));
for i = 1:length(peaks_OI)
    [val,idx] = min(abs(peaks_OI(i) - q));
    peaksfound(1,i) = idx;
    
end
output = zeros(length(peaks_OI),1);
counter = 1;

hold on
%% Perform Fits on Selected Peaks
for k1 = peaksfound
        idxrng = locs(k1)-25 : locs(k1)+25;
        %%%%%%%%%%%%%%%% Individal background removal 

        scatter(x(idxrng),y(idxrng));
        low_idx = find(x >= x(locs(k1))-w(k1)/2,1);
        high_idx = find(x >= x(locs(k1))+w(k1)/2,1);
        x_back1 = [mean(x(low_idx-10:low_idx-5)), mean(x(low_idx-5:low_idx)), ...
            mean(x(high_idx+5:high_idx+10)), mean(x(high_idx:high_idx+5)),];
        %y_back1 = [y(low_idx-5), y(low_idx), y(high_idx), y(high_idx+5)];
        
        y_back1 = [mean(y(low_idx-10:low_idx-5)), mean(y(low_idx-5:low_idx)), ...
            mean(y(high_idx+5:high_idx+10)), mean(y(high_idx:high_idx+5)),];

        %y_background = interp1(x_back1,y_back1, x(idxrng));
        p = polyfit(x_back1,y_back1,2);
        y_background = polyval(p,x(idxrng));

        scatter(x_back1,y_back1);
        plot(x(idxrng),y_background,'LineWidth', 2.0)

        %%%%%%%%%%%%%%%% End of background removal.

        temp_x = x(idxrng);
        temp_y = y(idxrng) - y_background;
        scatter(temp_x,temp_y);
        [Parms(:,k1), SSE(k1)] = fminsearch(@(b)(SSECF(b,temp_x,temp_y)), [max(temp_y); x(locs(k1)); 1]);
        x_gaussian = min(temp_x):0.001:max(temp_x);
        AUC(k1) = trapz(x_gaussian, gausfcn(Parms(:,k1),x_gaussian));
        FWHM(k1) = 2*sqrt(2*log(2))*Parms(3,k1);
        
        output(counter,1) = AUC(k1);
        counter = counter+1;
        plot(x_gaussian, gausfcn(Parms(:,k1),x_gaussian), 'LineWidth',1)
end
hold on
plot(x, y, 'LineWidth',1)
%plot(x(locs), pks, '^r')

grid
hold off
end