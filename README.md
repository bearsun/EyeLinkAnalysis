#EyeLinkAnalysis

There are two steps:
1. Convert .edf to .asc
2. read data from desired time period for each trial

##step 1:
It basically use a binary file (C++ program I think) from the manufacturer. The file is "edf2asc". Scottie has a matlab wrapper for that "Convert.m", but it requires Alex's library. A simple alternative for that is just to run "./edf2asc FilePath" in your terminal. It will generate a .asc file with the same name as the .edf file.

##step 2:
Use "Read.m" to read the .asc file and output a ntrials X 1 structs cells. Each output struct will contain 4 field, in which t=time,d=pupil-diameter. In current setting, each field will be a n X 1 array. n = trial_duration_in_secs X 250, since we are recording with 250 Hz.

The usage for that function:

cOutput = Read(FilePath, 'start_code', % tiral_start_event%, 'end_code', % trial_end_event%);

just replace % tiral_start_event% and % trial_end_event% to the event names you defined for the beginning and end of the interested tracking period for each trial.

