function rfSeq = addRFpulse(startT, pulseDur, dt, rfVal, rfSeq, type)
    
    gamma = 2*pi*42.577e6;
    
    switch type
        case 'rect'
            % rfVal is flip angle (radians)
            rfSeq(startT:(startT + round(pulseDur/dt)-1)) = rfVal/(gamma*pulseDur); 
            
        case 'rectAmp'
            rfSeq(startT:(startT + round(pulseDur/dt)-1)) = rfVal;
        
        case 'kT'
            for i = 1:length(startT)
                rfSeq(startT(i):(startT(i) + round(pulseDur(i)/dt)-1)) = rfVal(i);
            end
            
    end
            
    
end