% Compare synchronous firing by unit via the 'coupling' metric

%% Minimum number of units needed to include recording - has to be at least 2 for pairwise correlation
min_n_units             = 2;

%% Select for n cortical units

n_units                 = unit_results_table.n_cortical_units;
q_n_units               = n_units >= min_n_units;

q_select                = q_n_units;
unit_select_table       = unit_results_table(q_select,:);

%% Get ChR2 coupling measures

ChR2_baseline_coupling  = unit_select_table.ChR2_baseline_coupling;
ChR2_target_coupling    = unit_select_table.ChR2_target_coupling;

ChR2_coupling_results 	= [ChR2_baseline_coupling'; ChR2_target_coupling'];
ChR2_coupling_delta     = ChR2_target_coupling' - ChR2_baseline_coupling';

% Get shuffled measures
ChR2_shuffled_baseline_coupling     = unit_select_table.ChR2_shuffled_baseline_coupling;
ChR2_shuffled_target_coupling       = unit_select_table.ChR2_shuffled_target_coupling;

ChR2_shuffled_coupling_results      = [ChR2_shuffled_baseline_coupling'; ChR2_shuffled_target_coupling'];
ChR2_shuffled_coupling_delta        = ChR2_shuffled_target_coupling' - ChR2_shuffled_baseline_coupling';

% Do paired non-parametric test
ChR2_p_val  = signrank(ChR2_baseline_coupling,ChR2_target_coupling);

%% Get ArchT coupling measures

ArchT_baseline_coupling     = unit_select_table.ArchT_baseline_coupling;
ArchT_target_coupling       = unit_select_table.ArchT_target_coupling;

ArchT_coupling_results      = [ArchT_baseline_coupling'; ArchT_target_coupling'];
ArchT_coupling_delta        = ArchT_target_coupling' - ArchT_baseline_coupling';

% Get shuffled measures
ArchT_shuffled_baseline_coupling  	= unit_select_table.ArchT_shuffled_baseline_coupling;
ArchT_shuffled_target_coupling   	= unit_select_table.ArchT_shuffled_target_coupling;

ArchT_shuffled_coupling_results  	= [ArchT_shuffled_baseline_coupling'; ArchT_shuffled_target_coupling'];
ArchT_shuffled_coupling_delta       = ArchT_shuffled_target_coupling' - ArchT_shuffled_baseline_coupling';

% Do paired non-parametric test
ArchT_p_val  = signrank(ArchT_baseline_coupling,ArchT_target_coupling);

%% Get ChR2+ArchT coupling measures

ChR2_ArchT_baseline_coupling  = unit_select_table.ChR2_ArchT_baseline_coupling;
ChR2_ArchT_target_coupling    = unit_select_table.ChR2_ArchT_target_coupling;

ChR2_ArchT_coupling_results 	= [ChR2_ArchT_baseline_coupling'; ChR2_ArchT_target_coupling'];
ChR2_ArchT_coupling_delta   	= ChR2_ArchT_target_coupling' - ChR2_ArchT_baseline_coupling';

% Get shuffled measures
ChR2_ArchT_shuffled_baseline_coupling   = unit_select_table.ChR2_ArchT_shuffled_baseline_coupling;
ChR2_ArchT_shuffled_target_coupling 	= unit_select_table.ChR2_ArchT_shuffled_target_coupling;

ChR2_ArchT_shuffled_coupling_results 	= [ChR2_ArchT_shuffled_baseline_coupling'; ChR2_ArchT_shuffled_target_coupling'];
ChR2_ArchT_shuffled_coupling_delta   	= ChR2_ArchT_shuffled_target_coupling' - ChR2_ArchT_shuffled_baseline_coupling';

% Do paired non-parametric test
ChR2_ArchT_p_val  = signrank(ChR2_ArchT_baseline_coupling,ChR2_ArchT_target_coupling);

%% Make line plots (local_line_plot function defined below)

figure
set(gcf,'Units','Normalized','Position',[.1 .3 .8 .4])

subplot(1,3,1)
local_line_plot(ChR2_coupling_results, ChR2_shuffled_coupling_results, ChR2_p_val, 'ChR2 only')

subplot(1,3,2)
local_line_plot(ArchT_coupling_results, ArchT_shuffled_coupling_results, ArchT_p_val, 'ArchT only')

subplot(1,3,3)
local_line_plot(ChR2_ArchT_coupling_results, ChR2_ArchT_shuffled_coupling_results, ChR2_ArchT_p_val, 'ChR2 + ArchT')

subplot_equal_y

%% Make delta plots (local_delta_plot function defined below)

figure
set(gcf,'Units','Normalized','Position',[.1 .3 .8 .4])

subplot(1,3,1)
local_delta_plot(ChR2_coupling_delta, ChR2_shuffled_coupling_delta, ChR2_p_val, 'ChR2 only')

subplot(1,3,2)
local_delta_plot(ArchT_coupling_delta, ArchT_shuffled_coupling_delta, ArchT_p_val, 'ArchT only')

subplot(1,3,3)
local_delta_plot(ChR2_ArchT_coupling_delta, ChR2_ArchT_shuffled_coupling_delta, ChR2_ArchT_p_val, 'ChR2 + ArchT')

subplot_equal_y

%% Local plotting functions:

function local_line_plot(coupling_results, shuffled_coupling_results, p_val, group_name)

plot(shuffled_coupling_results,'.-','MarkerSize',20,'Color',[.6 .6 .6])
hold on
plot(coupling_results,'k.-','MarkerSize',20)
fixplot
xlim([0 3])
set(gca,'XTick',[1 2],'XTickLabel',{'baseline', 'opto'})
ylabel('Unit coupling coefficient')
title([group_name ' - p = ' num2str(round(p_val,5))])

end


function local_delta_plot(coupling_delta, shuffled_coupling_delta, p_val, group_name)

beeswarm_data      = [coupling_delta(:); shuffled_coupling_delta(:)];
beeswarm_groups    = [ones(size(coupling_delta(:))); 2*ones(size(shuffled_coupling_delta(:)))];

beeswarmplot(beeswarm_data, beeswarm_groups, {'Data' 'Shuffled'},[0 0 0; .6 .6 .6])

xlim([0 3])
hold on
plot(xlim,[0 0], 'k:')

fixplot
ylabel('Delta coupling coefficient')
title([group_name ' - p = ' num2str(round(p_val,5))])

end