% Copyright (C) 2017-2018 Project-ODE
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Main contributors: Julien Bonnel, Dorian Cazau, Paul Nguyen HD

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
