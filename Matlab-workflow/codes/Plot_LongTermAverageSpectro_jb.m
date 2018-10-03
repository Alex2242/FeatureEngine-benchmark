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

% function Plot_LongTermAverageSpectro_jb(A,fPSD,timestamp_num_spectro,auxData_t_psd,Opt)

UseTimeStamp= 1;

% Long-term spectrogram

clf;
imagesc(timestamp_num_spectro,fPSD,vPSD_db.');
colormap(1-gray)
set(gca,'YDir','normal')
ylabel('Frequency [ Hz ]')
ylabel(colorbar,'PSD [ dB re 1 \muPa^2 Hz^-^1 ]','fontname','arial','fontsize',14)

[LineSpecificationMatrix,~,ColorMatrix] = LineAndColorSpecificationMatrix(size(auxData_t_psd,2));

hold on,
for cc= 1:size(auxData_t_psd,2)

    Val_Desc = auxData_t_psd(:,cc);

    if ~isempty(find(Val_Desc<0, 1))
        Val_Desc = Val_Desc - nanmin(Val_Desc);
    end

    if OptLSTA.MV_Apply_MedFilt>0
        Val_Desc = medfilt1(Val_Desc,OptLSTA.MV_Apply_MedFilt,[],1);%,'omitnan');
    end

    plot(timestamp_num_spectro,...
        OptLSTA.OffsetFreqDescriptors + fPSD(end)/3 * abs(Val_Desc) / max(abs(Val_Desc)),...
        LineSpecificationMatrix{cc},'linewidth',1.2,'color',ColorMatrix(cc,:),'markersize',8);


    OptLSTA.OffsetFreqDescriptors = OptLSTA.OffsetFreqDescriptors + OptLSTA.InterFreqDescriptors;

end
legend(auxVarNames)
% ylim([0 1000]);

if UseTimeStamp
   PutTimeStamp(timestamp_num_spectro,OptLSTA)
end
