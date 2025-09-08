function [Cdens, C] = fcm_capacitance_from_density(Cdens_uFcm2, A)
%% Convert uF/cm^2 -> F/m^2, then to absolute [F]
   Cdens = Cdens_uFcm2 * 1e-6 / 1e-4;  % [F/m^2]
   C     = Cdens * A;                  % [F]
end

