# Library
library(tidyverse)

# T test from summary statistics
tsum_test <- function(xbar, s, n, mu = 0,
                       alternative = c("two.sided", "less", "greater"), alpha = 0.05) {
  
  alternative <- match.arg(alternative)
  
  df <- n - 1
  
  t <- (xbar - mu) / (s / sqrt(n))
  
  p.value <- switch(alternative,
                    two.sided = pt(abs(t), df = df, lower.tail = FALSE) * 2,
                    greater = pt(t, df = df, lower.tail = FALSE),
                    less = pt(t, df = df))
  
result <- structure(
  list(
    statistic = c(t = t),
    parameter = c(df = df),
    p.value = p.value,
    alternative = alternative,
    method = "One-sample t-test from summary statistics",
    data.name = "summary statistics"
  ),
  class = "htest"
  )

result
}

# Confidence interval for a t-test
ci <- function(xbar, s, n, level = 0.95) {
  
  tcrit <- qt((1 - level) / 2, df = n - 1, lower.tail = FALSE)
  
  interval <- xbar + c(-1, 1) * tcrit * s / sqrt(n)
  
  names(interval) <- c("lower", "upper")
  
  interval
}

# Two sample t-test from sample statistics
tsum2_test <- function(
    xbar1, s1, n1, xbar2, s2, n2,
    var.equal = FALSE, alternative = c("two.sided", "greater", "less"),
    alpha = 0.05, ci = FALSE, level = 0.95) {
  
  alternative <- match.arg(alternative)
  
  # Using pooled variance
  if (var.equal) {
    df <-  n1 + n2 - 2
    
    sp2 <- ((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / df
    
    se <- sqrt(sp2 * (1/n1 + 1/n2))
  }
  
  # Using Welch-Satterthwaite
  else {
    w1 <- s1^2 / n1
    
    w2 <- s2^2 / n2
    
    se <- sqrt(w1 + w2)
    
    df <- (w1 + w2)^2 / (w1^2 / (n1 - 1) + w2^2 / (n2 - 1)) 
  }
  
  # Calculate t-value with corresponding p-value
  t <- (xbar1 - xbar2) / se
  
  p.value <- switch(alternative,
                    two.sided = pt(abs(t), df = df, lower.tail = FALSE) * 2,
                    greater = pt(t, df = df, lower.tail = FALSE),
                    less = pt(t, df = df))
  
  # Compile results
  results <- list(
    "statistic" = t,
    "DF" = df,
    "P.value" = p.value
  )
  
  # If requested, calculate CI and and append to results
  if (ci) {
    tcrit <- qt(1 - (1 - level) / 2, df = df)
    
    interval <- (xbar1 - xbar2) + c(-1, 1) * tcrit * se
    
    results$conf.interval <- interval
  }
  
  return(results)
}

# Custom function to compute power
find_power <- function(d, n, alpha = 0.05, 
                       alternative = c("two.sided", "less", "greater")) {
  alternative <- match.arg(alternative)
  if (length(n) > 1) {
    n1 <- n[1]
    n2 <- n[2]
    n_h <- 2 * n1 * n2 / (n1 + n2)
    delta <- d * sqrt(n_h/2)
    df <- n1 + n2 - 2
  }
  else {
    delta <- d * sqrt(n/2)
    df <- 2 * (n - 1)
  }
  t_crit <- switch(alternative,
                   "two.sided" = qt(1 - alpha / 2, df = df),
                   "greater" = qt(1 - alpha, df = df),
                   "less" = qt(alpha, df = df))
  beta <- switch(alternative,
                 "two.sided" = diff(pt(c(-t_crit, t_crit), df = df, ncp = delta)),
                 "greater" = pt(t_crit, df = df, ncp = delta),
                 "less" = 1 - pt(t_crit, df = df, ncp = delta))
  power <- 1 - beta
  power
}