#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

name=$1
neato -Tpng $name.dot -o $name.png -Kdot

exit