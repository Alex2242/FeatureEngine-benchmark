%% Main contributors: Julien Bonnel, Dorian Cazau
function PutTimeStamp(TimeVector,Opt)

if nargin<2
   Opt=[]; 
end

if ~isfield(Opt,'NberLabelX')
    Opt.NberLabelX=20;
end
if ~isfield(Opt,'TimeStampFormat')
    Opt.TimeStampFormat ='YYYY-mm-dd';
end
% if isfield(Opt,'ZoomTimeStamp')
%     ind=TimeVector>Opt.ZoomTimeStamp(1) & ...
%         TimeVector<Opt.ZoomTimeStamp(2);
%     TimeVector=TimeVector(ind);
%     xlim([Opt.ZoomTimeStamp(1);Opt.ZoomTimeStamp(2)])    
% end
if ~isfield(Opt,'Change_Ytick')
    Opt.Change_Ytick=0;
end

sec2dtn = datenum(1982,08,01,00,00,01)-datenum(1982,08,01,00,00,00); dtn2sec = 1/sec2dtn;

DtnVal = TimeVector(1:floor(length(TimeVector) / Opt.NberLabelX):end,1);

sec2dtn = datenum(1982,08,01,00,00,01)-datenum(1982,08,01,00,00,00);
dtn2sec = 1/sec2dtn;
DayCo = (DtnVal(end,1)-DtnVal(1,1))*dtn2sec/3600/24;
if DayCo<2
    Opt.TimeStampFormat ='mm/dd HH:MM';
end

for xx=1:length(DtnVal)
    Xlab{xx} = datestr(DtnVal(xx),Opt.TimeStampFormat);
end

set(gco,'XData',TimeVector);
set(gca,'XTick',DtnVal)
set(gca,'XTickLabel',Xlab)
set(gca,'Xgrid','on')

if verLessThan('matlab','9.1')
    xticklabel_rotate(DtnVal,45,Xlab); 
else
    xtickangle(45); 
end

end

