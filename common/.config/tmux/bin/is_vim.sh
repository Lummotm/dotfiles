#!/usr/bin/env bash

if ps ax | grep "$1" | grep -v nvim; then
    exit 0
else
    exit 1
fi
