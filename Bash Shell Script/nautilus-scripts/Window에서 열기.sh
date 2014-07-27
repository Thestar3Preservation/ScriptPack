#!/bin/bash
source ~/.bash_profile

VM='/media/ntfs_ssd/VMware/Windows XP Professional (3)/Windows XP Professional (3).vmx'

vmrun.sh "$VM" Setting_3 'Windows XP Professional x86'

if [[ $# > 0 ]]; then
	for i; do
		vmware-unity-helper --run "$VM" "Z:\\Host$(realpath "$i" | sed 's/\//\\/g')"
	done
else
	vmware-unity-helper --run "$VM" "Z:\\Host$(realpath "$PWD" | sed 's/\//\\/g')"
fi

exit