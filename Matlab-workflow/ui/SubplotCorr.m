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

% Main contributors: Julien Bonnel, Dorian Cazau

ind_plot=1;
for ii=1:subplotsy
    for jj=1:subplotsx
        X = [Matrix_X(:,jj),Matrix_Y(:,ii)];
        tbl = table(X(:,1),X(:,2),'VariableNames', {'X1','X2'});

        if outlierRobustSwitch
            mdl = fitlm(tbl,'X2 ~ X1');
            outliers = mdl.Diagnostics.CooksDistance > 4*mean(mdl.Diagnostics.CooksDistance);
            mdl2 = fitlm(tbl,'X2 ~ X1','Exclude', outliers );
            [R,pval] = corr(X(~outliers,1),X(~outliers,2),'type','Pearson','rows','all','tail','both');
        else
            mdl2 = fitlm(tbl,'X2 ~ X1');
            [R,pval] = corr(X(:,1),X(:,2),'type','Pearson','rows','all','tail','both');
        end

        b=subplot(subplotsx,subplotsy,ind_plot);
        pp=plotAdded(mdl2);
        legend(b,'off');
        title(b,'')
        ylabel(names_statSoundscapeFeatureMatrix{Vec_IndexResponse(ii)},'interpreter','tex')
        xlabel(names_statSoundscapeFeatureMatrix{Vec_IndexExplain(jj)},'interpreter','tex')
        axis tight

        %%% Add Corr Coeff on the subplot
        %%% It will be written in bold if pvalue<0.05
        plotPos = get(b,'Position');
        if pval < 0.05
        annotation('textbox',plotPos,...
                   'String',strcat(num2str(R,'%3.2f')),...
                   'FontWeight','Bold',...
                   'EdgeColor','none','Tag','corrCoefs','fontsize',14)
        else
        annotation('textbox',plotPos,...
                   'String',strcat(num2str(R,'%3.2f')),...
                   'EdgeColor','none','Tag','corrCoefs','fontsize',14)
        end


        if jj>1
            ylabel('')
        end
        if ii<subplotsx
            xlabel('')
        end
        grid on

        ind_plot=ind_plot+1;
    end
end
