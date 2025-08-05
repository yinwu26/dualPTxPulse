function PULSEDESIGN = optSubPulseDur(b, PULSEDESIGN, desiredFA, peakB1)
nTxChan = length(b)/PULSEDESIGN.nKpos;

% %--------------------------------------------------------------------------
% %% generate RF and gradient pulse waveforms
% %--------------------------------------------------------------------------
% PULSE = createRFandGradWaveForms(PULSEDESIGN, b, 10e-6);
% displaysequence(PULSE);
% 
% totPowerBef = sum(abs(PULSE.rf).^2,'all');

%% Sequence design
RFvoltage = reshape(b, [PULSEDESIGN.nKpos, nTxChan]) * rad2deg(PULSEDESIGN.flipAngle);
RFvoltage = ((RFvoltage.*100e-6)./PULSEDESIGN.subPulseDur) .* desiredFA;

%%-----------------------------------------------------------------------%%
%% Adjust subpulse durations (to lower RF power)
%%-----------------------------------------------------------------------%%
% peakRFvolt = 180; %[V] for 90deg flip
% [RFmag,rfInd] = max(abs(RFvoltage),[],2);
% 
% PULSEDESIGN.subPulseDur(RFmag>peakRFvolt) = PULSEDESIGN.subPulseDur(RFmag>peakRFvolt)*2;

%%
peakRFvolt = (peakB1/11.7)*PULSEDESIGN.refVoltage;
[RFmag,rfInd] = max(abs(RFvoltage),[],2);

subPulseDur = (RFmag .* PULSEDESIGN.subPulseDur)./peakRFvolt;
PULSEDESIGN.subPulseDur = round(subPulseDur,5);% ceil(subpluseDur/10)*10;

end