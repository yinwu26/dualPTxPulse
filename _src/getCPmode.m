function [CPMODE] = getCPmode(MAPS,bFlatten)

    disp('NOVA pTx CP-mode');
    CPMODE = MAPS.B1(:,:,:,1)*exp(1i*pi/4.0);
    for ii=2:8
        CPMODE = CPMODE + MAPS.B1(:,:,:,ii)*exp(1i*pi*(ii)/4.0);
    end
    
    if(bFlatten)
        CPMODE = CPMODE(:);
    end
end