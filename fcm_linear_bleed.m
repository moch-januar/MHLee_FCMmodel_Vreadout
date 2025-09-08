function dec_lin = fcm_linear_bleed(t, t0, Ibleed, Cref, u)
%% Linear decay due to bleed current Ibleed through Cref
   dec_lin = -(Ibleed/Cref) * (t - t0) .* u(t - t0);
end