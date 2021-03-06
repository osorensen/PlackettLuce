context("implementation [simulate.PlackettLuce]")


R <- matrix(c(1, 2, 0, 0,
              4, 1, 2, 3,
              2, 1, 1, 1,
              1, 2, 3, 0,
              2, 1, 1, 0,
              1, 0, 3, 2), nrow = 6, byrow = TRUE)
colnames(R) <- c("apple", "banana", "orange", "pear")
mod <- PlackettLuce(R)
simulate(mod, 5)
s1 <- simulate(mod, 5, seed = 112)
s2 <- simulate(mod, 4, seed = 112)

test_that("the seed argument is respected in [simulate.PlackettLuce]", {
    expect_identical(s1[1:3], s2[1:3])
})


## A small simulation study
R <- PlackettLuce:::generate_rankings(maxi = 5, n_rankings = 100, tie = 0,
                                      seed = 123)
mod1 <- PlackettLuce(R)
samples <- simulate(mod1, 100, seed = 123)
fits <- lapply(samples, PlackettLuce, npseudo = 0.5)
coefs <- vapply(fits, function(fit) {
    cc <- coef(fit)
    if (length(cc) < 9)
        c(cc, rep(0, 9 - length(cc)))
    else
        cc
}, numeric(length(coef(mod1))))

## As computed from the first implementation
test_biases <- c(0.000000000, -0.014515877, -0.022463593, 0.010276173,
                 -0.063401876, -0.030184771, -0.065134349, -0.003526264,
                 -0.022166709)

test_that("simulation results are consistent to first version", {
    result_biases <- unname(unclass(rowMeans(coefs) - coef(mod1)))
    expect_equivalent(result_biases, test_biases, tolerance = 1e-06)
})

## par(mfrow = c(3, 3))
## for (j in 1:9) { hist(coefs[j,], main = paste(j)); abline(v = coef(mod1)[j]) }

## ## ## No ties
## R <- PlackettLuce:::generate_rankings(maxi = 10, n_rankings = 100,
##                                       tie = 1000, seed = 123)
## mod1 <- PlackettLuce(R)

## ## Using Diaconis (1998). Chapter 9D
## samples <- simulate(mod1, 1000, seed = 123, multinomial = FALSE)
## fits <- mclapply(samples, PlackettLuce, npseudo = 0.5, mc.cores = 4)
## coefs <- sapply(fits, function(fit) {
##     cc <- coef(fit)
##     cc
## })
## result_biases <- unname(unclass(rowMeans(coefs) - coef(mod1)))

## ## Using multinomial sampling
## samples2 <- simulate(mod1, 1000, seed = 123, multinomial = TRUE)
## fits2 <- mclapply(samples2, PlackettLuce, npseudo = 0.5, mc.cores = 4)
## coefs2 <- sapply(fits2, function(fit) {
##     cc <- coef(fit)
##     cc
## })
## result_biases2 <- unname(unclass(rowMeans(coefs2) - coef(mod1)))



