# Spike2_Kilosort
Sharott lab toolkit for spike-sorting Spike2 .smr files using Kilosort

A set of MATLAB functions and scripts to:

1) Extract electrophysiology data, trial and stimulus timings from .smr files for an experimental session and write to a concatenated Kilosort-compatible binary data file
2) Run kilosort with settings for a 32-channel 4-shank 100-micron-spacing electrode array in Cortex and one in Thalamus (channel maps included to reflect the recording setup for a specific set of experiments in the Sharott lab)
3) Align the spikes for individual clusters back to the timings of individual protocols, trials and events for further analysis


## Step 1: Load Spike2 .smr, extract data & timings, and write Kilosort-compatible binary .dat file

**preprocess_smr.m** will load a series of .smr files, save event data, and write a Kilosort-compatible concatenated binary .dat file

## Step 2: Kilosort!

Use **cortex_config** and **thalamus_config** folders to configure Kilosort for the cortical and thalamic data, respectively.

## Step 3: Link Kilosorted spikes to protocol & event data

**postprocess_kilosort.m** will take the saved event data from preprocess_smr and the *curated* output from Kilosort and align the spikes for the clusters from Kilosort to the protocol, trial and event data.

### Dependencies:

**load_smr** uses Malcolm Lidierth's old sigTOOL MATLAB SON toolbox to read .smr files. This is no longer maintained and hard to find but was accessed from:
https://github.com/tjrantal/Spike-smr-reader



