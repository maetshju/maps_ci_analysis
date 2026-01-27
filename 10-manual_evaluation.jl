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
const VAL_ERR_OUT_NAME = "val_manual_errors.txt"
const TEST_ERR_OUT_NAME = "test_manual_errors.txt"
const TRAIN_ERR_OUT_NAME = "train_manual_errors.txt"

const BUCKEYE_IGNORE = Set([
	"<EXCLUDE-NAME>",
	"<EXCLUDE-name>",
	"<EXCLUDE>",
	"EXCLUDE",
	"<EXCLUDE>",
	"IVER",
	"<IVER>",
	"IVER-LAUGH",
	"<IVER-LAUGH>",
	"LAUGH",
	"<LAUGH>",
	"NOISE",
	"<NOISE>",
	"UNKNOWN",
	"<UNKNOWN>",
	"VOCNOISE",
	"<VOCNOISE>",
	"{B_TRANS}",
	"{E_TRANS}",
	"",
	])
function main(table_name, err_out_name)

	dat_res = CSV.read(table_name, DataFrame, delim='\t')
	dat_res_g = groupby(dat_res, :file)
	errors = Float64[]
	p = []
	tim_errors = Float64[]
	tim_p = []
	buck_errors = Float64[]
	buck_p = []
	contained = Bool[]
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
		dat_cilo = g.segment_lo_ci
		dat_cihi = g.segment_hi_ci
		ranges = [(lo, hi) for (lo, hi) in zip(dat_cilo, dat_cihi)]
		s_idx = startswith(fname, "s") ? 2 : 1
		if length(tg_tg.tiers[s_idx]) == 1
			tg_times = [tg_tg.tiers[s_idx][1].maxTime]
		else
# 			tg_times = [x.maxTime for x in tg_tg.tiers[1]][1:end-1]
			tg_times = [x.maxTime for x in tg_tg.tiers[s_idx] if ! (replace(x.mark, ";"=>"") in BUCKEYE_IGNORE)]
		end
		if length(dat_times) == 1 || length(tg_times) == 1
			continue
		end
		if length(dat_times) != length(tg_times)
			dur1 = tg_tg.tiers[s_idx][1].maxTime - tg_tg.tiers[s_idx][1].minTime
			durf = tg_tg.tiers[s_idx][end].maxTime - tg_tg.tiers[s_idx][end].minTime
			if startswith(fname, "s")
				if durf < 0.01
					tg_times = tg_times[1:end-1]
				elseif dur1 < 0.001
					tg_times = tg_times[2:end]
				end
			else
				for x in tg_tg.tiers[s_idx]
					println(x.mark)
				end
				error("Incommensurate lengths for file $(g.file[1]). Lengths: $((length(dat_times), length(tg_times)))")
			end
		end
		er = dat_times[1:end-1] .- tg_times[1:end-1]
		presences = [b <= t <= e for (b, e, t) in zip(dat_cilo[1:end-1], dat_cihi[1:end-1], tg_times[1:end-1])]
		if startswith(fname, "s")
			append!(buck_errors, er)
			append!(buck_p, presences)
		else
			append!(tim_errors, er)
			append!(tim_p, presences)
		end
		append!(errors, er)
		append!(p, presences)
	end
	mn = round(mean(abs.(errors)) * 1000, digits=2)
	mdn = round(median(abs.(errors)) * 1000, digits=2)
	println(mn)
	println(mdn)
	open(err_out_name, "w") do w
		for (er, pr) in zip(errors, p)
			write(w, "$er\t$pr\n")
		end
	end

	open("tim" * err_out_name, "w") do w
		for (er, pr) in zip(tim_errors, tim_p)
			write(w, "$er\t$pr\n")
		end
	end

	open("buck" * err_out_name, "w") do w
		for (er, pr) in zip(buck_errors, buck_p)
			write(w, "$er\t$pr\n")
		end
	end
end

println("Analyzing train data")
main(TRAIN_TABLE, TRAIN_ERR_OUT_NAME)
println("Analyzing val data")
main(VAL_TABLE, VAL_ERR_OUT_NAME)
println("Analyzing test data")
main(TEST_TABLE, TEST_ERR_OUT_NAME)
