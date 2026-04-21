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

lt50 = seq(0, 50, length.out=1000)
pdf("width_cdf.pdf", width=6, height=4)
plot(lt50, ecdf(train_vals$width)(lt50), col=cols[1], main="", xlab="Boundary width (ms)",
     ylab="Proportion within width", type="l", lwd=2)
abline(v=mean(train_vals$width), col=cols[1])
lines(lt50, ecdf(val_vals$width)(lt50), col=cols[2], lwd=2, lty=2)
abline(v=mean(val_vals$width), col=cols[2], lty=2)
lines(lt50, ecdf(test_vals$width)(lt50), col=cols[3], lwd=2, lty=3)
abline(v=mean(test_vals$width), col=cols[3], lty=3)
abline(h=0.5)
abline(h=0.25, lty=4, lwd=0.5)
abline(h=0.75, lty=4, lwd=0.5)
legend("bottomright", legend=c("Train", "Val", "Test"), lty=1:3, col=cols, lwd=2, bg="white")
dev.off()

## vowel-vowel cdf

test_vals$segment[test_vals$segment == "SIL"] = "sil"
segcat = read.csv("segment_categories.csv")
test_cats = merge(test_vals, segcat, sort=FALSE)
test_cats = test_cats[with(test_cats, order(file, word, segment_mintime)),]
library(dplyr)
test_cats = test_cats %>%
  group_by(word) %>%
  mutate(cat2=lag(category, 1, default="#"))

pdf("vowel-app-cdf.pdf", width=6, height=4)
plot(lt50, ecdf(test_cats$width[test_cats$category == "vowel" & test_cats$cat2 == "vowel"])(lt50),
     xlim=c(0, 50), type="l", col=cols[1], lwd=2,
     xlab="Boundary width (ms)",
     ylab="Proportion within tolerance", cex.lab=1.5, cex.axis=1.5)
lines(lt50, ecdf(test_cats$width[test_cats$category == "vowel" & test_cats$cat2 == "approximant"])(lt50),
      xlim=c(0, 50), lty=2, col=cols[2], lwd=2)
lines(lt50, ecdf(test_cats$width[test_cats$category == "approximant" & test_cats$cat2 == "vowel"])(lt50),
      xlim=c(0, 50), lty=3, col=cols[3], lwd=2)
abline(h=0.5)
abline(h=0.25, lty=4, lwd=0.5)
abline(h=0.75, lty=4, lwd=0.5)
legend("bottomright", legend=c("vowel-vowel", "vowel-approximant", "approximant-vowel"), lty=1:3, col=cols,
       bg="white", cex=1.5, lwd=2)
dev.off()

pdf("vowel-stop-fric.pdf", width=6, height=4)
plot(lt50, ecdf(test_cats$width[test_cats$category == "vowel" & test_cats$cat2 == "vowel"])(lt50),
     xlim=c(0, 50), type="l", col=cols[1], lwd=2,
     xlab="Boundary width (ms)",
     ylab="Proportion within tolerance", ylim=c(0, 1), cex.lab=1.5, cex.axis=1.5)
lines(lt50, ecdf(test_cats$width[test_cats$category == "stop" & test_cats$cat2 == "fricative"])(lt50),
      xlim=c(0, 50), lty=2, col=cols[2], lwd=2)
lines(lt50, ecdf(test_cats$width[test_cats$category == "fricative" & test_cats$cat2 == "stop"])(lt50),
      xlim=c(0, 50), lty=3, col=cols[3], lwd=2)
abline(h=0.5)
abline(h=0.25, lty=4, lwd=0.5)
abline(h=0.75, lty=4, lwd=0.5)
legend("bottomright", legend=c("vowel-vowel", "stop-fricative", "fricative-stop"), lty=1:3, col=cols,
       bg="white", cex=1.5, lwd=2)
dev.off()

pdf("vowel-stop-fric2.pdf", width=6, height=4)
plot(lt50, ecdf(test_cats$width[test_cats$category == "vowel" & test_cats$cat2 == "vowel"])(lt50),
     xlim=c(0, 50), type="l", col=cols[1], lwd=2,
     xlab="Boundary width (ms)",
     ylab="Proportion within tolerance", ylim=c(0, 1), cex.lab=1.5, cex.axis=1.5)
lines(lt50, ecdf(test_cats$width[test_cats$category == "stop" & test_cats$cat2 == "stop"])(lt50),
      xlim=c(0, 50), lty=2, col=cols[2], lwd=2)
lines(lt50, ecdf(test_cats$width[test_cats$category == "fricative" & test_cats$cat2 == "fricative"])(lt50),
      xlim=c(0, 50), lty=3, col=cols[3], lwd=2)
abline(h=0.5)
abline(h=0.25, lty=4, lwd=0.5)
abline(h=0.75, lty=4, lwd=0.5)
legend("bottomright", legend=c("vowel-vowel", "stop-stop", "fricative-fricative"), lty=1:3, col=cols,
       bg="white", cex=1.5, lwd=2)
dev.off()

pdf("vowel-stop-sil.pdf", width=6, height=4)
plot(lt50, ecdf(test_cats$width[test_cats$category == "vowel" & test_cats$cat2 == "vowel"])(lt50),
     xlim=c(0, 50), type="l", col=cols[1], lwd=2,
     xlab="Boundary width (ms)",
     ylab="Proportion within tolerance", ylim=c(0, 1), cex.lab=1.5, cex.axis=1.5)
lines(lt50, ecdf(test_cats$width[test_cats$category == "stop" & test_cats$cat2 == "silence"])(lt50),
      xlim=c(0, 50), lty=2, col=cols[2], lwd=2)
lines(lt50, ecdf(test_cats$width[test_cats$category == "silence" & test_cats$cat2 == "stop"])(lt50),
      xlim=c(0, 50), lty=3, col=cols[3], lwd=2)
abline(h=0.5)
abline(h=0.25, lty=4, lwd=0.5)
abline(h=0.75, lty=4, lwd=0.5)
legend("bottomright", legend=c("vowel-vowel", "stop-silence", "silence-stop"), lty=1:3, col=cols,
       bg="white", cex=1.5, lwd=2)
dev.off()

