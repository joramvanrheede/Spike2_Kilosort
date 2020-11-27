% Compare firing rates

%% Get ChR2 baseline and target firing rates from table & do paired non-parametric test

ChR2_baseline       = unit_results_table.ChR2_baseline;
ChR2_target         = unit_results_table.ChR2_target;

ChR2_results        = [ChR2_baseline'; ChR2_target'];
ChR2_delta          = ChR2_target' - ChR2_baseline';

ChR2_p_val          = signrank(ChR2_baseline,ChR2_target);

%% Get ArchT baseline and target firing rates from table & do paired non-parametric test

ArchT_baseline      = unit_results_table.ArchT_baseline;
ArchT_target        = unit_results_table.ArchT_target;

ArchT_results       = [ArchT_baseline'; ArchT_target'];
ArchT_delta         = ArchT_target' - ArchT_baseline';

ArchT_p_val         = signrank(ArchT_baseline,ArchT_target);

%% Get ChR2 + ArchT baseline and target firing rates from table & do paired non-parametric test

ChR2_ArchT_baseline	= unit_results_table.ChR2_ArchT_baseline;
ChR2_ArchT_target 	= unit_results_table.ChR2_ArchT_target;

ChR2_ArchT_results  = [ChR2_ArchT_baseline'; ChR2_ArchT_target'];
ChR2_ArchT_delta  	= ChR2_ArchT_target' - ChR2_ArchT_baseline';

ChR2_ArchT_p_val  	= signrank(ChR2_ArchT_baseline,ChR2_ArchT_target);

%% Make a figure with line plots ('local_line_plot' function defined below)

figure
set(gcf,'Units','Normalized','Position',[.1 .3 .8 .4])

subplot(1,3,1)
local_line_plot(ChR2_results, ChR2_p_val, 'ChR2 only')

subplot(1,3,2)
local_line_plot(ArchT_results, ArchT_p_val, 'ArchT only')

subplot(1,3,3)
local_line_plot(ChR2_ArchT_results, ChR2_ArchT_p_val, 'ChR2 + ArchT')

subplot_equal_y

%% Make a figure with line delta firing rate values ('local_delta_plot' function defined below)

figure
set(gcf,'Units','Normalized','Position',[.1 .3 .8 .4])

subplot(1,3,1)
local_delta_plot(ChR2_delta, ChR2_p_val, 'ChR2 only')

subplot(1,3,2)
local_delta_plot(ArchT_delta, ArchT_p_val, 'ArchT only')

subplot(1,3,3)
local_delta_plot(ChR2_ArchT_delta, ChR2_ArchT_p_val, 'ChR2 + ArchT')

subplot_equal_y

%% Local functions:

% Line plots
function local_line_plot(results, p_val, group_name)

plot(results,'k.-','MarkerSize',20)
fixplot
xlim([0 3])
set(gca,'XTick',[1 2],'XTickLabel',{'baseline', 'opto'})
ylabel('Firing rate (Hz)')
title([group_name ' - p = ' num2str(round(p_val,5))])

end

% Delta plots
function local_delta_plot(deltas, p_val, group_name)

beeswarm_data      = [deltas(:)];
beeswarm_groups    = [ones(size(deltas(:)))];

beeswarmplot(beeswarm_data, beeswarm_groups, {group_name},[.5 .5 .5])

xlim([0 2])
hold on
plot(xlim,[0 0], 'k:')

fixplot
ylabel('Delta firing rate (Hz)')
title([group_name ' - p = ' num2str(round(p_val,5))])

end