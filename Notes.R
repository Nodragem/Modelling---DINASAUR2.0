almostExp <- function(L, tau, t){
  return ((1- L/tau)^t)
}

Exp <- function(L, tau, t){
  return (exp(-L*t/tau))
}

time <- 0:1000

plot(time, almostExp(10, 100, time))
points(time, Exp(10, 100, time))

plot(time, almostExp(100, 100, time))
points(time, Exp(100, 100, time))

