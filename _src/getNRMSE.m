function [NRMSE] = getNRMSE(sol,target)
    NRMSE = sqrt(sum((abs(sol)-abs(target)).^2, 'all')/sum(abs(target).^2, 'all'));
    NRMSE = sqrt(sum((abs(sol)-abs(target)).^2, 'all')/sum(abs(target).^2, 'all'));
end