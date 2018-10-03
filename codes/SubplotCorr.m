%% Main contributors: Julien Bonnel, Dorian Cazau
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

