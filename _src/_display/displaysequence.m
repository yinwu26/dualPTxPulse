function displaysequence(PULSE, varargin)

    time = PULSE.time;
    if nargin > 1
        range = varargin{1};
    else
        range = PULSE.nTimeSteps;
    end
    
    figure();
    subplot(5,1,1); plot(time*1e3, abs(PULSE.rf));
    ylabel('RF (V)')
    xlim([0 time(range)*1e3])
    
    subplot(5,1,2); plot(time*1e3, angle(PULSE.rf)); 
    ylabel('RF Phase (rad)')
    xlim([0 time(range)*1e3])
    
    subplot(5,1,3); plot(time*1e3, PULSE.g(1,:)*1e3); 
    ylabel('G_x (mT/m)')
    xlim([0 time(range)*1e3])
    
    subplot(5,1,4); plot(time*1e3, PULSE.g(2,:)*1e3); 
    ylabel('G_y (mT/m)')
    xlim([0 time(range)*1e3])
    
    subplot(5,1,5); plot(time*1e3, PULSE.g(3,:)*1e3);
    xlabel('Time (ms)') 
    ylabel('G_z (mT/m)')
    xlim([0 time(range)*1e3])

end