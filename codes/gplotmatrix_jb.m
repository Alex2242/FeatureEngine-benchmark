%% Main contributors: Julien Bonnel, Dorian Cazau
function gplotmatrix_jb(dataMatrix, vecIndex, names)

n_response=length(vecIndex);
iplot=1;
for mm=1:n_response
    for nn=1:n_response
        if mm==nn
            subplot(n_response,n_response,iplot)
            histogram(dataMatrix(:,vecIndex(nn)), 50);
            xlabel(names{vecIndex(nn)})
            iplot=iplot+1;   
            grid on
        else
            subplot(n_response,n_response,iplot)
            plot(dataMatrix(:,vecIndex(nn)), dataMatrix(:,vecIndex(mm)), '.')
            xlabel(names{vecIndex(nn)})
            ylabel(names{vecIndex(mm)})
            iplot=iplot+1;   
            grid on
        end
    end
end
