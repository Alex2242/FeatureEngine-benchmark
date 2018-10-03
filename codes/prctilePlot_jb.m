%% Main contributors: Julien Bonnel, Dorian Cazau
%%%% Percentile
pp=[1 5 50 95 99];

%%%% dB axis
mindB=min(min(vPSD_db));
maxdB=max(max(vPSD_db));
hind = 0.1;               % histogram bin width for probability densities (PD)
dbvec = mindB:hind:maxdB; % dB values at which to calculate empirical PD

%%% Compute probability densities
d = hist(vPSD_db,dbvec)/(hind*size(vspl,1));  %SPD array
d(d == 0) = NaN;   %suppress plotting of empty hist bins

%%% Compute percentiles
p=prctile(vPSD_db,pp,1);

%%% Compute RMS level
RMSlevel = 10*log10(mean(10.^(vPSD_db/10)));

%%% Plot
g = pcolor(fPSD,dbvec,d); 
set(g,'LineStyle','none')
% set(gca, 'XScale', 'log')
colorbar
grid on
hold on
plot(fPSD, p, 'k', 'linewidth', 2)
hold on
plot(fPSD, RMSlevel, 'r', 'linewidth', 2)
xlabel('Frequency (Hz)')
ylabel('PSD (dB re 1 \muPa^2/Hz)')
ylabel(colorbar,'Empirical Probability Density','fontsize',14,'fontname','Arial')
% caxis([0 0.05])

clearvars dbvec p d RMSlevel
