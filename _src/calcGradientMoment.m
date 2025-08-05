function [gradMoment] = calcGradientMoment(deltaKloc)
    
    gamma = 42.577e6; % (Hz/T = 1/s/T)

    kTmove     = -diff(deltaKloc')';
    gradMoment = ((kTmove)/gamma);         % [s*T/m] gradMom/blipDur
    gradMoment = gradMoment.*1000000*1000; % [ms*uT/m] 

end