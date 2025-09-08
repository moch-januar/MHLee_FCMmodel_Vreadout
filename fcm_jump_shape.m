function shape = fcm_jump_shape(t, t0, t_set, u)
%% Exponential settle after t0 with time-constant t_set
   shape = (1 - exp(-(t - t0)/max(t_set, eps))) .* u(t - t0);
end
