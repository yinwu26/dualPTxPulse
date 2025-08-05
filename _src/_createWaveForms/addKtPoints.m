function [rfSeq, g, endTimeStep] = addKtPoints(dt, kTstart, rfSeq, g, RF)

    gamma = 42.577e6; % (Hz/T = 1/s/T)
    
    %% Timing
    if length(RF.subPulseDur) == 1
        RF.subPulseDur = repmat(RF.subPulseDur, RF.nKpos, 1);
    end
    
    gradBlipSteps   = round(RF.gradBlipDur/dt)+1;
    rfSubPulseSteps = round(RF.subPulseDur./dt);
    
    gStartTime = ones(1,RF.nKpos-1);
    rfStartT   = ones(1,RF.nKpos);
    
    gStartTime(1) = kTstart;
    for i = 1:RF.nKpos  
        rfStartT(i)     = gStartTime(i) + gradBlipSteps;
        gStartTime(i+1) = rfStartT(i) + rfSubPulseSteps(i);
    end
    
    endTimeStep = gStartTime(end)+gradBlipSteps-1;
    
    %% RF subpulses
    for i = 1:size(RF.pulse,2)
        rfSeq(i,:) = addRFpulse(rfStartT, RF.subPulseDur, dt, RF.pulse(:,i), rfSeq(i,:), 'kT');
    end
    
    %% gradient blips
    rampTime = floor(RF.gradBlipDur/20e-6)*10e-6;
%     rampTime = RF.gradRampDur; %RF.gradBlipDur/2;
    
    % initialise/apply gradient blips
    kTloc  = [0,0,0; RF.kLoc'; 0,0,0]';
    kTmove = -diff(kTloc')';
    
    gradMom = (kTmove)/gamma; % [s*T/m] 
    
    g(1,:) = addGrad(dt, RF.gradBlipDur, rampTime, gradMom(1,:), g(1,:), gStartTime, 'mom');
    g(2,:) = addGrad(dt, RF.gradBlipDur, rampTime, gradMom(2,:), g(2,:), gStartTime, 'mom');
    g(3,:) = addGrad(dt, RF.gradBlipDur, rampTime, gradMom(3,:), g(3,:), gStartTime, 'mom');


end