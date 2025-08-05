function [Afull, compressedA] = createMagMatrix(indices, PULSE, MAPS)
    
    gamma = 42.577e6; % Hz/T
    
    [nX,nY,nZ,nC] = size(MAPS.B1);
    tmpA = zeros(nX*nY*nZ, PULSE.nKpos, nC);

    % Setup XYZ coordinates
    B1x = reshape(MAPS.B1,[nX*nY*nZ,nC]);
    B0x = MAPS.B0(:) * 42.577e6; % [T]->[Hz]
    pos = MAPS.PO(:,:)';
    
    totalPulDur = sum(PULSE.subPulseDur)+PULSE.gradBlipDur*PULSE.nKpos;
        
    for ii = 1:nC 
        offsetDur = totalPulDur - (PULSE.subPulseDur(1)/2);
        for jj = 1:PULSE.nKpos
            % consider B0
            tmpA(:,jj,ii) = exp(1i*2*pi*(B0x*(offsetDur)));
            
            % K-space points
            tmpA(:,jj,ii) = (exp(1i*2*pi*(pos*PULSE.kLoc(:,jj)))) .* tmpA(:,jj,ii);
            
            % Sensitivity Map
            tmpA(:,jj,ii) = (1i*2*pi*gamma*100e-6*B1x(:,ii)) .* tmpA(:,jj,ii);
%             tmpA(:,jj,ii) = (1i*2*pi*gamma*PULSE.subPulseDur(jj)*B1x(:,ii)) .* tmpA(:,jj,ii);
            
            % update pulse offset duration 
            % NB: assuming there is no minimum time gap between RF pulse
            % objects unlike in the sequence.
            if jj < PULSE.nKpos
                offsetDur = offsetDur-(sum(PULSE.subPulseDur(jj:jj+1))/2)-PULSE.gradBlipDur;
            end
        end
    end
    
    % Format: Afull(spatialPos, [channel1 subpulses, ..., channelN subpulses])
    Afull       = reshape(tmpA, [nX*nY*nZ, PULSE.nKpos*nC]); 
    compressedA = Afull(indices,:);
    
end