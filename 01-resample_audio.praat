start_dir$ = "D:/maps_ci_data/train/audio"
out_dir$ = "D:/maps_ci_data/train/audio16"
s = Create Strings as file list: "fileList", start_dir$ + "/" + "*.wav"
nFiles = Get number of strings
for i from 1 to nFiles
	selectObject(s)
	fname$ = Get string: i
	w = Read from file: start_dir$ + "/" + fname$
	w16 = Resample: 16000, 50
	out_name$ = out_dir$ + "/" + fname$
	Save as WAV file: out_name$
	selectObject(w, w16)
	Remove
endfor
selectObject(s)
Remove
writeInfoLine: "Done! :)"