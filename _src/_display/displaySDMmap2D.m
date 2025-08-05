function displaySDMmap2D(magT, MAPS)

    %% match image to DICOM orientation
    magT = magT.*MAPS.mask;
    magT = flip(permute(magT,[3,2,1]),1);
   
    
    figure(); sgtitle(['SDM Expected Excitation Profiles']);
    subplot(1,3,1); imshow(squeeze(abs(magT)),[]); colorbar;
    title(''); title('|M_T|');

    subplot(1,3,2); imshow(squeeze(angle(magT)),[-pi pi]); colorbar;
    title(''); title('\angle M_T');

    FA = asind(abs(magT));
    subplot(1,3,3); imshow(squeeze(abs(FA)),[0 2]); colorbar;
    title(''); title('Flip Angle');

    colormap parula;
end