function VR_t = fcm_precharge_pulse(t, VR, t_pre, t0)
%% Pre-charge pulse active only between t_pre and t0
   VR_t = VR * (t >= t_pre & t <= t0);
end
