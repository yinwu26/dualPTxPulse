function [mTFinal, mZFinal] = runBlochMEX(PULSE, MAPS, nTimeSteps)
    tic;
    [nX,nY,nZ,~] = size(MAPS.B1);

    %% Setup input arguments
    % set voxel spatial positions    
    X = MAPS.PO(1,:);
    Y = MAPS.PO(2,:);
    Z = MAPS.PO(3,:);
    
    M0 = [0,0,1];
    
    % pulse sequence
    RF = permute(complex(PULSE.rf(:,1:nTimeSteps)), [2,1]);
    
    Gx = PULSE.g(1,1:nTimeSteps);
    Gy = PULSE.g(2,1:nTimeSteps);
    Gz = PULSE.g(3,1:nTimeSteps);
    
    % B1map and B0 input
    B1 = permute(MAPS.B1,[4,1,2,3]); % [nTx, x, y, z]
    B1 = complex(double(B1(:)));
    B0 = double(MAPS.B0(:));
    
    flow = MAPS.flowRate(:);

    %% Bloch_FLOW_MEX (C++ function)
    % NOTE: B1map and rfPulse input must be complex double!
    [mX,  mY,  mZ] = Bloch_FLOW_MEX(X, Y, Z, M0, PULSE.dt, RF, Gx, Gy, Gz, B1, B0, MAPS.T1, MAPS.T2, flow);
    
    %% Output Magnetisation
    mT = mX - 1i*mY; % transverse magnetisation
    
    % reshape into volume
    mTFinal = reshape(mT, nX,nY,nZ);
    mZFinal = reshape(mZ, nX,nY,nZ);
    
    simTime = toc;
    display(simTime);
    
%% Bloch_FLOW_MEX function
%  [mX,  mY,  mZ] = Bloch_FLOW_MEX(XX, YY, ZZ, M0, dt, rf, Gx, Gy, Gz, B1map, B0map, T2, flow)

% INPUT
%     XX: x coordinate of the proton in [metre]
%     YY: y coordinate of the proton in [metre]
%     ZZ: z coordinate of the proton in [metre]
%     M0: in form of a vector [Mx, My, Mz] describing the magnetization at the beginning of the simulation
%     dt: delta_t in [second]
%     rf: a vector of B1 over time, needs to be complex double 
%     Gx: a vector of Gx over time, needs to be on the same raster time as rf. 
%     Gy: a vector of Gy over time, needs to be on the same raster time as rf.
%     Gz: a vector of Gz over time, needs to be on the same raster time as rf.
%     B1map: transmit field map
%     B0map: off resonance in [Hz]
%     T2: T2 relaxation time in [second]
%     flow: flowrate [m/s]


% OUTPUT
%     mX: resulting Mx at end of time series
%     mY: resulting My at end of time series
%     mZ: resulting Mz at end of time series
