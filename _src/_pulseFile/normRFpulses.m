function [RFpulses, maxRF] = normRFpulses(rfVec, RF, refVolt)

    nTxChan   = size(rfVec,1)/RF.nKpos/RF.pulseSets;
    flipAngle = rad2deg(RF.flipAngle);
    
    rfVec    = rfVec .* 1.23; %1.25 arbitrary scaling
    scale    = (0.5/0.1).*(flipAngle/90); % use this for fixed subpulse duration of 100us
%     scale    = (0.5./RF.subPulseDur).*(flipAngle/90);
%     scale    = repmat(scale,[nTxChan 1]);
%     scale    = (0.5/0.1).*(flipAngle/90).*2.17; % original
    scaledRF = (rfVec./(scale.*refVolt));

    RFpulses = reshape(scaledRF, [RF.nKpos, nTxChan, RF.pulseSets]);
    maxRF    = max(abs(scaledRF));

    disp(['maxScaledRF: ', num2str(maxRF)]);
%     if maxRF > 1 
%         f = errordlg('scaled RF amplitude >1');
%     end

end