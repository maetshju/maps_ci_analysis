using DynamicAxisWarping
using Distances
using Statistics
using ProgressMeter
using DataFrames
using CSV

using PyCall
textgrid = pyimport("textgrid")

const TG_DIR = "/home/matt/timbuck_data/timbuck_textgrids"
# const VAL_DIR = "val/audio16"
const VAL_TABLE = "val_audio16_manual_ensemble_model_alignment_results.tsv"
const TEST_TABLE = "test_audio16_manual_ensemble_model_alignment_results.tsv"
const TRAIN_TABLE = "train_audio16_manual_ensemble_model_alignment_results.tsv"
const VAL_ERR_OUT_NAME = "val_manual_dtw_errors.txt"
const TEST_ERR_OUT_NAME = "test_manual_dtw_errors.txt"
const TRAIN_ERR_OUT_NAME = "train_manual_dtw_errors.txt"

function main(table_name, err_out_name)

	dat_res = CSV.read(table_name, DataFrame, delim='\t')
	dat_res_g = groupby(dat_res, :file)
	errors = Float64[]
# 	ensemble_names = [x for x in readdir(VAL_DIR) if occursin("ensemble", x)]
# 	@showprogress for fname in ensemble_names
	@showprogress for g in dat_res_g
# 		println(g.file[1])
		fname = g.file[1]
		tg_path = joinpath(TG_DIR, replace(fname, "_ensemble" => ""))
# 		val_tg = textgrid.TextGrid()
# 		val_tg.read(val_path, round_digits=100)
		tg_tg = textgrid.TextGrid()
		tg_tg.read(tg_path, round_digits=100)
# 		if length(tg_tg.tiers[1]) <= 1 continue end
# 		val_times = [x.maxTime for x in val_tg.tiers[2]][1:end-1]
		dat_times = g.segment_maxtime
		s_idx = startswith(fname, "s") ? 2 : 1
		if length(tg_tg.tiers[1]) == 1
			tg_times = [tg_tg.tiers[1][1].maxTime]
		else
# 			tg_times = [x.maxTime for x in tg_tg.tiers[1]][1:end-1]
			tg_times = [x.maxTime for x in tg_tg.tiers[s_idx]]
		end
		if length(dat_times) == 1 || length(tg_times) == 1
			continue
		end
		d, p1, p2 = dtw(dat_times[1:end-1], tg_times[1:end-1], cityblock)
# 		println(abs.(dat_times .- tg_times))
# 		println(mean(abs.(dat_times .- tg_times)))
# 		println(d)
		d /= length(dat_times) - 1
# 		println(d)
# 		exit()
# 		append!(errors, repeat([d], length(val_times)))
		append!(errors, repeat([d], length(dat_times) - 1))
	end
	mn = round(mean(abs.(errors)) * 1000, digits=2)
	mdn = round(median(abs.(errors)) * 1000, digits=2)
	println(mn)
	println(mdn)
	open(err_out_name, "w") do w
		for er in errors
			write(w, "$er\n")
		end
	end
end

println("Analyzing train data")
main(TRAIN_TABLE, TRAIN_ERR_OUT_NAME)
println("Analyzing val data")
main(VAL_TABLE, VAL_ERR_OUT_NAME)
println("Analyzing test data")
main(TEST_TABLE, TEST_ERR_OUT_NAME)
