Erase all
start = 0.5571435530707061
final = 0.91233022171669795
s = Read from file: "/home/matt/maps_ci_data/train/audio16/FAEM0SX42.wav"
tg = Read from file: "/home/matt/maps_ci_data/train/audio16_manual/FAEM0SX42_ensemble.TextGrid"

selectObject(s)

Select outer viewport: 0, 6.5, 0, 1.5
Draw: start, final, 0, 0, "no", "curve"
Draw inner box
Marks left: 2, "yes", "yes", "no"
Text left: "no", "Amplitude"

Select outer viewport: 0, 6.5, 0.85, 3.575
selectObject(s)
sp = To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
Paint: start, final, 0, 0, 100, "yes", 50, 6, 0, "no"
Draw inner box
Marks left: 2, "yes", "yes", "no"
Text left: "no", "Frequency (Hz)"

selectObject(tg)
Remove tier: 1
Remove point: 2, 16
Select outer viewport: 0, 6.5, 0, 5
Draw: start, final, "no", "no", "no"
Marks bottom: 2, "yes", "yes", "no"
Text bottom: "no", "Time (s)"
Colour: "Blue"
for i from 18 to 21
	t = Get time of point: 2, i
	One mark bottom: t, "no", "no", "yes", ""
endfor
Colour: "Black"

removeObject(s, tg, sp)