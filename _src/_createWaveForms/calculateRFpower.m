function RFpowTOT = calculateRFpower(b, )
    % Uses complete RF waveform with time steps
    RFvolt = abs(PULSE.rf) .* PULSE.dt;
    
    RFpowCh  = sum(RFvolt.^2, 1);
    RFpowTOT = 
    
end