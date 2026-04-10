# Confidence interval analysis for MAPS

[![DOI](https://zenodo.org/badge/923227516.svg)](https://doi.org/10.5281/zenodo.15571293)


0. Run `00-copy_data.jl` to copy the data from existing folders.
1. Run `01-resample_audio.praat` to ensure the audio is sampled at 16,000 Hz.
2. Run `02-make_tg_dict.py` to create a dictionary that maps filenames onto manual transcriptions from the data sets. This step allows the system to look up transcriptions by speaker and sentence to allow for checking the acoustic model using more reallistic data.
3. Run `03-create_manual_labels.py` to create the label files for lookup into the dictionary from 5.
4. Run `04-align_train_manual.sh` to align the training data using the manual transcriptions.
5. Run `05-align_val_manual.sh` to align the validation data using the manual transcriptions.
6. Run `06-align_test_manual.sh` to align the test data using the manual transcriptions.
7. Run `07-manual_evaluation.jl` to test the alignment on the manually transcribed data.
8. Run `08-ci_widths.jl` to assess the widths of the confidence intervals.
9. Run `09-create_ci_fig.praat` to create the confidence intervals figure from the paper.
10. Run `10-heatmap_plots.jl` to create the heatmaps comparing bisegment boundary range widths.
11. Run `11-width_cdf.R` to create the CDF function for thw boundary range widths.

