%% FCM readout: Multi-level (M-state) model — modular version
   clear; clc; close all;

 % ===== Define M states by capacitance density (uF/cm^2) =====
   setModel = "ourData";
   switch setModel
       case "ourData"
           cfg.A_cm2  = 2.1e-4;                      % [um^2]
           CFCM            = [33, 106, 210, 316];    % [pF]
           cfg.Cdens_uFcm2 = CFCM*1e-6/cfg.A_cm2;    % [uF/cm^2]
           cfg.Cref   = 12e-12;                      % [F]
           cfg.RL     = inf;                         % [ohm] set Inf for pure linear discharge
           cfg.Ibleed = 10e-9;                      % [A] bleed current -> linear slope ~ Ibleed/Cref
           cfg.t_end  = 2.750e-3;
           cfg.dt     = 0.5e-6;
           cfg.eta    = 0.16; % fit once from one measured point
       case "NUS"
           cfg.A_cm2  = 2.2e-5;                      % [um^2]
           cfg.Cdens_uFcm2 = [0.02 0.30 0.68 1.00];  % [uF/cm^2]
           cfg.Cref   = 10e-12;                      % [F]
           cfg.RL     = inf;                         % [ohm] set Inf for pure linear discharge
           cfg.Ibleed = 18e-9;                       % [A] bleed current -> linear slope ~ Ibleed/Cref
           cfg.t_end  = 0.70e-3;
           cfg.dt     = 0.5e-6;
           cfg.eta    = 1; % fit once from one measured point
   end
   cfg.labels = {'00','01','10','11'};    % same length as Cdens_uFcm2
   cfg.A_um2  = cfg.A_cm2 * 1e8;               % [cm^2]
   cfg.A      = cfg.A_um2 * 1e-12;             % [m^2]

 % Convert to absolute capacitance
   [Cdens, C] = fcm_capacitance_from_density(cfg.Cdens_uFcm2, cfg.A);
   cfg.Cdens  = Cdens;                         % [F/m^2]
   cfg.C      = C;                             % [F]

 % ===== Readout network =====
   cfg.tauRC  = cfg.RL * cfg.Cref;             % [s]

 % ===== Timing =====
   cfg.VR    = 0.5;                            % [V] pre-charge level
   cfg.t_pre = 0.01e-3;                        % [s] start of pre-charge pulse
   cfg.t0    = 0.12e-3;                        % [s] connect FCM to charge amp (read)
   cfg.t_set = 8e-6;                           % [s] settling time of the jump

 % ===== Time axis =====
   [t, ufun] = fcm_time_axis(cfg.t_end, cfg.dt);

 % ===== Pre-charge pulse (only between t_pre and t0) =====
   VR_t = fcm_precharge_pulse(t, cfg.VR, cfg.t_pre, cfg.t0);

 % ===== Common waveforms =====
   shape   = fcm_jump_shape(t, cfg.t0, cfg.t_set, ufun);                   % jump shape
   dec_lin = fcm_linear_bleed(t, cfg.t0, cfg.Ibleed, cfg.Cref, ufun);      % linear bleed

 % ===== Build Vo(t) for each state =====
   Vo = fcm_simulate_states(cfg, t, cfg.C, cfg.Cref, cfg.VR, cfg.t0, shape, dec_lin, cfg.tauRC, ufun);

 % ===== Read at a fixed time & thresholds =====
   t_read = 0.15e-3;                                                       % [s]
   read   = fcm_read_values_and_thresholds(t, Vo, cfg.labels, t_read);

 % ===== Plot & print =====
   fcm_plot_readout(t, VR_t, Vo, cfg.labels, read);
   fcm_print_readout(read, t_read);

