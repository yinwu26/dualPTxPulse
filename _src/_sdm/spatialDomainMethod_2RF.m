function [pulse, mTvol, NRMSE, target] = spatialDomainMethod_2RF(RF, MAPS)
    
    [nX,nY,nZ,nC] = size(MAPS.B1);

    % Check
    if size(RF.kLoc,2) ~= RF.nKpos
        disp('Mismatch: number of k-space positions and subpulses.');
        return
    end
    
    % define target indices
    indices = find(MAPS.mask~=0);
    
    targetMag = MAPS.targetMag;
    targetPha = MAPS.initTargetPha;

    %% Create magnetization matrix (Afull)
    [Afull,~] = createMagMatrix(indices, RF, MAPS);

    A = angle(MAPS.dPhaseC)/2;
    
    targetPha1 = targetPha.*exp(-1i*A);
    targetPha2 = targetPha.*exp( 1i*A);

%     A = angle(MAPS.dPhaseC);
%     
%     targetPha1 = targetPha;
%     targetPha2 = targetPha.*exp(1i*A);
    
    %% Tikhonov reg and pseudo inverse 

    invA = pinv(Afull'*Afull + RF.tikLambda*eye(nC*RF.nKpos));
    invA = invA'*Afull';

    for i = 1:RF.iterations
        pulse1 = invA*(targetMag.*targetPha1);
        pulse2 = invA*(targetMag.*targetPha2);
        
        %% calculate delta phase needed to enforce refcousing 
        tmpPha = exp(1i*angle(Afull*pulse1)) + exp(1i*angle(Afull*pulse2));
        tmpPha = exp(1i*angle(tmpPha));

        targetPha1 = tmpPha.*exp(-1i*A);
        targetPha2 = tmpPha.*exp( 1i*A);

%         tmpPha = exp(1i*angle(Afull*pulse1));
%         
%         targetPha1 = tmpPha;
%         targetPha2 = tmpPha.*exp(1i*A);

        % calculate NRMSE
        mT1   = Afull*pulse1;
        mT2   = Afull*pulse2;
        targ1 = targetMag .* targetPha1;
        targ2 = targetMag .* targetPha2;
        
        disp(['p1 = ', num2str(getNRMSE(mT1,targ1)),' p2 = ', num2str(getNRMSE(mT2,targ2))]);

    end

    %% expected transverse magnetisation
    mTvec1 = Afull*pulse1;
    mTvec2 = Afull*pulse2;
    
    mTvol          = reshape(mTvec1, nX, nY, nZ);
    mTvol(:,:,:,2) = reshape(mTvec2, nX, nY, nZ);
    
    pulse = [pulse1; pulse2];
            
    target          = reshape(targetMag.*targetPha1, [nX, nY, nZ]);
    target(:,:,:,2) = reshape(targetMag.*targetPha2, [nX, nY, nZ]);
    
    %% Normalised Root Mean Square Error (NRMSE)
    for ii = 1:RF.pulseSets
        % Global NRMSE (mT)
        NRMSE(1,ii) = sqrt(sum((abs(mTvol(:,:,:,ii))-abs(target(:,:,:,ii))).^2, 'all')/sum(abs(target(:,:,:,ii)).^2, 'all'));

        % Flip Angle NRMSE
        FAtarget  = asind(abs(target(:,:,:,ii))); 
        FAvol = asind(abs(mTvol(:,:,:,ii)));

        NRMSE(2,ii) = sqrt(sum((abs(FAvol)-abs(FAtarget)).^2, 'all')/sum(abs(FAtarget).^2, 'all'));
    end
end