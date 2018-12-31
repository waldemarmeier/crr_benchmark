# crr_benchmark

## Intro

A shiny app that allows you to compare the calculation speed of the Cox-Ross-Rubinstein (CRR) option pricing model implemented in R, Java and C++.

## More about this app

The Cox-Ross-Rubinstein (CRR) option pricing model uses a binomial tree to price European or American style options. Even in R, the CRR-model is implemented using loops. This approach leads to poor code-performance in R. As the length of the binomial tree growths, the calculation takes significantly more time. You can improve the performance by outsourcing the calculation of the model to other programming languages. 

In this R-shiny app you can compare the speed of the CRR-model calculation in R, Java and C++. R uses the implmenation of the fOptions package. The methods in Java and C++ are basically copies of the R implemenation. Furhtermore, for European style options you can observe how the CRR-price converges to the analytical price.

## Usage

### Docker

Run using docker (clone repo and open a commandline window in the directory):

```
docker build -t crr .
docker run -p 3838:3838 crr
```
Now, you can access the app in the browser on `localhost:3838`.

### R Studio

This setup requires that you to install the JDK and all R-packages (listed in app/global.R). Clone the repository and import it into r-studio. Open a commandline window and move to `app/java`. Now you have to compile and package the Java file.

Using the script
```
chmod +x compile_archive_java.sh
./ compile_archive_java.sh
```
Or the JDK commands

```
javac CRR.java
jar CRR.jar CRR.class
```
Press the run button in R-Studio to start the app.
