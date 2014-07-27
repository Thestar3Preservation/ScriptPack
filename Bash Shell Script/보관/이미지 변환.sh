#!/bin/bash

IFS='
'

 mogrify -format jpg "$@"

exit
