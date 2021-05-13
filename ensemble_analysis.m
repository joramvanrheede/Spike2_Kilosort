
target_win      = [5.1 9.1];
baseline_win    = [0 4];

probe_dims      = [8,4];
spacing         = [100];
smooth_win      = 33;

% choose experiment
expt            = matched_ArchT(5);

% defaults
bin_size        = 0.01;
bin_vec         = 0:bin_size:(1500*bin_size);
bin_vec         = bin_vec(1:end-1);

%
baseline_bins   = bin_vec >= baseline_win(1) & bin_vec < baseline_win(2);
target_bins     = bin_vec >= target_win(1) & bin_vec < target_win(2); 

% Select binned spikes from appropriate windows
target_binned_spikes                = binned_spikes(:,:,target_bins);
baseline_binned_spikes              = binned_spikes(:,:,baseline_bins);

% Do pca
[target_coeff, target_score, target_latent]        = pca_on_channels(target_binned_spikes);
[baseline_coeff, baseline_score, baseline_latent]    = pca_on_channels(baseline_binned_spikes);


visualise_component_loadings(baseline_coeff, probe_dims, spacing, smooth_win)
visualise_component_loadings(target_coeff, probe_dims, spacing, smooth_win)

figure
plot(baseline_latent,'LineWidth',2)
hold on
plot(target_latent,'r','LineWidth',2)
xlabel('Component #')
ylabel('Principal component variance')
legend({'Baseline', 'Opto'})
fixplot



function visualise_component_loadings(coeff, probe_dims, spacing, smooth_win)

pca_fig = figure;
set(pca_fig,'Units','Normalized','Position',[.2 .2 .6 .6])
for a = 1:6
    subplot(3,2,a)
    probe_image = generate_probe_image(coeff(:,a),probe_dims, spacing, smooth_win);
    imagesc(probe_image)
    set(gca,'CLim',[-.5 .5])
    xlabel('Depth (microns)')
    ylabel('Width (microns)')
    fixplot
    colorbar
    colormap(hot_cold)
end

end