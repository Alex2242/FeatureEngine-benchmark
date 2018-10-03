%% Main contributors: Julien Bonnel, Dorian Cazau, Paul Nguyen HD
function FormatFigures(NameFig)

box on

h = get(0,'children');
scrsz = get(0,'ScreenSize');
set(h,'Position',[scrsz(1) scrsz(2) scrsz(3) scrsz(4)])  

set(gcf,'color','w'); 

print(gcf,NameFig,'-dpng')
saveas(gcf,NameFig,'fig')
    
close(gcf)

end
