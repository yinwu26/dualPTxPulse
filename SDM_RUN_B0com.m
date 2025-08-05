%--------------------------------------------------------------------------
% Spatial Domain Small Tip Angle Pulse Design
% Dual pTx pulse (P1P2) B0 compensation Version 1.0
%   1. Simultaneous P1 and P2 pulse design with enforced +-dB0/2 phase shift
%   2. Adjust subpulse durations
%   3. Optimize with new subpulse durations
%   4. Bloch simulation
%   
% NB: currently only single slice optimization
%--------------------------------------------------------------------------
clear all; close all;
addpath(genpath('_src'));
fprintf('\n============================\n');
fprintf('    SDM STA Pulse Design     ');
fprintf('\n============================\n');

%--------------------------------------------------------------------------
%% Input/Output filenames
%--------------------------------------------------------------------------
filePath    = '_input/sub001_MAPS.mat';

%--------------------------------------------------------------------------
%% Load Calibration Data
%--------------------------------------------------------------------------
load(filePath);

%--------------------------------------------------------------------------
%% Masks
%--------------------------------------------------------------------------
% remove edge noise in dB0map
MAPS.maskV1 = MAPS.mask;
SE = strel('disk',2);
MAPS.mask = imerode(MAPS.mask,SE); 

MAPS = applyMask(MAPS);

%--------------------------------------------------------------------------
%% Select single slice (reset parameters)
%--------------------------------------------------------------------------
[nRO, nPE, nPar, nCh] = size(MAPS.B1);

orientation_sli = 'tra';

MAPSorg = MAPS;

switch orientation_sli
    case 'tra'
        % Transverse
        pos   = 10;
        slice = (nPar/2)+round(pos/4);
        MAPS.slice = slice;
        MAPS.mask  = MAPS.mask(:,:,slice);
        MAPS.B1    = MAPS.B1(:,:,slice,:);
        MAPS.B0    = MAPS.B0(:,:,slice); 
        MAPS.PO    = MAPS.PO(:,:,:,slice);
    case 'sag'
        % Sagittal
        pos   = 4;
        slice = (nRO/2)+round(pos/4);
        MAPS.mask = MAPS.mask(slice,:,:); 
        MAPS.B1   = MAPS.B1(slice,:,:,:);
        MAPS.B0   = MAPS.B0(slice,:,:); 
        MAPS.PO   = MAPS.PO(:,slice,:,:);
    case 'cor'
        % Coronal
        pos   = 16;
        slice = (nPE/2)+round(pos/4);
        MAPS.mask = MAPS.mask(:,slice,:);
        MAPS.B1   = MAPS.B1(:,slice,:,:);
        MAPS.B0   = MAPS.B0(:,slice,:); 
        MAPS.PO   = MAPS.PO(:,:,slice,:);
end

%--------------------------------------------------------------------------
%% Pulse Optimisation Parameters
%--------------------------------------------------------------------------
PULSEDESIGN.pulseSets   = 2;
PULSEDESIGN.tikLambda   = 60.0e-7;                              % [a.u.] constrains b^2 NB: larger lambda decreases power

PULSEDESIGN.iterations  = 200;                                  % [a.u.]
PULSEDESIGN.optPulDur   = true;

%--------------------------------------------------------------------------
%% Pulse Parameters
%--------------------------------------------------------------------------
PULSEDESIGN.flipAngle   = deg2rad(1);                           % [rad]
PULSEDESIGN.nKpos       = 13;                                   % [a.u.] num of subpulses

PULSEDESIGN.subPulseDur = ones(PULSEDESIGN.nKpos, 1) * 100.0e-6;% [s] NB: only for B0 consideration
PULSEDESIGN.gradBlipDur = 70.0e-6;                              % [s]
% PULSEDESIGN.gradRampDur = 30.0e-6;
PULSEDESIGN.TR          = 15e-3;                                % [s] time between two pulse sets

PULSEDESIGN.refVoltage  = MAPS.refVolt;                         % [V]
PULSEDESIGN.dK          = 4;                                    % [1/m] ( should be about 16-25 cm ) not dependent on the FOV

%--------------------------------------------------------------------------
%% k-Space locations
%-------------------------------------------------------------------------
switch PULSEDESIGN.nKpos
    case 15
    PULSEDESIGN.kLoc = [0, 0, 0, 1,  0,  0, -1, 0, -1,  0,  0, 1, 0, 0, 0;
                        0, 0, 1, 0,  0, -1,  0, 0,  0, -1,  0, 0, 1, 0, 0;
                        0, 1, 0, 0, -1,  0,  0, 0,  0,  0, -1, 0, 0, 1, 0].*2;
    case 13
    PULSEDESIGN.kLoc = [0, 0, 0, 1,  0,  0, -1,  0,  0, 1, 0, 0, 0;
                        0, 0, 1, 0,  0, -1,  0, -1,  0, 0, 1, 0, 0;
                        0, 1, 0, 0, -1,  0,  0,  0, -1, 0, 0, 1, 0].*2;
    case 8
    PULSEDESIGN.kLoc = [0, 0, 0, 1,  0,  0, -1, 0;
                        0, 0, 1, 0,  0, -1,  0, 0;
                        0, 1, 0, 0, -1,  0,  0, 0].*2; % 0 z y x -z -y -x 0 (8 subpulses)
end
                
plotkSpaceTrajectory(PULSEDESIGN.kLoc);

PULSEDESIGN.kLoc        = PULSEDESIGN.kLoc*PULSEDESIGN.dK;      % [1/m]    
PULSEDESIGN.gradMoments = calcGradientMoment(PULSEDESIGN.kLoc); % [ms*uT/m]

%--------------------------------------------------------------------------
%% Define target maps
%--------------------------------------------------------------------------
[nX,nY,nZ,nC]      = size(MAPS.B1);
MAPS.targetMag     = sin(PULSEDESIGN.flipAngle) * MAPS.mask(:);
MAPS.initTargetPha = exp(1i.*angle(getCPmode(MAPS,true)));

% figure(); imshow(angle(getCPmode(MAPS,false)),[]);

%--------------------------------------------------------------------------
%% Setup dB0
%-------------------------------------------------------------------------
 MAPS.dB0map  = MAPS.B0 * 42.577e6 * 1;     % [T -> Hz]
dPhaseC      = MAPS.dB0map.*PULSEDESIGN.TR; % [Hz*s]
dPhaseC      = exp(-2i*pi*dPhaseC);

MAPS.dPhaseC = dPhaseC(:);

%--------------------------------------------------------------------------
%% Spatial Domain Method Optimization Single Pulse
%--------------------------------------------------------------------------
A = angle(MAPS.dPhaseC)/2;
MAPS.initTargetPha = MAPS.initTargetPha .* exp(-1i*A);

[b1, mT1, NRMSE1, target1] = spatialDomainMethod(PULSEDESIGN, MAPS);
% displaySDMmap2D(mT1, MAPS);

MAPS.initTargetPha = exp(1i.*angle(target1(:)));

%--------------------------------------------------------------------------
%% Spatial Domain Method Optimization
%--------------------------------------------------------------------------
tic;
[b, mT, ~, target] = spatialDomainMethod_2RF(PULSEDESIGN, MAPS);
SDMtime = toc;
disp(['SDMtime: ', num2str(SDMtime)]);

%--------------------------------------------------------------------------
%% generate RF and gradient pulse waveforms
%--------------------------------------------------------------------------
PULSEDESIGN.subPulseDur = ones(PULSEDESIGN.nKpos, 1) * 360.0e-6;

pulse = reshape(b, [PULSEDESIGN.nKpos*nC, PULSEDESIGN.pulseSets]);
PULSE1 = createRFandGradWaveForms(PULSEDESIGN, pulse(:,1), 10e-6);
PULSE2 = createRFandGradWaveForms(PULSEDESIGN, pulse(:,2), 10e-6);
displaysequence(PULSE1);
displaysequence(PULSE2);

totPowerBef1 = sum(abs(PULSE1.rf).^2,'all');
totPowerBef2 = sum(abs(PULSE2.rf).^2,'all');

%%-----------------------------------------------------------------------%%
%% Adjust subpulse durations (to lower RF power)
%%-----------------------------------------------------------------------%%
if PULSEDESIGN.optPulDur 
    PULSEDESIGN1 = optSubPulseDur(pulse(:,1), PULSEDESIGN, 90, 7); %7.5
    PULSEDESIGN2 = optSubPulseDur(pulse(:,2), PULSEDESIGN, 90, 7); %7.5
    
    %% Rerun optimization with updated variable pulse durations
    [b, mT, ~, target] = spatialDomainMethod_2RF(PULSEDESIGN, MAPS);
    pulse = reshape(b, [PULSEDESIGN.nKpos*nC, PULSEDESIGN.pulseSets]);
    PULSE1 = createRFandGradWaveForms(PULSEDESIGN1, pulse(:,1), 10e-6);
    PULSE2 = createRFandGradWaveForms(PULSEDESIGN2, pulse(:,2), 10e-6);    
    
    totPowerAft1 = sum(abs(PULSE1.rf).^2,'all'); % RF power 
    totPowerAft2 = sum(abs(PULSE2.rf).^2,'all');
    diff1 = ((totPowerBef1-totPowerAft1)/totPowerBef1)*100;
    diff2 = ((totPowerBef2-totPowerAft2)/totPowerBef2)*100;
    disp(['1 Total Power - Before: ', num2str(totPowerBef1), '  After: ', num2str(totPowerAft1)]);
    disp(['Percent change %: ', num2str(diff1)]);

    disp(['2 Total Power - Before: ', num2str(totPowerBef2), '  After: ', num2str(totPowerAft2)]);
    disp(['Percent change %: ', num2str(diff2)]);

    displaysequence(PULSE1);
    displaysequence(PULSE2);
end

%%-----------------------------------------------------------------------%%
%% show STA results
%%-----------------------------------------------------------------------%%
displaySDMmap2D(mT(:,:,:,1), MAPS);
displaySDMmap2D(mT(:,:,:,2), MAPS);

totPulDur = max(PULSE1.nTimeSteps,PULSE2.nTimeSteps)*10;
disp(['PULSE1 [us]: ', num2str(PULSE1.nTimeSteps*10), ' --- PULSE2 [us]: ', num2str(PULSE2.nTimeSteps*10)]);

%--------------------------------------------------------------------------
%% Run Bloch Simulation
%--------------------------------------------------------------------------
MAPS.T1       = 2.0;              % [s]
MAPS.T2       = 0.05;             % [s]
MAPS.flowRate = zeros(nX,nY,nZ);  % [m/s]

[mTFinal1, mZFinal1] = runBlochMEX(PULSE1, MAPS, PULSE1.nTimeSteps);
[mTFinal2, mZFinal2] = runBlochMEX(PULSE2, MAPS, PULSE2.nTimeSteps);
displayBlochMap2D(mTFinal1, mZFinal1, orientation_sli);
displayBlochMap2D(mTFinal2, mZFinal2, orientation_sli);

disp(['BlochNRMSE P1: ', num2str(getNRMSE(mTFinal1,target))]);
disp(['BlochNRMSE P2: ', num2str(getNRMSE(mTFinal2,target))]);
   
%--------------------------------------------------------------------------
%% match image to dicom orientation
%--------------------------------------------------------------------------
magT = flip(permute(mT, [3,2,1,4]),1);
tar  = flip(permute(target, [3,2,1,4]),1);

mTFinal1 = flip(permute(mTFinal1, [3,2,1,4]),1);
mTFinal2 = flip(permute(mTFinal2, [3,2,1,4]),1);

%%-----------------------------------------------------------------------%%
%% show STA results
%%-----------------------------------------------------------------------%%
magT1 = magT(:,:,:,1);
magT2 = magT(:,:,:,2);
switch orientation_sli
    case 'sag'
        nX = 2;
    case 'cor'
        nY = 2;
    case 'tra'
        nZ = 2;
end
top = 0.1;
figure(); sgtitle(['SDM Expected Transverse Magnetisation']);
subplot(4,3,1); imshow(squeeze(abs(magT1(:,nY/2,:))),[0 top]); colorbar; colormap parula;
title('Coronal'); ylabel('Pulse 1');
subplot(4,3,2); imshow(squeeze(abs(magT1(:,:,nX/2))),[0 top]); colorbar; colormap parula;
title('Sagittal');
subplot(4,3,3); imshow(squeeze(abs(magT1(nZ/2,:,:))),[0 top]); colorbar; colormap parula;
title('Transverse');

subplot(4,3,4); imshow(squeeze(angle(magT1(:,nY/2,:))),[-pi pi]); colorbar; colormap parula;
title('Coronal');
subplot(4,3,5); imshow(squeeze(angle(magT1(:,:,nX/2))),[-pi,pi]); colorbar; colormap parula;
title('Sagittal');
subplot(4,3,6); imshow(squeeze(angle(magT1(nZ/2,:,:))),[-pi,pi]); colorbar; colormap parula;
title('Transverse');

subplot(4,3,7); imshow(squeeze(abs(magT2(:,nY/2,:))),[0 top]); colorbar; colormap parula;
title('Coronal'); ylabel('Pulse 2');
subplot(4,3,8); imshow(squeeze(abs(magT2(:,:,nX/2))),[0 top]); colorbar; colormap parula;
title('Sagittal');
subplot(4,3,9); imshow(squeeze(abs(magT2(nZ/2,:,:))),[0 top]); colorbar; colormap parula;
title('Transverse');

subplot(4,3,10); imshow(squeeze(angle(magT2(:,nY/2,:))),[-pi pi]); colorbar; colormap parula;
title('Coronal');
subplot(4,3,11); imshow(squeeze(angle(magT2(:,:,nX/2))),[-pi,pi]); colorbar; colormap parula;
title('Sagittal');
subplot(4,3,12); imshow(squeeze(angle(magT2(nZ/2,:,:))),[-pi,pi]); colorbar; colormap parula;
title('Transverse');

%%
mTPhaDiff  = rad2deg(angle(exp(1i*angle(magT2)).* conj(exp(1i*angle(magT1)))));
BlochDiff  = rad2deg(angle(exp(1i*angle(mTFinal2)).* conj(exp(1i*angle(mTFinal1)))));
tarPhaDiff = rad2deg(angle(exp(1i*angle(tar(:,:,:,2))) .* conj(exp(1i*angle(tar(:,:,:,1))))));

val = 180;
figure(); sgtitle(['Phase Difference']);
subplot(3,3,1); imshow(squeeze(mTPhaDiff(:,nY/2,:)),[-val val]); colorbar; colormap parula;
title('Coronal'); ylabel('SDM');
subplot(3,3,2); imshow(squeeze(mTPhaDiff(:,:,nX/2)),[-val val]); colorbar; colormap parula;
title('Sagittal');
subplot(3,3,3); imshow(squeeze(mTPhaDiff(nZ/2,:,:)),[-val val]); colorbar; colormap parula;
title('Transverse');

subplot(3,3,4); imshow(squeeze(BlochDiff(:,nY/2,:)),[-val val]); colorbar; colormap parula;
title('Coronal'); ylabel('Bloch');
subplot(3,3,5); imshow(squeeze(BlochDiff(:,:,nX/2)),[-val val]); colorbar; colormap parula;
title('Sagittal');
subplot(3,3,6); imshow(squeeze(BlochDiff(nZ/2,:,:)),[-val val]); colorbar; colormap parula;
title('Transverse');

subplot(3,3,7); imshow(squeeze(tarPhaDiff(:,nY/2,:)),[-val val]); colorbar; colormap parula;
title('Coronal'); ylabel('Target');
subplot(3,3,8); imshow(squeeze(tarPhaDiff(:,:,nX/2)),[-val val]); colorbar; colormap parula;
title('Sagittal');
subplot(3,3,9); imshow(squeeze(tarPhaDiff(nZ/2,:,:)),[-val val]); colorbar; colormap parula;
title('Transverse');

%--------------------------------------------------------------------------
%% Save Results
%--------------------------------------------------------------------------
if ~exist('_results', 'dir')
       mkdir('_out');
end

PULSE1.nPulseChannel = reshape(pulse(:,1), [PULSEDESIGN.nKpos, nC]);
PULSE2.nPulseChannel = reshape(pulse(:,2), [PULSEDESIGN.nKpos, nC]);

% save results for Bloch Simulator
MATname  = ['_out/PULSE_B0_TR',num2str(PULSEDESIGN.TR*1000),...
            '_',num2str(PULSEDESIGN.nKpos),'kT.mat'];
save(MATname, 'PULSE1', 'PULSE2');

%--------------------------------------------------------------------------
%% Create Pulse Binary File 
%--------------------------------------------------------------------------
% Pulse binary files
PTXRFQ_A1 = './_out/PTXRFQ_P1.double'; PTXGRQ_A1 = './_out/PTXGRQ_P1.double';
PTXRFQ_A2 = './_out/PTXRFQ_P2.double'; PTXGRQ_A2 = './_out/PTXGRQ_P2.double';

%% Create/Save RF and gradient pulse files
% Scale RF pulses
[RFpulses, ~] = normRFpulses(b, PULSEDESIGN, MAPS.refVolt);

create_PulseFile(PTXRFQ_A1, PTXGRQ_A1, RFpulses(:,:,1), PULSEDESIGN, MAPS);
create_PulseFile(PTXRFQ_A2, PTXGRQ_A2, RFpulses(:,:,2), PULSEDESIGN, MAPS);

%% ------------------------------------------------------------------------
rmpath(genpath('_src'));

