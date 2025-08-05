function grad = addGrad(dt, gDur, rampTime, gradVal, grad, startT, type)
    
    % INPUT 
    %     dt:       [s] time step
    %     gDur:     [s] gradient duration
    %     rampTime: [s] ramp up/down time 
    %     gradVal:  [s*T/m] gradient moment
    %     grad:     gradient seq vector
    %     startT:   gradient start vector element
    
    % NB: gradient slew rate limit 200mT/m/s
    %     max gradient amplitude limit 70mT/m
    switch type
        case 'mom'
            gradAmp = gradVal ./ (gDur - rampTime); % [T/m]
            
            slewRate = max(abs(gradAmp./rampTime));
            if slewRate>200
                disp(['Slew Rate limit exceeded! [', num2str(slewRate), '] Increase gradient duration.']);
            else 
                disp(['Slew Rate [', num2str(slewRate), ']']);
            end
            
            flatTopDur = gDur - (2*rampTime);

            for i = 1:length(startT)
                flatTop  = startT(i) + round(rampTime/dt);
                rampDown = flatTop + round(flatTopDur/dt);

                grad(startT(i):startT(i)+(round(rampTime/dt))) = linspace(0, gradAmp(i), round(rampTime/dt)+1);
                grad(flatTop:flatTop+(round(flatTopDur/dt)-1))   = gradAmp(i);
                grad(rampDown:rampDown+(round(rampTime/dt)))   = linspace(gradAmp(i), 0, round(rampTime/dt)+1);

            end

        case 'amp'
            flatTopDur = gDur - (2*rampTime);

            for i = 1:length(startT)
                flatTop  = startT(i) + round(rampTime/dt)+1;
                rampDown = flatTop + round(flatTopDur/dt)-1;

                grad(startT(i):startT(i)+(round(rampTime/dt))) = linspace(0, gradVal(i), round(rampTime/dt)+1);
                grad(flatTop:flatTop+(round(flatTopDur/dt)-1))   = gradVal(i);
                grad(rampDown:rampDown+(round(rampTime/dt)-1))   = linspace(gradVal(i), 0, round(rampTime/dt)+1);

            end
    
    end
end