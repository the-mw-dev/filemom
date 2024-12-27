#!/bin/bash

export WINEDLLOVERRIDES="native,unix,opengl,nvapi64=n"

# Working Directory
cd '/home/user/MiSide'

# Command
/usr/bin/wine '/home/user/Desktop/MiSide/MiSide.exe'
