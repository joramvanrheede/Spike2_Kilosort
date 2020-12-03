
function visualise_coupling_diff(expt, example_trial, example_units)
% function visualise_coupling_diff(expt, example_trial, example_units)

% expt            = matched_ChR2_ArchT(5) % 5 is good example - NB117_190808

% example_trial  	= 18; % 9? 10? 11! 18!

if nargin < 2
    % Set trial #2 as default, to eliminate any particularly large effects in first trial
    example_trial   = 2;
end

if nargin < 3
    % If no target units are specified, default to 'all'
    target_units = ':'; 
end

% target_units    = [5 6 9 10 11];

%% These values are specific to this set of protocols:

baseline_win    = [0 4];
target_win      = [5.1 9.1];

trial_win       = [0 15];
min_rate        = 0.1;

%% hardcoded defaults

xcorr_max_lag  	= 1;
n_shuffles      = 10;

bin_size        = 0.01;
bin_vec         = 0:bin_size:(1500*bin_size);
bin_vec         = bin_vec(1:end-1);

%%

spikes          = expt.cortex_spikes;
binned_spikes   = expt.cortex_binned_spikes;

spike_rates     = spike_rate_by_channel(spikes, trial_win);
q_spike_rate    = spike_rates >= min_rate;

%% 
baseline_bins   = bin_vec >= baseline_win(1) & bin_vec < baseline_win(2);
target_bins     = bin_vec >= target_win(1) & bin_vec < target_win(2); 

baseline_vec    = bin_vec(baseline_bins); 
target_vec      = bin_vec(target_bins);



%% paired measure, delta measure, cum plot, paired correlation comparison? correlation matrix? 

spikes                  = spikes(q_spike_rate,:,:);
binned_spikes           = binned_spikes(q_spike_rate,:,:);

raster_spikes           = spikes(target_units,:,:);
raster_binned_spikes    = binned_spikes(target_units,:,:);
binary_binned_spikes    = raster_binned_spikes > 0;

baseline_spikes      	= raster_spikes(:,example_trial,:);
baseline_spikes         = baseline_spikes - baseline_win(1);

target_spikes           = raster_spikes(:,example_trial,:);
target_spikes           = target_spikes - target_win(1);

baseline_binned_spikes  = binary_binned_spikes(:,example_trial,baseline_bins);
target_binned_spikes  	= binary_binned_spikes(:,example_trial,target_bins);

baseline_bin_profile    = squeeze(baseline_binned_spikes);
baseline_bin_profile    = smoothdata(baseline_bin_profile, 2, 'movmean',3);
baseline_bin_profile    = baseline_bin_profile > 0;
baseline_bin_profile    = sum(baseline_bin_profile);

target_bin_profile      = squeeze(target_binned_spikes);
target_bin_profile      = smoothdata(target_bin_profile, 2, 'movmean',3);
target_bin_profile      = target_bin_profile > 0;
target_bin_profile      = sum(target_bin_profile);

%%

[baseline_coupling, baseline_matrix, baseline_all_pair_corrs]    	= unit_cross_corr(binned_spikes(:,:,baseline_bins), xcorr_max_lag);
[target_coupling, target_matrix, target_all_pair_corrs]             = unit_cross_corr(binned_spikes(:,:,target_bins), xcorr_max_lag);
% % [post_coupling, post_matrix, post_all_pair_corrs]                   = unit_cross_corr(binned_spikes(:,:,post_bins), 5);

[shuffled_baseline_coupling, shuffled_baseline_matrix, shuffled_baseline_all_pair_corrs]    = shuffled_unit_corr(binned_spikes(:,:,baseline_bins),xcorr_max_lag,n_shuffles);
[shuffled_target_coupling, shuffled_target_matrix, shuffled_target_all_pair_corrs]          = shuffled_unit_corr(binned_spikes(:,:,target_bins),xcorr_max_lag,n_shuffles);
% [shuffled_post_coupling, shuffled_post_matrix, shuffled_post_all_pair_corrs]                = shuffled_unit_corr(binned_spikes(:,:,post_bins),5,10);

coupling_results    = [baseline_coupling; target_coupling];
shuffled_results    = [shuffled_baseline_coupling'; shuffled_target_coupling'];

delta_coupling          = target_coupling - baseline_coupling;
shuffled_delta_coupling = shuffled_target_coupling' - shuffled_baseline_coupling';

delta_coupling_results  = [delta_coupling; shuffled_delta_coupling];
coupling_groups         = [ones(size(baseline_coupling)); (ones(size(baseline_coupling))*2)];


%% The figure begins

figure
set(gcf,'Units','Normalized','Position',[0 .1 1 .8],'Color',[1 1 1])

%% Raster plot and co-active units histogram, baseline

subplot(4,4,1)
raster_plot(baseline_spikes,1);
ylabel('Unit')
xlabel('Time (s)')
title('Baseline window')
xlim([0 4])
fixplot
box on

subplot(4,4,5)
bar(baseline_vec+0.5*bin_size,baseline_bin_profile,'FaceColor',[0 0 0],'EdgeColor',[0 0 0],'BarWidth',1); % plot the spike counts vs time bins
xlabel('Time (s)')
ylabel('N co-active units')
fixplot

baseline_bar_axis   = gca;

%% Raster plot and co-active units histogram, opto

subplot(4,4,9)
raster_plot(target_spikes,1);
ylabel('Unit')
xlabel('Time (s)')
title('Opto window')
xlim([0 4])
fixplot
box on

subplot(4,4,13)
bar(baseline_vec+0.5*bin_size,target_bin_profile,'FaceColor',[0 0 0],'EdgeColor',[0 0 0],'BarWidth',1); % plot the spike counts vs time bins
xlabel('Time (s)')
ylabel('N co-active units')
fixplot

target_bar_axis     = gca;

%% Some code to ensure equal y axis between the N co-active units bar graphs

baseline_ylim   = get(baseline_bar_axis,'YLim');
target_ylim     = get(target_bar_axis,'YLim');

y_max           = max([baseline_ylim(:); target_ylim(:)]);

set(baseline_bar_axis,'YLim',[0 y_max])
set(target_bar_axis,'YLim',[0 y_max])



%% Correlation matrix - baseline
subplot(2,4,2)
imagesc(baseline_matrix)
set(gca,'ColorMap',parula)
set(gca,'CLim',[0 1])
axis square
colorbar
xlabel('Unit #')
ylabel('Unit #')
title('Baseline correlation')
fixplot
box on

%% Correlation matrix - opto

subplot(2,4,3)
imagesc(target_matrix)
set(gca,'ColorMap',parula)
set(gca,'CLim',[0 1])
axis square
colorbar
xlabel('Unit #')
ylabel('Unit #')
title('Opto correlation')
fixplot
box on

subplot(2,4,4)
imagesc(target_matrix - baseline_matrix)
set(gca,'ColorMap',LFP_colormap)
set(gca,'CLim',[-.5 .5])
% axis off
axis square
colorbar
% colorbar('West')
xlabel('Unit #')
ylabel('Unit #')
title('Delta correlation')
fixplot
box on


%% Cumulative plot

baseline_pair_hist_counts   = histcounts(baseline_all_pair_corrs, [0:0.01:1]);
target_pair_hist_counts     = histcounts(target_all_pair_corrs, [0:0.01:1]);

baseline_cum_perc           = cumsum(baseline_pair_hist_counts)/sum(baseline_pair_hist_counts)*100;
target_cum_perc             = cumsum(target_pair_hist_counts)/sum(target_pair_hist_counts)*100;

subplot(2,4,6)
plot([0.01:0.01:1],baseline_cum_perc, 'k-','LineWidth',2)
hold on
plot([0.01:0.01:1],target_cum_perc, 'r-','LineWidth',2)
ylabel('Cumulative percentage')
xlabel('Correlation coefficient')
legend({'Baseline', 'Opto'},'Location','SouthEast')
fixplot


%% Paired unit coupling plot

subplot(2,4,7)
plot(coupling_results,'k.-','MarkerSize',20)
fixplot
y_lims  = ylim;
set(gca,'YLim',[0 y_lims(2)])
xlim([0 3])
set(gca,'XTick',[1 2],'XTickLabel',{'Baseline', 'Opto'})
ylabel('Unit coupling score')

% stat:
paired_p = signrank(coupling_results(1,:),coupling_results(2,:));

title(['p = ' num2str(paired_p,'%0.5f')])


%% Delta unit coupling + shuffled beeswarm

subplot(2,4,8)
beeswarmplot(delta_coupling_results, coupling_groups,{'Real', 'Shuffled'},[1 0 0; .5 .5 .5])
hold on
plot([0 3],[0 0],'k:')
fixplot
ylabel('Delta coupling score')

paired_p = signrank(delta_coupling_results(1,:),delta_coupling_results(2,:));

title(['p = ' num2str(paired_p,'%0.5f')])

