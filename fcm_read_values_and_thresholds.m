function read = fcm_read_values_and_thresholds(t, Vo, labels, t_read)
%% Sample Vo at t_read, sort levels, compute suggested thresholds
   vread = interp1(t, Vo.', t_read, 'linear', 'extrap').';  % N x 1
   [vs, idx]   = sort(vread, 'descend');
   labs        = labels(idx);
   th          = (vs(1:end-1) + vs(2:end))/2;
   read.t_read = t_read;
   read.vread  = vread;
   read.vs     = vs;
   read.idx    = idx;
   read.labs   = labs;
   read.th     = th;
end