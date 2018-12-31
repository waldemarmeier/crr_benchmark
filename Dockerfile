FROM rocker/shiny:3.5.2

LABEL maintainer="Waldemar Meier info@waldemarmeier.com"

RUN apt update -y && \
    apt-get install openjdk-8-jdk-headless -y \
    libbz2-dev \
    libicu-dev \
    liblzma-dev \ 
    # for plotly / httr
    libssl-dev    

COPY app srv/shiny-server
      
RUN R -e "install.packages(c('httr','shiny','rJava','plotly','fOptions',\
          'shinythemes','data.table','Rcpp','microbenchmark'))"


RUN cd srv/shiny-server/java \
    chmod + x compile_archive_java.sh && \
    ./compile_archive_java.sh