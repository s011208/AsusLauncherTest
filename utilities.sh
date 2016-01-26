#!/bin/bash

ENV_MAC=false;
ENV_LINUX=false;
ENV_WIN=false;

if [ "$(uname)" == "Darwin" ]; then
    ENV_MAC=true;
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    ENV_LINUX=true;
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    ENV_WIN=true;
fi