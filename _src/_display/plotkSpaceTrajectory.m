function plotkSpaceTrajectory(kLoc)
    figure();  
    plot3(kLoc(1,:), kLoc(2,:), kLoc(3,:)); hold on;
    plot3(kLoc(1,:), kLoc(2,:), kLoc(3,:), 'bo');
    
    title('k-Space Trajectory');
    xlabel('k_x'); 
    ylabel('k_y'); 
    zlabel('k_z');
    grid on;
    
end