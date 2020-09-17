# Spike2_Kilosort
Sharott lab toolkit for spike-sorting Spike2 .smr files using Kilosort

A set of MATLAB functions and scripts to:

1) Extract electrophysiology data, trial and stimulus timings from Spike2 .smr files for an experimental session and write to a concatenated Kilosort-compatible binary data file
2) Run kilosort with settings for a 32-channel 4-shank 100-micron-spacing electrode array in Cortex and one in Thalamus (channel maps included to reflect the recording setup for a specific set of experiments in the Sharott lab)
3) Align the spikes for individual clusters back to the timings of individual protocols, trials and events for further analysis

### Warning - this repository was made for a specific recording configuration and analysis and there are some hardcoded default settings in the main functions, though they should be at the top of the code and clearly indicated.

# How to run Kilosort on Spike2 .smr data using Spike2_Kilosort:

## Step 1: Load Spike2 .smr, extract data & timings, and write Kilosort-compatible binary .dat file

**preprocess_smr.m** will load a series of .smr files, save event data, and write a Kilosort-compatible concatenated binary .dat file. The script **preprocess_script_local.m** provides an example of how to run the **preprocess_smr.m** function.

## Step 2: Kilosort!

The **run_kilosort2.m** function will set up a Kilosort2 run. Use **cortex_config** and **thalamus_config** folders to configure Kilosort for the cortical and thalamic data, respectively. **kilosort2_script.m** provides an example of how to run the **run_kilosort2.m** function.

## Step 3: Manual curation using Phy
See https://github.com/cortex-lab/phy for details on how to install Phy and curate the output from Kilosort2.


## Step 4: Postprocess - link Kilosorted spikes to protocol & event data

**postprocess_kilosort.m** will take the saved experiment sync data from **preprocess_smr.m** and the *curated* output from Kilosort2, and align the spikes for the clusters from Kilosort2 to the protocol, trial and event data. **postprocess_script.m** provides an example of how to control the **postprocess_kilosort.m** function.


### Dependencies:

**load_smr** uses Malcolm Lidierth's old sigTOOL MATLAB SON toolbox to read .smr files. This is no longer maintained and hard to find but was accessed from:
https://github.com/tjrantal/Spike-smr-reader



