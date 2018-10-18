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

function Plot_LongTermAverageSpectro_jb(A,FrequencyVector,TimeVector,FeatureMatrix,Opt)
%Plot_LongTermAverageSpectro_jb(A,FrequencyVector,TimeVector,FeatureMatrix,Opt)
% This function enables to plot long term average spectrograms
%
% Syntax: Plot_LongTermAverageSpectro_jb(A,FrequencyVector,TimeVector,FeatureMatrix,Opt)
%
% Input:    
%      A - Spectrogram to plot
%      FrequencyVector - frequency array
%      TimeVector - time array
%      FeatureMatrix - Matrix containing auxiliary data
%      Opt - Structure containing options for the computation of LTSA
%
% Output:   
%      LTSA plot with auxiliary variables on it

% Note : 
%
% Author: Julien Bonnel, Dorian Cazau
% email: 
% date of creation: 
% Modified [date]
%   [COMMENTS ON MODIFICATIONS]

% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

UseTimeStamp= 1;

% Long-term spectrogram

clf; 
imagesc(TimeVector,FrequencyVector,A.');
colormap(1-gray)
set(gca,'YDir','normal')
ylabel('Frequency [ Hz ]')
ylabel(colorbar,'PSD [ dB re 1 \muPa^2 Hz^-^1 ]','fontname','arial','fontsize',14)

[LineSpecificationMatrix,~,ColorMatrix] = LineAndColorSpecificationMatrix(size(FeatureMatrix,2)); 

hold on,
for cc= 1:size(FeatureMatrix,2)  
        
    Val_Desc = FeatureMatrix(:,cc);
 
    if length(find(Val_Desc<0))>0
        Val_Desc = Val_Desc - nanmin(Val_Desc);        
    end
    
    if Opt.MV_Apply_MedFilt>0
        Val_Desc = medfilt1(Val_Desc,Opt.MV_Apply_MedFilt,[],1);%,'omitnan');
    end

    plot(TimeVector,...
        Opt.OffsetFreqDescriptors + FrequencyVector(end)/3 * abs(Val_Desc) / max(abs(Val_Desc)),...
        LineSpecificationMatrix{cc},'linewidth',1.2,'color',ColorMatrix(cc,:),'markersize',8);

    
    Opt.OffsetFreqDescriptors = Opt.OffsetFreqDescriptors + Opt.InterFreqDescriptors;

end
legend(Opt.AuxVariableNames)
    
if UseTimeStamp   
   PutTimeStamp(TimeVector,Opt) 
end

end
