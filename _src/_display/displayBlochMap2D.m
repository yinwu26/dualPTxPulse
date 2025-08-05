function displayBlochMap2D(mT, mZ, orientation)
    
    %% match image to dicom orientation
    mT = flip(permute(mT, [3,2,1]),1);
    mZ = flip(permute(mZ, [3,2,1]),1);
    
    FA = asind(abs(mT)./sqrt(abs(mT).^2 + mZ.^2));
    
    [nZ,nY,nX] = size(mT);
    
    switch orientation
        case 'sag'
            nX = 2;
        case 'cor'
            nY = 2;
        case 'tra'
            nZ = 2;
    end
    
    figure(); sgtitle(['BlochSim Expected Profiles']);
    subplot(4,3,1); imshow(squeeze(abs(mT(:,nY/2,:))), []); colorbar; colormap parula;
    title('Coronal'); ylabel('M_T');
    subplot(4,3,2); imshow(squeeze(abs(mT(:,:,nX/2))), []); colorbar; colormap parula;
    title('Sagittal');
    subplot(4,3,3); imshow(squeeze(abs(mT(nZ/2,:,:))), []); colorbar; colormap parula;
    title('Transverse');

    %
    subplot(4,3,4); imshow(squeeze(angle(mT(:,nY/2,:))), [-pi pi]); colorbar; colormap parula;
    title('Coronal'); ylabel('phase');
    subplot(4,3,5); imshow(squeeze(angle(mT(:,:,nX/2))), [-pi pi]); colorbar; colormap parula;
    title('Sagittal');
    subplot(4,3,6); imshow(squeeze(angle(mT(nZ/2,:,:))), [-pi pi]); colorbar; colormap parula;
    title('Transverse');

    subplot(4,3,7); imshow(squeeze(mZ(:,nY/2,:)), []); colorbar; colormap parula;
    title('Coronal'); ylabel('M_Z');
    subplot(4,3,8); imshow(squeeze(mZ(:,:,nX/2)), []); colorbar; colormap parula;
    title('Sagittal');
    subplot(4,3,9); imshow(squeeze(mZ(nZ/2,:,:)), []); colorbar; colormap parula;
    title('Transverse');

    % Plot the FA maps
    top = 30;
%     figure(); sgtitle(['BlochSim FAmap']);
    subplot(4,3,10); imshow(squeeze(abs(FA(:,nY/2,:))), [0 top]); colorbar; colormap parula;
    title('Coronal'); 
    subplot(4,3,11); imshow(squeeze(abs(FA(:,:,nX/2))), [0 top]); colorbar; colormap parula;
    title('Sagittal');
    subplot(4,3,12); imshow(squeeze(abs(FA(nZ/2,:,:))), [0 top]); colorbar; colormap parula;
    title('Transverse');
    
%     figure(); imshow(squeeze(abs(FA(nZ/2,:,:))), [0 top]); colorbar; colormap parula;
end