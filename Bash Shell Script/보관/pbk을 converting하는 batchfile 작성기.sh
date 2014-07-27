#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION

ext=pbk
conveter=pbk2txt

{

echo "@echo off"$'\r'

for i in $(ls *.$(replace_i $ext)); do
	echo "$conveter \"$i\" \"$(sed "s/\.$ext/.txt/i" <<<"$i")\""$'\r'
done

echo "exit /b"$'\r'

} | tee ${ext}convert.cmd

source=$(iconv -t UHC ${ext}convert.cmd)

cat <<<"$source" > ${ext}convert.cmd

exit
