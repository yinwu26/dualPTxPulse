function [seqPar] = createRFandGradWaveForms(DESIGN, pulse, dt)
    %% Allocate memory
    nTxChan = size(pulse,1)/DESIGN.nKpos;
    nT      = round((sum(DESIGN.subPulseDur+DESIGN.gradBlipDur+dt)+DESIGN.gradBlipDur)/dt)+1;
    rf      = zeros(nTxChan,nT);                % RF waveform
    g       = zeros(3,nT);                      % gradient waveform

    %% Initialise space
    time    = (1:nT)*dt;                   % Timeline for plotting

    %% Sequence design
    DESIGN.pulse = reshape(pulse, [DESIGN.nKpos, nTxChan]) * rad2deg(DESIGN.flipAngle);
    DESIGN.pulse = (DESIGN.pulse.*100e-6)./DESIGN.subPulseDur;

    kTstart  = 1;
    [rf, g, ~] = addKtPoints(dt, kTstart, rf, g, DESIGN);

    %% Store sequence elements
    seqPar.time  = time;
    seqPar.rf = rf;
    seqPar.g  = g;
    seqPar.dt = dt;
    seqPar.nTimeSteps = nT;
end