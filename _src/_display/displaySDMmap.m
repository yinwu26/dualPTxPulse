function displaySDMmap(magT, MAPS)

    %% match image to DICOM orientation
    magT = magT.*MAPS.mask;
    magT = flip(permute(magT,[3,2,1]),1);
    
    [nZ,nY,nX] = size(magT);

    figure(); sgtitle(['SDM Expected Excitation Profiles']);
    subplot(3,3,1); imshow(squeeze(abs(magT(:,nY/2,:))),[]); colorbar;
    title('Coronal'); ylabel('|M_T|');
    subplot(3,3,2); imshow(squeeze(abs(magT(:,:,nX/2))),[]); colorbar;
    title('Sagittal');
    subplot(3,3,3); imshow(squeeze(abs(magT(nZ/2,:,:))),[]); colorbar;
    title('Transverse');

    subplot(3,3,4); imshow(squeeze(angle(magT(:,nY/2,:))),[-pi pi]); colorbar;
    title('Coronal'); ylabel('\angle M_T');
    subplot(3,3,5); imshow(squeeze(angle(magT(:,:,nX/2))),[-pi,pi]); colorbar;
    title('Sagittal');
    subplot(3,3,6); imshow(squeeze(angle(magT(nZ/2,:,:))),[-pi,pi]); colorbar;
    title('Transverse');

    FA = asind(abs(magT));
    subplot(3,3,7); imshow(squeeze(abs(FA(:,nY/2,:))),[0 2]); colorbar;
    title('Coronal'); ylabel('Flip Angle');
    subplot(3,3,8); imshow(squeeze(abs(FA(:,:,nX/2))),[0 2]); colorbar;
    title('Sagittal');
    subplot(3,3,9); imshow(squeeze(abs(FA(nZ/2,:,:))),[0 2]); colorbar;
    title('Transverse');

    colormap parula;
end