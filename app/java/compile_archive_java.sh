#!/bin/sh

# check if java class file exists

if [ -f CRR.class ]; then
    echo "delete class file"
    rm CRR.class
fi

# check if java jar file exists

if [ -f CRR.jar ]; then
    echo "delete jar file"
    rm CRR.jar
fi

javac CRR.java

jar cf CRR.jar CRR.class