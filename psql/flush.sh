#!/usr/bin/env bash
# Drop and create database
if [ -n "$1" ] ; then
  echo "Drop and create database '$1'"
else
  echo "Provide a database"
  exit 0
fi
sh ./kill_connections.sh $1
dropdb -h localhost -p 5432 $1 
createdb -h localhost $1 --owner $1
