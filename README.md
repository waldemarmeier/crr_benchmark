# crr_benchmark

## Intro

A shiny app that allows you to compare calculation speed of the Cox-Ross-Rubinstein (CRR) option pricing model in R, Java and C++.

## More about this app

The Cox-Ross-Rubinstein (CRR) option pricing model uses a binomial tree to price European or American style options. Even in R, the CRR-model is implemented using loops. This approach leads to poor code-performance in R. As the length of the binomial tree growths, the calculation takes significantly more time. You can improve the performance by outsourcing the calculation of the model to other programming languages. 

In this R-shiny app you can compare the speed of the CRR-model calculation in R, Java and C++. R uses the implmenation of the fOptions package. The methods in Java and C++ are basically copies of the R implemenation. Furhtermore, for European style options you can observe how the CRR-price converges to the analytical price.