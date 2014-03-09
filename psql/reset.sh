#!bin/bash
sh ./flush.sh $1
psql dbname < tmp/$1.bak


