function [pulse, mTvol, NRMSE, target] = spatialDomainMethod(RF, MAPS)
    
    [nX,nY,nZ,nC] = size(MAPS.B1);
    
    % Check
    if size(RF.kLoc,2) ~= RF.nKpos
        disp('Mismatch: number of k-space positions and subpulses.');
        return
    end
    
    % define target indices
    indices = find(MAPS.mask~=0);
    
    targetMag   = MAPS.targetMag;
    targetPha = MAPS.initTargetPha;

    %% Create magnetization matrix (Afull)
    [Afull,~] = createMagMatrix(indices, RF, MAPS);    
    
    %% Tikhonov reg and pseudo inverse 

    invA = pinv(Afull'*Afull + RF.tikLambda*eye(nC*RF.nKpos));
    invA = invA'*Afull';

    for i = 1:RF.iterations
        pulse = invA*(targetMag.*targetPha);

        targetPha = exp(1i.*angle(Afull*pulse)); % update target phase
        
        % calculate NRMSE
%         mT1   = Afull*pulse;
%         targ1 = targetMag .* targetPha;
%         
%         disp(['iter ',num2str(i), '= ', num2str(getNRMSE(mT1,targ1))]);
    end

    target = reshape(targetMag.*targetPha, [nX, nY, nZ]);
    
    %% expected transverse magnetisation
    mTvec = Afull*pulse;
    mTvol = reshape(mTvec, nX, nY, nZ);
    
    %% Normalised Root Mean Square Error (NRMSE)
    NRMSE = getNRMSE(mTvol,target);
    disp(['NRMSE     : ', num2str(NRMSE)]);

end