function Vo = fcm_simulate_states(cfg, t, C, Cref, VR, t0, shape, dec_lin, tauRC, u)
%% For each state capacitance C(k), compute Vo(t)
   N  = numel(C);
   Vo = zeros(N, numel(t));
   for k = 1:N

     % inside fcm_simulate_states (or before computing Vo0k):
       Vo0k = cfg.eta * (C(k)/Cref) * VR;   % scaled jump
       VoJk = Vo0k * shape;               % jump waveform
       
       if isfinite(tauRC)
           dec_rc_k = (Vo0k*(exp(-(t - t0)/tauRC) - 1)) .* u(t - t0);
       else
           dec_rc_k = 0;
       end
       Vo(k,:) = max(VoJk + dec_lin + dec_rc_k, 0); % clip at 0 for display
   end
end
