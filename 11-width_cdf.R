train_vals = read.table("train_audio16_manual_ensemble_model_alignment_results.tsv",
                        header=TRUE)
train_vals$width = with(train_vals, segment_hi_ci - segment_lo_ci) * 1000

val_vals = read.table("val_audio16_manual_ensemble_model_alignment_results.tsv",
                      header=TRUE)
val_vals$width = with(val_vals, segment_hi_ci - segment_lo_ci) * 1000

test_vals = read.table("test_audio16_manual_ensemble_model_alignment_results.tsv",
           header=TRUE)
test_vals$width = with(test_vals, segment_hi_ci - segment_lo_ci) * 1000

cols = hcl.colors(3, "Dark2")
cols = c(rgb(0.0, 0.6056031704619725, 0.9786801190138923),
         rgb(0.8888735440600661, 0.435649148506399, 0.2781230452972764),
         rgb(0.24222393333911896, 0.6432750821113586, 0.304448664188385))

lt40 = seq(0, 40, length.out=1000)
plot(lt40, ecdf(train_vals$width)(lt40), col=cols[1], main="", xlab="Boundary width (ms)",
     ylab="Proportion within width", type="l", lwd=2)
abline(v=mean(train_vals$width), col=cols[1])
lines(lt40, ecdf(val_vals$width)(lt40), col=cols[2], lwd=2, lty=2)
abline(v=mean(val_vals$width), col=cols[2], lty=2)
lines(lt40, ecdf(test_vals$width)(lt40), col=cols[3], lwd=2, lty=3)
abline(v=mean(test_vals$width), col=cols[3], lty=3)
abline(h=0.5)
legend("bottomright", legend=c("Train", "Val", "Test"), lty=1:3, col=cols, lwd=2)
