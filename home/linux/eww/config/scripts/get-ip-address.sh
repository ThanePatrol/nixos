#!/usr/bin/env bash

ip -4 -o addr | grep 'enp' | awk '{print $4}' | sed 's/\/.*//'
