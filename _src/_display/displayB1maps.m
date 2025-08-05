function displayB1maps(MAPS)

    TxB1maps = flip(permute(MAPS.B1.*MAPS.mask, [3,2,1,4]),1);

    figure(); sgtitle('nTx B1 maps');
    for ii=1:8
        subplot(3,3,ii); imshow(squeeze(abs(TxB1maps(29,:,:,ii))), []); colormap parula; 
    end

end