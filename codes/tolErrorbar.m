%% Main contributors: Julien Bonnel, Dorian Cazau, Paul Nguyen HD
function tolErrorbar(vtol, marker,centerFreq)
%tolErrorbar enables to plot tol of with standard error of the means (sem) with errorbar
% This function enables to save the boxplot and heatmaps of aggregated TOLs
% Taken from 
% https://medium.com/@SciencelyYours/errors-bars-standard-errors-and-confidence-intervals-on-line-and-bar-graphics-matlab-254d6aa32b76
% Syntax:  tolErrorbar( vtol)
%
% Input:    
%      vtol       - TOL to analyse
%      marker     - Markers to use in plots
%      centerFreq - Nominal center frequencies of analyzed TOL
%
% Output:  None - just a plot

n = size(vtol,1);

%% Compute standard error of the means (sem) of each tob
sem = std(vtol)/sqrt(n);

%% Plot
p1 = plot(mean(vtol));
set(p1, 'LineWidth', 0.5, 'Marker', marker,'MarkerSize', 8)
% e1 = errorbar(mean(vtol), sem); 
errorbar(mean(vtol), sem); 
set(gca,'XTickLabel',round(centerFreq))
% set(e1, 'LineStyle', 'none');
% eline = get(e1, 'Children');
% set(eline,  'LineWidth', 0.5, 'Marker', marker, 'MarkerSize', 3)


end

