using DataFrames, CSV
using Statistics

function main()
    train_man = CSV.read("train_audio16_manual_ensemble_model_alignment_results.tsv", DataFrame)
    val_man = CSV.read("val_audio16_manual_ensemble_model_alignment_results.tsv", DataFrame)
    test_man = CSV.read("test_audio16_manual_ensemble_model_alignment_results.tsv", DataFrame)

    train_orth = CSV.read("train_audio16_ensemble_model_alignment_results.tsv", DataFrame)
    val_orth = CSV.read("val_audio16_ensemble_model_alignment_results.tsv", DataFrame)
    test_orth = CSV.read("test_audio16_ensemble_model_alignment_results.tsv", DataFrame)

    dfs = [train_man, val_man, test_man, train_orth, val_orth, test_orth]

    means = [mean(x.segment_hi_ci .- x.segment_lo_ci) for x in dfs] .* 1000
    means = round.(means, digits=2)
    medians = [median(x.segment_hi_ci .- x.segment_lo_ci) for x in dfs] .* 1000
    medians = round.(medians, digits=2)
    println(join(["trm", "vam", "tem", "tro", "vao", "teo"], "\t"))
    println(join(string.(means), "\t"))
    println(join(string.(medians), "\t"))
end

main()
