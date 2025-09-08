
function fcm_print_readout(read, t_read)
   fprintf('Read values at t = %.2f ms:\n', t_read*1e3);
   for i = 1:numel(read.vs)
       fprintf('  state %s: %.3f V\n', read.labs{i}, read.vs(i));
   end
   fprintf('Suggested thresholds:\n');
   for i = 1:numel(read.th)
       fprintf('  T%d = %.3f V (between %s and %s)\n', ...
           i, read.th(i), read.labs{i}, read.labs{i+1});
   end
end