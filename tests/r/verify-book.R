# verify-book.R — QualStack's R tools against numbers published in Humphreys &
# Jacobs (2023). Run by tests/run_tests.py when R and CausalQueries are
# installed: Rscript tests/r/verify-book.R <path-to-qualstack-root>
# Exact checks use tolerance 0.001; Stan-based ones allow Monte Carlo error.

args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args)) args[1] else "."
suppressMessages({
  source(file.path(root, "skills/clue-select/assets/clue-diagnosis.R"))
  source(file.path(root, "skills/case-select/assets/case-diagnosis.R"))
  source(file.path(root, "skills/robustness/assets/model-checks.R"))
  source(file.path(root, "skills/process-trace/assets/trace-case.R"))
})
fails <- 0
check <- function(label, got, want, tol) {
  ok <- isTRUE(all(abs(got - want) <= tol))
  cat(if (ok) "ok  " else "FAIL", label, ": got", paste(round(got, 4), collapse = " "),
      "want", paste(want, collapse = " "), "\n")
  if (!ok) fails <<- fails + 1
}

# Fig 12.2 (base survival model): expected learning by clue strategy, given Y = 0.
surv <- make_model("S -> C -> Y <- R <- X; X -> C -> R") |>
  set_restrictions(labels = list(C = c("1110", "1111"), R = c("0001", "0000"), Y = c("0001")), keep = TRUE)
s12 <- qs_strategy_table(surv, "(Y[X=1] > Y[X=0])", "Y==0",
                         list(X = "X", S = "S", C = "C", R = "R", XS = c("X", "S"), CS = c("C", "S")))
check("Fig 12.2 X, S, C, R, XS, CS", s12$exp_learning, c(.1875, .0508, .0545, 0, .2417, .0756), .001)

pimd <- make_model("I -> M -> D <- P; I -> D") |>
  set_restrictions(c("(M[I=1] < M[I=0])",
                     "(D[I=1] > D[I=0]) | (D[M=1] < D[M=0]) | (D[P=1] < D[P=0])"))

# Fig 12.4: expected learning from P alone, M alone, both, in an I=0, D=1 case.
st <- qs_strategy_table(pimd, "D[I=1] != D[I=0]", "I==0 & D==1",
                        list(P = "P", M = "M", MP = c("M", "P")))
check("Fig 12.4 I=0,D=1 expected learning", st$exp_learning, c(.0704, .0066, .0843), .001)

# Fig 12.7: two-step strategies with prices M = 1, P = 1.5.
ts <- qs_two_step(pimd, "(D[I=1] != D[I=0])", "D==1 & I==1", c("M", "P"), c(M = 1, P = 1.5))
row <- function(lab) ts[ts$strategy == lab, c("exp_var", "exp_cost")]
check("Fig 12.7 (M),(.,P)", unlist(row("(M),(.,P)")), c(.1049, 2.277), .001)
check("Fig 12.7 (P),(M,.)", unlist(row("(P),(M,.)")), c(.1061, 1.777), .001)
check("Fig 12.7 frontier size", sum(ts$frontier & ts$strategy != "priors"), 4, 0)

# Fig 16.10: process tracing Malawi (I=1, D=1, M=1, P=1) and Nicaragua (I=0, D=1, M=1, P=1).
tr <- qs_trace_case(pimd, "D[I=1] != D[I=0]", list(I = 1, D = 1), list(M = 1, P = 1))
check("Fig 16.10 Malawi path", tr$path$posterior, c(.128, .150, .107), .001)
tr2 <- qs_trace_case(pimd, "D[I=1] != D[I=0]", list(I = 0, D = 1), list(M = 1, P = 1))
check("Fig 16.10 Nicaragua, Albania (P=0), Taiwan (M=0)",
      c(tr2$path$posterior[3], tr2$counterfactual$if_other_value[2], tr2$counterfactual$if_other_value[1]),
      c(.263, .571, .393), .001)

# Table 16.2: sensitivity of Pr(X caused Y | X=Y=1, M) to lambda^Y_10.
base <- make_model("X -> M -> Y") |> set_parameters(param_names = "M.10", parameters = .25)
vars <- lapply(c(0, .1, .2), function(a) set_parameters(base, param_names = "Y.10", parameters = a))
names(vars) <- c("a0", "a1", "a2")
s <- qs_sensitivity(vars, list(PC = "Y[X=1] > Y[X=0]"),
                    given = list("X==1 & Y==1", "X==1 & Y==1 & M==0", "X==1 & Y==1 & M==1"))
check("Table 16.2 (a = .1)", s$mean[s$model == "a1"], c(.200, .125, .25), .001)

# Table 16.1: conditional-independence check in the running example.
cnt <- c(X0M0Y0 = 35, X1M0Y0 = 14, X0M1Y0 = 32, X1M1Y0 = 15, X0M0Y1 = 20, X1M0Y1 = 34, X0M1Y1 = 17, X1M1Y1 = 33)
d <- do.call(rbind, lapply(names(cnt), function(k) {
  v <- as.integer(strsplit(gsub("[XMY]", "", k), "")[[1]])
  data.frame(X = rep(v[1], cnt[[k]]), M = rep(v[2], cnt[[k]]), Y = rep(v[3], cnt[[k]]))
}))
ci <- qs_ci_tests(make_model("X -> M -> Y"), d)
check("Table 16.1 X-Y difference given M", ci$diff, c(.345, .341), .001)

# Table 13.7: expected posterior variance of three case-selection strategies (Stan).
m13 <- make_model("X -> M -> Y") |> set_restrictions(c("(Y[M=1]<Y[M=0])", "(M[X=1]<M[X=0])"))
d13 <- data.frame(X = c(0, 0, 0, 1, 1, 1), M = NA, Y = c(0, 0, 1, 0, 1, 1))
set.seed(20250101)
u13 <- suppressWarnings(suppressMessages(update_model(m13, d13, refresh = 0, iter = 8000, chains = 4)))
cs <- qs_case_strategies(u13, "Y[X=1] - Y[X=0]",
                         list(on = c("X==1 & Y==1", "X==0 & Y==0"), off = c("X==1 & Y==0", "X==0 & Y==1"),
                              pos = c("X==1 & Y==1", "X==1 & Y==1")), clues = "M")
check("Table 13.7 EPV (on, off, two positive)", cs$exp_post_var, c(.0151, .0173, .0156), .0007)
check("Table 13.7 ranking on < pos < off", as.numeric(order(cs$exp_post_var)), c(1, 3, 2), 0)

cat(if (fails) paste(fails, "check(s) failed\n") else "all checks passed\n")
quit(status = if (fails) 1 else 0)
