function create_PulseFile(PTXRFQ, PTXGRQ, RFpulses, PULSEDESIGN, MAPS)
    % This function creates binary files for pTx bSSFP sequence.
    
    % INPUT
    %     PTXRFQ: RF binary file name
    %     PTXGRQ: GR binary file name
    %     RFpulses: scaled RF pulses for all channels
    %     pulseDesign: pulse design struct - contains gradient information
    %
    % OUTPUT
    %     Separate *.double binary files containing RF and gradient pulses
    
    nTx = size(MAPS.B1, 4);
    
    %% Create/Save RF and gradient pulse files
    fileID = fopen(PTXRFQ,'w');
    
    for ii=1:PULSEDESIGN.nKpos
        for jj=1:nTx
            tmpReal =  real(RFpulses(ii,jj));
            tmpImag = -imag(RFpulses(ii,jj)); % conjugate phase

            fwrite(fileID,tmpReal,'double'); %real
            fwrite(fileID,tmpImag,'double'); %imag
        end
    end

    fclose(fileID);

    %% calculate gradient moments
    gamma  = 42.577e6; % (Hz/T = 1/s/T)
    kTloc  = [0,0,0; PULSEDESIGN.kLoc'; 0,0,0]';
    kTmove = -diff(kTloc')';
    
    gradMoment = ((kTmove)/gamma);         % [s*T/m] gradMom/blipDur
    gradMoment = gradMoment.*1000000*1000; % [ms*uT/m] 
    
%     gradMoment = PULSEDESIGN.gradMoments;
    
    %% save gradient binary
    fileID = fopen(PTXGRQ,'w');

    for ii=1:size(gradMoment,2)
        tmpX = gradMoment(1,ii);
        tmpY = gradMoment(2,ii);
        tmpZ = gradMoment(3,ii);

        fwrite(fileID,tmpX,'double'); %X Gradient
        fwrite(fileID,tmpY,'double'); %Y Gradient
        fwrite(fileID,tmpZ,'double'); %Z Gradient
    end

%     fwrite(fileID,  0,'double'); %x
%     fwrite(fileID,  0,'double'); %y
%     fwrite(fileID,  0,'double'); %z

    fclose(fileID);
end