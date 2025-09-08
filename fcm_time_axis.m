function [t, ufun] = fcm_time_axis(t_end, dt)
%% Build time axis and a unit-step function handle
   t    = 0:dt:t_end;
   ufun = @(x) double(x >= 0);
end
