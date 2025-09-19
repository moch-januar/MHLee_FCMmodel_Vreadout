%% FCM_readout_Crefs.m
 % Sweep reference capacitance (Cref) and visualize readout behavior.
 % Relies on helper functions you already separated:
 %   fcm_capacitance_from_density, fcm_time_axis, fcm_precharge_pulse,
 %   fcm_jump_shape, fcm_linear_bleed, fcm_simulate_states,
 %   fcm_read_values_and_thresholds

   clear; clc; close all;

% ===== Define M states by capacitance density (uF/cm^2) =====
   setModel = "ourData";
   switch setModel
       case "ourData"
           cfg.A_um2  = 700*300;                     % [um^2]
           cfg.A_cm2  = cfg.A_um2*1e-8;               % [cm^2]
           CFCM            = [33, 106, 210, 316]+300;    % [pF]
           G               = 500;
           cfg.Cdens_uFcm2 = CFCM*1e-6/cfg.A_cm2;    % [uF/cm^2]
           cfg.Cref   = 12e-9;                       % [F]
           cfg.RL     = inf;                         % [ohm] set Inf for pure linear discharge
           cfg.Ibleed = 1.9e-11;                      % [A] bleed current -> linear slope ~ Ibleed/Cref
           cfg.t_end  = 2.750;
           cfg.dt     = 0.08;
           cfg.eta    = 0.45; % fit once from one measured point
           cfg.VR     = 0.2;                         % [V] pre-charge level
           cfg.t_pre  = 0.01;                        % [s] start of pre-charge pulse
           cfg.t0     = 0.12;                        % [s] connect FCM to charge amp (read)
           cfg.t_set  = 8e-3;                        % [s] settling time of the jump
           unitFact   = 1;
           tAxeLabel  = 'Time [s]';
         % ===== Sweep settings =====
           Cref_vec = logspace(-11.4, -10.8, 24)*1e3; % [F] ~ 1 pF → 100 pF
           t_read   = 0.3;                          % [s] read moment
       case "NUS"
           cfg.A_cm2  = 2.2e-5;                      % [um^2]
           cfg.Cdens_uFcm2 = [0.02 0.30 0.68 1.00];  % [uF/cm^2]
           cfg.Cref   = 10e-12;                      % [F]
           cfg.RL     = inf;                         % [ohm] set Inf for pure linear discharge
           cfg.Ibleed = 18e-9;                       % [A] bleed current -> linear slope ~ Ibleed/Cref
           cfg.t_end  = 0.70e-3;
           cfg.dt     = 0.5e-6;
           cfg.eta    = 1; % fit once from one measured point
           cfg.VR     = 0.5;                         % [V] pre-charge level
           cfg.t_pre  = 0.01e-3;                     % [s] start of pre-charge pulse
           cfg.t0     = 0.12e-3;                     % [s] connect FCM to charge amp (read)
           cfg.t_set  = 8e-6;                        % [s] settling time of the jump
           unitFact   = 1e3;
           tAxeLabel  = 'Time [ms]';
         % ===== Sweep settings =====
           Cref_vec = logspace(-11.4, -10.8, 25); % [F] ~ 1 pF → 100 pF
           t_read   = 0.15e-3;                          % [s] read moment
   end
   cfg.labels = {'00','01','10','11'};       % same length as Cdens_uFcm2
   cfg.A_um2  = cfg.A_cm2 * 1e8;             % [cm^2]
   cfg.A      = cfg.A_um2 * 1e-12;           % [m^2]

 % Convert to absolute capacitance
   [Cdens, C] = fcm_capacitance_from_density(cfg.Cdens_uFcm2, cfg.A);
   cfg.Cdens  = Cdens;                       % [F/m^2]
   cfg.C      = C;                           % [F]

 % ===== Time axis =====
   [t, ufun] = fcm_time_axis(cfg.t_end, cfg.dt);

 % ===== Common waveforms (independent of Cref) =====
   VR_t  = fcm_precharge_pulse(t, cfg.VR, cfg.t_pre, cfg.t0);
   shape = fcm_jump_shape(t, cfg.t0, cfg.t_set, ufun);

 % ===== Storage =====
   Nstate    = numel(cfg.C);
   Nref      = numel(Cref_vec);
   Vread_mat = nan(Nstate, Nref);         % per-state read voltage vs Cref
   minSep    = nan(1, Nref);              % min adjacent separation at t_read
   co        = lines(Nstate);             % consistent colors across figures

% ===== Sweep Cref =====
for j = 1:Nref
    Cref_j  = Cref_vec(j);
    tauRC_j = cfg.RL * Cref_j;            % [s]
    dec_lin = fcm_linear_bleed(t, cfg.t0, cfg.Ibleed, Cref_j, ufun);

    Vo_j    = fcm_simulate_states(cfg, t, cfg.C, Cref_j, cfg.VR, cfg.t0, shape, dec_lin, tauRC_j, ufun, G);
    read_j  = fcm_read_values_and_thresholds(t, Vo_j, cfg.labels, t_read);

  % store unsorted per-state values at t_read
    vread_unsorted  = interp1(t, Vo_j.', t_read, 'linear', 'extrap').';  % N x 1
    Vread_mat(:, j) = vread_unsorted(:);

  % min adjacent separation (sorted by level at t_read)
    if Nstate >= 2
        diffs     = diff(sort(vread_unsorted,'descend'));
        minSep(j) = min(abs(diffs));
    else
        minSep(j) = NaN;
    end
end

%% Figure 1: Time-domain examples for three Cref values
 % --- pick a custom example (3rd position) ---
   idx_custom  = 20;          % <-- change this as you like
 % Build: [small, mid, custom, large]
   mid = round((Nref+1)/2);
   idx_examples = [1, mid, idx_custom, Nref];
 % Avoid duplicates by nudging the custom slot if it collides
   if idx_examples(3) == idx_examples(2), idx_examples(3) = min(idx_examples(3)+1, Nref); end
   if idx_examples(3) == idx_examples(4), idx_examples(3) = max(idx_examples(3)-1, 1);    end

   figure('Color','w','Position',[60 410 900 320]);
   tiledlayout(1, numel(idx_examples), 'TileSpacing','none','Padding','compact');
   for ii = 2:numel(idx_examples)
       j  = idx_examples(ii);
       Cref_j  = Cref_vec(j);
       tauRC_j = cfg.RL * Cref_j;
       dec_lin = fcm_linear_bleed(t, cfg.t0, cfg.Ibleed, Cref_j, ufun);
       Vo_j    = fcm_simulate_states(cfg, t, cfg.C, Cref_j, cfg.VR, cfg.t0, shape, dec_lin, tauRC_j, ufun, G);

       nexttile; 
           plot(t*unitFact, VR_t, 'k:','LineWidth',2, 'DisplayName','V_R');  hold on; box on; 
           for k = 1:Nstate
               plot(t*unitFact, Vo_j(k,:), 'LineWidth', 2.0, 'Color', co(k,:), ...
                   'DisplayName', sprintf('V_o (%s)', cfg.labels{k}));
           end
         % read markers
           vread_j = interp1(t, Vo_j.', t_read, 'linear','extrap').';
           plot(t_read*unitFact, vread_j, 'o', 'MarkerFaceColor','b', 'MarkerEdgeColor','b', ...
               'MarkerSize', 6, 'HandleVisibility','off');
           title(sprintf('@C_{ref} = %.0f nF', Cref_j*1e9));
           xlabel(tAxeLabel,'FontSize',14.5,'FontWeight','bold');
           if ii==2 
               ylabel('Voltage [V]','FontSize',14.5,'FontWeight','bold');
               set(gca, 'FontSize',13,'FontWeight','bold','TickDir','in');
           else
               set(gca, 'FontSize',13,'FontWeight','bold','TickDir','in','YTick',[]);
           end
           xlim([-0.2, max(t)*unitFact]); ylim([0.001, 3.4])
           if ii==numel(idx_examples), legend('Location','eastoutside'); legend boxoff; end
   end

%% Figure 2: Readout vs Cref + Level margin
   figure('Color','w','Position',[60 10 600 320]);
   tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
 % Left: Vread vs Cref (per state)
   nexttile; hold on; box on; axis padded
   for k = 1:Nstate
       semilogx(Cref_vec*1e9, Vread_mat(k,:), 'LineWidth', 2.2, 'Color', co(k,:), ...
                'DisplayName', sprintf('state %s', cfg.labels{k}));
   end
   xlabel('C_{ref} [nF]','FontSize',14.5,'FontWeight','bold');
   ylabel(sprintf('V_o at t=%.2f s [V]', t_read),'FontSize',14.5,'FontWeight','bold');
   set(gca, 'FontSize',13,'FontWeight','bold','TickDir','in');
   title('Readout vs C_{ref}');
   grid on; legend('Location','best'); legend boxoff;
 % Right: minimum adjacent separation at t_read
   nexttile;
   plot(Cref_vec*1e12, minSep, 'LineWidth', 2.2); box on; grid on;
   xlabel('C_{ref} [nF]','FontSize',14.5,'FontWeight','bold');
   ylabel('Min. adj. distance @t_{read} [V]','FontSize',14.5,'FontWeight','bold');
   set(gca, 'FontSize',13,'FontWeight','bold','TickDir','in');
   title('Level margin vs C_{ref}');   

%% Figure 3 (optional): Heatmap of Vread vs state & Cref
   figure('Color','w','Position',[800 10 360 320]);
   imagesc(Cref_vec*1e12, 1:Nstate, Vread_mat); box on
   axis xy; colormap jet; colorbar;
   set(gca,'YTick',1:Nstate,'YTickLabel',cfg.labels);
   xlabel('C_{ref} [pF]','FontSize',14.5,'FontWeight','bold');
   ylabel('State','FontSize',14.5,'FontWeight','bold');
   set(gca,'FontSize',13,'FontWeight','bold','TickDir','in');
   title(sprintf('V_o at t=%.2f ms [V]', t_read*1e3));

%% Print a quick suggestion based on margin
   [~, bestIdx] = max(minSep);
   fprintf('Suggested Cref for best margin at t=%.2f ms: %.3g F (min Δ=%.3f V)\n', ...
       t_read*1e-3*1e3, Cref_vec(bestIdx), minSep(bestIdx));
