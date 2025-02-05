using ProgressMeter
using PyCall
textgrid = pyimport("textgrid")

const TRAIN_DIR = "D:/timbuck_data/timbuck10_train"
const VAL_DIR = "D:/timbuck_data/timbuck10_val"
const TEST_DIR = "D:/timbuck_data/timbuck10_test"
const TRAIN_OUT = "train"
const VAL_OUT = "val"
const TEST_OUT = "test"

const TIMIT_PATH = "D:/TIMIT"
const BUCK_PATH = "D:/alignerv2/buck_out"
const BUCK_S4_PATH = "D:/alignerv2/buck_out_s04"

const REPLACE = false

function move_data(src, out, wav_d)
	if ! isdir(out) mkdir(out) end
	done = Set(readdir(out))
	@showprogress for x in [x for x in readdir(src) if endswith(x, "_labs.npy")]
		x = replace(x, "_labs.npy" => ".wav")
		out_path = joinpath(out, x)
		if ! REPLACE && x in done continue end
		src_path = wav_d[lowercase(x)]
		cp(src_path, out_path, force=REPLACE)
	end
end

function move_tg(src, out, tg_d)
	if ! isdir(out) mkdir(out) end
	done = Set(readdir(out))
	@showprogress for x in [x for x in readdir(src) if endswith(x, ".wav")]
		b = splitext(x)[1]
		p = tg_d[lowercase(b)]
		s = String[]
		if startswith(b, "s")
			tg = textgrid.TextGrid()
			tg.read(p)
			for x in tg.tiers[1].intervals
				lab = x.mark
				lab = replace(lab, ";" => "")
				if ! (startswith(lab, "<") || startswith(lab, "{"))
					push!(s, lab)
				end
			end
		else
			open(p) do f
				for line in readlines(f)
					push!(s, split(line, " ")[3])
				end
			end
		end
		out_name = joinpath(out, b * ".txt")
		open(out_name, "w") do w
			write(w, join(s, " ") * "\n")
		end
	end
end

function copy_wav()

	wav_d = Dict{String, String}()
	println("DETERMINING TIMIT LOCATIONS")
	wav_d = Dict{String, String}()
	@showprogress for (root, _, fnames) in collect(walkdir(TIMIT_PATH))
		for f in [x for x in fnames if endswith(lowercase(x), "wav")]
			oneup = basename(root)
			wavname = lowercase(oneup * f)
			wav_d[wavname] = joinpath(root, f)
		end
	end
	
	println("DETERMINING BUCKEYE LOCATIONS")
	@showprogress for (root, _, fnames) in collect(walkdir(BUCK_PATH))
		for f in [x for x in fnames if endswith(lowercase(x), "wav")]
			wav_d[lowercase(f)] = joinpath(root, f)
		end
	end
	
	@showprogress for (root, _, fnames) in collect(walkdir(BUCK_S4_PATH))
		for f in [x for x in fnames if endswith(lowercase(x), "wav")]
			wav_d[lowercase(f)] = joinpath(root, f)
		end
	end

	println("COLLECTING TRAINING DATA")
	move_data(TRAIN_DIR, TRAIN_OUT, wav_d)
	
	println("COLLECTING VAL DATA")
	move_data(VAL_DIR, VAL_OUT, wav_d)
	
	println("COLLECTING TEST DATA")
	move_data(TEST_DIR, TEST_OUT, wav_d)
end

function copy_tg()
	tg_d = Dict{String, String}()
	println("DETERMINING TIMIT LOCATIONS")
	for (root, _, fnames) in walkdir(TIMIT_PATH)
		for f in [x for x in fnames if endswith(x, ".WRD")]
			oneup = basename(root)
			wrdname = oneup * f
			k = lowercase(splitext(wrdname)[1])
			tg_d[k] = joinpath(root, f)
		end
	end
	
	println("DETERMINING BUCKEYE LOCATIONS")
	for (root, _, fnames) in [collect(walkdir(BUCK_PATH)); collect(walkdir(BUCK_S4_PATH))]
		for f in [x for x in fnames if endswith(x, "TextGrid")]
			b = splitext(f)[1]
			tg_d[lowercase(b)] = joinpath(root, f)
		end
	end
	
	println("COPYING TRAIN ORTH")
	move_tg(joinpath(TRAIN_OUT, "audio"), joinpath(TRAIN_OUT, "orth"), tg_d)
	println("COPYING VAL ORTH")
	move_tg(joinpath(VAL_OUT, "audio"), joinpath(VAL_OUT, "orth"), tg_d)
	println("COPYING TEST ORTH")
	move_tg(joinpath(TEST_OUT, "audio"), joinpath(TEST_OUT, "orth"), tg_d)
end

copy_tg()
