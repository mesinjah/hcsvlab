#!/bin/bash

for CORPUS in $@
do
  rake fedora:ingest $CORPUS
done