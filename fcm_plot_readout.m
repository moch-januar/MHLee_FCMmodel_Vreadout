

function fcm_plot_readout(t, VR_t, Vo, labels, read)
%% PLOTTING RESULTS
 % ------------------------------------------------------------------------
   JanColor = [0,0.43,1; 1,0.075,0.075; 1,0.75,0; 0,0.75,0.75; 0.75,0,0.75; 1,0.15,0.65; 0,0.05,1; 0.15,0.15,0.15; 0.6,0.2,0.12; 0.9,0.53,0.1];
   JanFS = 14;
 % ------------------------------------------------------------------------
   figure('DefaultAxesFontSize',JanFS-2); set(gcf,'Position',[40 40 600 350],'color','w');
   tile = tiledlayout(1,3); tile.Padding = 'tight'; tile.TileSpacing = 'compact';
   set(groot,'defaultAxesColorOrder',JanColor);
   set(0,'DefaultAxesFontName','CMU Serif','defaultTextFontName','CMU Serif');
 % ------------------------------------------------------------------------
   co = lines(size(Vo,1));
   plot(t*1e3, VR_t, 'k:','LineWidth',2.5,'DisplayName','V_R (pre-charge)'); hold on;
   for k = 1:size(Vo,1)
       plot(t*1e3, Vo(k,:), 'LineWidth',2.8, 'Color', co(k,:), ...
           'DisplayName', sprintf('V_o (state %s)', labels{k}));
   end
 % Mark read instant & levels
   plot(read.t_read*1e3, read.vs, 'o', 'MarkerFaceColor','b', ...
       'MarkerEdgeColor','b','MarkerSize',7,'HandleVisibility','off');
 % Draw suggested thresholds
   for i = 1:numel(read.th)
       yline(read.th(i),'--','Color',[0.5 0.5 0.5],'HandleVisibility','off');
   end
   xlabel('Time [ms]','FontSize',JanFS+0.5,'FontWeight','bold');
   ylabel('Voltage [V]','FontSize',JanFS+0.5,'FontWeight','bold');
   set(gca,'FontSize',13,'FontWeight','bold','TickDir','in');
   title('FCM Readout: Multi-level states');
   subtitle('(pre-charge \rightarrow read \rightarrow discharge)');
   legend('Location','eastoutside'); legend boxoff;
   xlim([0, max(t)*1e3]); ylim([0, max(1.2, 1.1*max(Vo(:)) )]);
   grid on;
end
