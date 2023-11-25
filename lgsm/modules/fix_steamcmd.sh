#!/bin/bash
# LinuxGSM fix_steamcmd.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with SteamCMD.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# function to simplify the steamclient.so fix
# example
# fn_fix_steamclient_so 32|64 (bit) "${serverfiles}/linux32/"
fn_fix_steamclient_so() {
	# $1 type of fix 32 or 64 as possible values
	# $2 as destination where the lib will be copied to
	if [ "$1" == "32" ]; then
		# get md5sum of steamclient.so
		if [ -f "${2}/steamclient.so" ]; then
			steamclientmd5=$(md5sum "${2}/steamclient.so" | awk '{print $1;}')
		fi

		# get md5sum of steamclient.so from steamcmd
		if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
			steamcmdsteamclientmd5=$(md5sum "${HOME}/.steam/steamcmd/linux32/steamclient.so" | awk '{print $1;}')
		elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
			steamcmdsteamclientmd5=$(md5sum "${steamcmddir}/linux32/steamclient.so" | awk '{print $1;}')
		elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" ]; then
			steamcmdsteamclientmd5=$(md5sum "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" | awk '{print $1;}')
		fi

		# steamclient.so x86 fix.
		if [ ! -f "${2}/steamclient.so" ] || [ "${steamcmdsteamclientmd5}" != "${steamclientmd5}" ]; then
			fixname="steamclient.so x86"
			fn_fix_msg_start
			if [ ! -d "${2}" ]; then
				mkdir -p "${2}"
			fi
			if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
				cp "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${2}/steamclient.so"
			elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
				cp "${steamcmddir}/linux32/steamclient.so" "${2}/steamclient.so"
			elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" ]; then
				cp "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" "${2}/steamclient.so"
			fi
			fn_fix_msg_end
		fi
	elif [ "$1" == "64" ]; then
		# get md5sum of steamclient.so
		if [ -f "${2}/steamclient.so" ]; then
			steamclientmd5=$(md5sum "${2}/steamclient.so" | awk '{print $1;}')
		fi

		# get md5sum of steamclient.so from steamcmd
		if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
			steamcmdsteamclientmd5=$(md5sum "${HOME}/.steam/steamcmd/linux64/steamclient.so" | awk '{print $1;}')
		elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
			steamcmdsteamclientmd5=$(md5sum "${steamcmddir}/linux64/steamclient.so" | awk '{print $1;}')
		elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux64/steamclient.so" ]; then
			steamcmdsteamclientmd5=$(md5sum "${HOME}/.local/share/Steam/steamcmd/linux64/steamclient.so" | awk '{print $1;}')
		fi

		# steamclient.so x86_64 fix.
		if [ ! -f "${2}/steamclient.so" ] || [ "${steamcmdsteamclientmd5}" != "${steamclientmd5}" ]; then
			fixname="steamclient.so x86_64"
			fn_fix_msg_start
			if [ ! -d "${2}" ]; then
				mkdir -p "${2}"
			fi
			if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
				cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${2}/steamclient.so"
			elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
				cp "${steamcmddir}/linux64/steamclient.so" "${2}/steamclient.so"
			elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux64/steamclient.so" ]; then
				cp "${HOME}/.local/share/Steam/steamcmd/linux64/steamclient.so" "${2}/steamclient.so"
			fi
			fn_fix_msg_end
		fi
	fi
}

# Helps fix: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
steamsdk64="${HOME}/.steam/sdk64"
steamclientsdk64="${steamsdk64}/steamclient.so"
# remove any old unlinked versions of steamclient.so
if [ -f "${steamclientsdk64}" ]; then
	if [ "$(stat -c '%h' "${steamclientsdk64}")" -eq 1 ]; then
		fixname="steamclient.so sdk64 - remove old file"
		fn_fix_msg_start
		rm -f "${steamclientsdk64}"
		fn_fix_msg_end
	fi
fi

# place new hardlink for the file to the disk
if [ ! -f "${steamclientsdk64}" ]; then
	fixname="steamclient.so sdk64 hardlink"
	fn_fix_msg_start
	if [ ! -d "${steamsdk64}" ]; then
		mkdir -p "${steamsdk64}"
	fi
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		ln "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${steamclientsdk64}"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		ln "${steamcmddir}/linux64/steamclient.so" "${steamclientsdk64}"
	elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux64/steamclient.so" ]; then
		ln "${HOME}/.local/share/Steam/steamcmd/linux64/steamclient.so" "${steamclientsdk64}"
	else
		fn_print_fail_nl "Could not copy any steamclient.so 64bit for the gameserver"
	fi
	fn_fix_msg_end
fi

# Helps fix: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
steamsdk32="${HOME}/.steam/sdk32"
steamclientsdk32="${HOME}/.steam/sdk32/steamclient.so"
if [ -f "${steamclientsdk32}" ]; then
	if [ " $(stat -c '%h' "${steamclientsdk32}")" -eq 1 ]; then
		fixname="steamclient.so sdk32 - remove old file"
		fn_fix_msg_start
		rm -f "${steamclientsdk32}"
		fn_fix_msg_end
	fi
fi

# place new hardlink for the file to the disk
if [ ! -f "${steamclientsdk32}" ]; then
	fixname="steamclient.so sdk32 link"
	fn_fix_msg_start
	if [ ! -d "${steamsdk32}" ]; then
		mkdir -p "${steamsdk32}"
	fi
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		ln "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${steamclientsdk32}"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		ln "${steamcmddir}/linux32/steamclient.so" "${steamclientsdk32}"
	elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" ]; then
		ln "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" "${steamclientsdk32}"
	else
		fn_print_fail_nl "Could not copy any steamclient.so 32bit for the gameserver"
	fi
	fn_fix_msg_end
fi

# steamclient.so fixes
if [ "${shortname}" == "ahl" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "ark" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
	fn_fix_steamclient_so "64" "${serverfiles}/ShooterGame/Binaries/Linux"
elif [ "${shortname}" == "arma3" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "ats" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "av" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "bb" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "bb2" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "32" "${serverfiles}/bin"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "bd" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "bmdm" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/bin"
elif [ "${shortname}" == "bo" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
	fn_fix_steamclient_so "32" "${serverfiles}/BODS_Data/Plugins/x86"
	fn_fix_steamclient_so "64" "${serverfiles}/BODS_Data/Plugins/x86_64"
elif [ "${shortname}" == "bs" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
	fn_fix_steamclient_so "64" "${serverfiles}/bin/linux64"
elif [ "${shortname}" == "bt" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "btl" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "ck" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "col" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "cmw" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "32" "${executabledir}/lib"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
	fn_fix_steamclient_so "32" "${serverfiles}/Binaries/Linux/lib"
elif [ "${shortname}" == "cs" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "cscz" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "ct" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "dab" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "32" "${serverfiles}/bin"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "dayz" ]; then
	fn_fix_steamclient_so "64" "${serverfiles}"
elif [ "${shortname}" == "dmc" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "dod" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "dodr" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/Dragons/Binaries/Linux"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "dods" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/bin"
elif [ "${shortname}" == "doi" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "dst" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
	fn_fix_steamclient_so "32" "${serverfiles}/bin/lib32"
	fn_fix_steamclient_so "64" "${serverfiles}/bin64/lib64"
elif [ "${shortname}" == "dys" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/bin/linux32"
elif [ "${shortname}" == "eco" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "em" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "gmod" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "hldm" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "hw" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "kf" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/System"
elif [ "${shortname}" == "ins" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
elif [ "${shortname}" == "inss" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
elif [ "${shortname}" == "ios" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
elif [ "${shortname}" == "kf2" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "ns" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
elif [ "${shortname}" == "ns2c" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/ia32"
elif [ "${shortname}" == "opfor" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
elif [ "${shortname}" == "pz" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/linux32"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "pvr" ]; then
	fn_fix_steamclient_so "64" "${executabledir}"
elif [ "${shortname}" == "ricochet" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "tu" ]; then
	fn_fix_steamclient_so "64" "${executabledir}"
elif [ "${shortname}" == "unt" ]; then
	fn_fix_steamclient_so "64" "${serverfiles}"
elif [ "${shortname}" == "wurm" ]; then
	fn_fix_steamclient_so "64" "${serverfiles}/nativelibs"
fi
