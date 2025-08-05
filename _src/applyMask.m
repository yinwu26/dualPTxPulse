function MAPS = applyMask(MAPS)
    MAPS.B1 = MAPS.B1(:,:,:,1:end).*MAPS.mask;
    MAPS.B0 = MAPS.B0.*MAPS.mask;
end