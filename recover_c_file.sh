#!/bin/bash
# -*- coding: utf-8 -*-

# recover_c_file.sh
# recover an accidently written-over text file

# Chris Reid <spikeysnack@gmail.com>

# search raw disc bytes for a file containing a string and recover it.
# this is for text file accidently removed or overwritten.
# It only works well if you run it shortly after you realize
# what happened and don't save a bunch of stuff to disk in between.



## GLOBALS
set -e
OLDIFS=$IFS
DEBUG=
DEBUGFUNCTIONS=1

## debug functions

# debug_fname
#  @param 
#           string f function name
#  @output
#          int return val
#
debug_fname()
{
	local f="$1"

	[[ $DEBUG && $DEBUGFUNCTIONS ]] && >&2 echo "~~~~~~ [$f]()] ~~~~~~"

	return 0
}

# File Info
TITLE="recover_c_file"
FILE="recover_c_file.sh"
MIMETYPE="text/plain"
CHARSET="utf-8"
FILETYPE="Bash Script"
DATE="20 Mar 2022"
VERSION="1.2"
STATUS="release-candidate"
readonly TITLE FILE MIMETYPE CHARSET FILETYPE
#

## DEFAULTS
STRING=                     ## required
DEV=                        ## required
PRE=50                      ## optional
POST=100                    ## optional
MATCHES=5                   ## optional
R_DIR="./"                  ## optional
R_FILE="recovered.txt"      ## optional
RFILE="${R__DIR}/${R_FILE}"
TEST=
#


## requirements
requires="getopt findmnt nice tr pv grep strings"
getopt_bin=$(which getopt)
findmnt_bin=$(which findmnt)
nice_bin=$(which nice)
tr_bin=$(which tr)
pv_bin=$(which pv)
grep_bin=$(which grep)
strings_bin=$(which strings)


## user config  ##
LC_ALL="${LC_ALL:-${LANG}}"
USE_COLORS=1
CLEARSCREEN=1
TABS=4
# TABS=8  # the default but who uses it anymore?
niceness=10   # slightly less than full
ostream=1    # stdout
# ostream=2  # stderr


## set ups ##
tabs -${TABS}  # set the tabs
numcolors=$(tput colors)
COLORS_DONE=
COLORS=${COLORS:-${USE_COLORS}}

## credits ##
declare -A authors # 
declare -A license # 
declare -A credits #  associative arrays

# authors
authors[fimdmnt]="Karel Zak"
authors[getopt]="Frodo Looijaard"
authors[grep]="Ken Thompson"
authors[nice]="David MacKenzie"
authors[pv]="Andrew Wood"
authors[strings]="Kernighan & Ritchie"
authors[tr]="Jim Meyering"
readonly authors

# license
declare GPL="GNU GPL 2.0"
declare FSW="free software"
license[grep]="${GPL} ${FSW}"
license[fimdmnt]="${GPL} ${FSW}"
license[noncommercial]="Free for all non-commercial purposes."
license[mod]="allowed but original attribution must be included."
license[nice]="${GPL} ${FSW}"
license[pv]="ARTISTIC 2.0 ${FSW}"
license[strings]="${GPL} ${FSW}"
license[tr]="${GPL} ${FSW}"
license[url]="https://creativecommons.org/licenses/by-sa/3.0/"

_norm="$(tput sgr0)" # need this before
_cyan="$(tput setaf 6)"

license[summary]=$(cat <<EOF
You are free to:

${_cyan}Share${_norm} — copy and redistribute the material in any medium or format

${_cyan}Adapt${_norm} — remix, transform, and build upon the material for any purpose,
even commercially.

${_cyan}Attribution${_norm} — You must give appropriate credit,
provide a link to the license, and indicate if changes were made.
You may do so in any reasonable manner,
but not in any way that suggests the licensor endorses you or your use.

${_cyan}ShareAlike${_norm} — If you remix, transform, or build upon the material,
you must distribute your contributions under the same license
as the original.

${_cyan}Revocation${_norm} — The licensor cannot revoke these freedoms as
long as you follow the license terms.

${_cyan}No Additional Restrictions${_norm} — You may not apply legal terms
or technological measures that legally restrict others
from doing anything the license permits.
EOF
	   )
unset _norm
unset _cyan

readonly license

# credits
credits[author]="Chris Reid"
credits[authors]=$(printf "%s\n" "${authors[@]}")
credits[category]="file recovery"
credits[copyright]="Copyright 2022"
credits[country]="United States of America"
credits[date]="${DATE}"
credits[email]="spikeysnack@gmail.com"
credits[file]="${FILE}"
credits[maintainer]="${credits[author]}"
credits[note]="must be run as super-user"
credits[status]="${STATUS}"

credits[title]="${TITLE}"
credits[version]="${VERSION}"

readonly credits



## check_for_colors
#  @param (none)
#
#  @output
#         string number of colors
#
check_for_colors()
{
	# see if it supports colors...
	ncolors=$(tput colors)
	echo "${ncolors}"
	
	debug_fname "check_for_colors"
	return 0
}


## init_colors
#  set color vars
#  @param (none)
#
# @output
#         (none)
#
# initialize color term variables
init_colors()
{
  	[[ $COLORS_DONE ]] && return 0  #  save time
	
	if [[ ${USE_COLORS} ]] && [ $(check_for_colors) -gt 4 ]
	then
		# text attributes
		normal="$(tput sgr0)"
		bold="$(tput bold)"
		underline="$(tput smul)"
		nounderline="$(tput rmul)"
		standout="$(tput smso)"
		nostandout="$(tput rmso)"
		reverse="$(tput rev)"

		# text fg colors
		black="$(tput setaf 0)"
		red="$(tput setaf 1)"
		green="$(tput setaf 2)"
		yellow="$(tput setaf 3)"
		blue="$(tput setaf 4)"
		magenta="$(tput setaf 5)"
		cyan="$(tput setaf 6)"
		white="$(tput setaf 7)"

		# text bg colors
		bgred="$(tput setab 1)"
		bggreen="$(tput setab 2)"
		bgyellow="$(tput setab 3)"
		bgblue="$(tput setab 4)"
		bgmagenta="$(tput setab 5)"
		bgcyan="$(tput setab 6)"
		bgwhite="$(tput setab 7)"
		bgblack="$(tput setab 0)"
		COLORS_DONE=1
		COLORS=1
	fi

	debug_fname "init_colors"

	return 0
}

## show_license
#
#  @param  (none)
#
#  @output
#         print license vars
#
#  display license info
show_license()
{

	[[ $CLEARSCREEN ]] && tput clear

	echo "${green}"
	printf '=%.0s' {1..80}
	echo "${normal}"

	echo "${bold}"
	echo "${TITLE}${normal}"

	echo "${bold}${green}"
	echo "Author: ${credits[author]}"
	echo "${magenta}"
	echo "License: ${license[noncommercial]}"
	echo "${blue}"
	echo "License URL: ${license[url]}"
	echo "${magenta}"
	echo "Modification: ${license[mod]}"
	echo "${white}"
	echo -e "${license[summary]}\n"
	echo -e "${bold}${yellow}--- ${credits[note]} ---\n"
	echo "${green}"
	printf '=%.0s' {1..80}
	echo "${normal}"

	debug_fname "show_license"
	
	return 0
}


## show_version
#
#  @param
#         int S output stream 
#             ( stdout=1, stderr=2)  
#  @output
#
# display version info
show_version()
{
	local default=1
	S=${1:-$default}

	local y="${yellow}"
	local n="${normal}"
	
	>&${S} echo "${bold}${y}${credits[title]}${n}"
	>&${S} echo  "${n}version: ${y}${VERSION}${n}"
	>&${S} echo  "date: ${yellow}${DATE}"
	>&${S} echo  "${n}status: ${y}${STATUS}${n}"
	>&${S} echo  "${n}license: ${y}${license[noncommercial]}${n}"
	>&${S} echo  "${n}copyright: ${y}${credits[copyright]} ${credits[author]} <${credits[email]}>${n}"
	>&${S} echo

	debug_fname "show_version"
	return 0
}


## show_credits
#
#  @param  
#        int S output stream ( stdout=1, stderr=2)
#  @output
#         print version vars
#
# display credits
show_credits()
{
	local default=1
	S=${1:-$default}

	local y="${yellow}"
	local n="${normal}"
	
	show_version ${S}
	
	printf "${y}%-20s\t%-20s\t%-s\n${n}" "program" "author" "license"

	printf "${cyan}"
	for C in ${!authors[@]}
	do
		>&${S} printf "%-20s\t%-20s\t%-s\n"  "${C}" "${authors[$C]}" "${license[$C]}"
	done
	
 	printf "${n}\n"

	debug_fname "show_credits"

	return 0
}


## usage
#  @param
#         int S output stream 
#             ( stdout=1, stderr=2)  
#
#  @output
#     string usage info
#
usage ()
{
	local default=1
	Stream=${1:-$default}

	[[ $CLEARSCREEN ]] && tput clear

   cat <<EOF
${bold}${yellow}
usage: <sudo> $0 options

   ${white}sudo  ${blue}bash  ${green}recover_c_file.sh   <options>

   ${bold}${white}${underline}(must be run as super-user to read device)${normal}

   ${bold}${magenta}required:${normal}
   ${bold}-s|--string ${underline}"string"${nounderline}   string to search for${normal}
   ${bold}-d|--dev    ${underline}<device>${nounderline}   block device to scan${normal}

   ${bold}${magenta}optional:${normal}                                              (defaults)
   -p|--pre         <num>     how many lines before string   (50)
   -P|--post        <num>     how many lines after string    (100)
   -m|--matches     <num>     how many times to match        (5)
   -D|--output-dir  "string"  dir to save file to            (./)
   -o|--output-file "string"  filename to save to            ("recovered.txt")
   -c|--color       "string"  use color (yes/no/0/1)         (yes)

   ${bold}${magenta}info:${normal}
   -h|--help  output this message
   -t|--test  print out args read, don't start scanning
   -v|--version version info
   -l|--license license info${normal}

   ${bold}${magenta}description:
	  ${yellow}Search the device you specify
	  and create a file called 'recovered.txt'
	  preferrably on another file system.
	  The recovered file will contain:
	  50 lines pre-match, matching line, 100 lines post-match.
	  repeats 5 times, appending.${normal}

${yellow}    example:
${bold}${blue}
	sudo bash recover_c_file.sh --help --string "a string" --dev "/dev/sda1" \\
	--pre 50 --post 100 --matches 5 --output-dir /tmp --output-file recovered.c.txt
${normal}
EOF

   debug_fname "usage"
   return 0
}


## check_requirements
#
#  @param  string array 
#                 external programs
#  @output
#         0 no error
#         1 problem
#
# do binaries exist?

check_requirements()
{
	local OUT
	local L
	local R

	L=("${1}")

	for R in ${L[@]}
	do
		P=$(which "${R}")
		[[ ! "${P}" ]] && OUT="${R}" &&  break
	done

	if [[ $OUT ]]
	then
		>&2 echo "${red}A required binary [${OUT}] was not found in the PATH. ${normal}"

		>&2 echo "${yellow}Please find it and put its dir in the PATH variable and try again.${normal}"

		for F in ${L[@]}
		do
			if [ "X${OUT}" == "X${F}" ]
			then
				avail="should be available in a package with the your distro."
				>&2 echo "${bold}${white}${F} ${green}${avail}.${norm}"
			fi
		done

		return 1

	fi
	
	debug_fname "check_requirements"
	return 0
}


## check_options
#
#  @param  array
#
#  @output
#         0 all options present
#         1 problem with options
#
# must have all 8
check_options()
{
	local -a arglist; # string array

	arglist=(
	"$STRING"
	"$DEV"
	"$PRE"
	"$POST"
	"$MATCHES"
	"$COLORS"
	"$R_DIR"
	"$R_FILE"
	"$RFILE"
	)

	argnames=(
	"STRING"
	"DEV"
	"PRE"
	"POST"
	"MATCHES"
	"COLORS"
	"R_DIR"
	"R_FILE"
	"RFILE"
	)

	local -i argc

	argc=$((${#arglist[@]}))

	if [ $argc -ne 9 ] ; then

		>&2 echo "check_options not enough args"
		return 1
	fi

	check_colors

	for ((i=0 ; i<$((argc)) ; i++))
		{
		arg="${arglist[$i]}"
		aname="${argnames[$i]}"

			if [ -z "${arg}" ] ; then
			>&2 echo "${bold}${red}ERROR ${white}${aname} ${red}is not set${normal}"
			return 1
			fi
		}

	debug_fname "check_options"
	return 0
}

## options
#
#  @param  string array
#
#  @output
#         0 all options processed
#         1 problem with options
#
#  @requires
#        (none)
#
# must have all 8

# get program options
options()
{
	local -A OPTIONS
	local -a optarglist
	local -a singleopts
	local -a optlist
	local shortopts
	local longopts
	local opts
	local nargs

	singleopts=(
		"test"
		"help"
		"license"
		"version"
		"credits"
	)

	optarglist=(
		"color"
		"string"
		"dev"
		"pre"
		"post"
		"matches"
		"output-dir"
		"output-file"
	)

	optlist=("${singleopts[@]}" "${optarglist[@]}" )

  shortopts="c:thlvs:d:p:P:m:D:o:"
  longopts="$(printf "%s," "${singleopts[@]}")"
  longopts="${longopts}$(printf "%s:," "${optarglist[@]}")"
  # printf "long options: %s\n" "${longopts}"

# read arguments
  opts=$( ${getopt_bin} -s bash -a \
		--longoptions "${longopts}" \
		--name "$(basename "$0")" \
		--options "${shortopts}" \
		-- "$@" )

  eval set -- $opts

  while [[ $# -gt 0 ]] ; do

	  case "$1" in

		  -c|--color)
			  COLORS=$2
			  shift 2
			  ;;

		  -t|--test)
			  TEST=1
			  shift 1
			  ;;

		  --credits)
			  CREDITS=1
			  shift 1
			  ;;

		  -h|--help)
			  HELP=1
			  shift 1
			  ;;

		  -l|--license)
			  LICENSE=1
			  shift 1
			  ;;

		  -v|--version)
			  SHOWVERSION=1
			  shift 1
			  ;;

		  -s|--string)
			  STRING=$2
			  shift 2
			  ;;

		  -d|--dev)
			  DEV=$2
			  shift 2
			  ;;

		  -p|--pre)
			  PRE=$2
			  shift 2
			  ;;

		  -P|--post)
			  POST=$2
			  shift 2
			  ;;

		  -m|--matches)
			  MATCHES=$2
			  shift 2
			  ;;

		  -D|--output-dir)
			  R_DIR=$2
			  shift 2
			  ;;

		  -o|--output-file)
			  R_FILE=$2
			  shift 2
			  ;;



		  *)
			  break
			  ;;
	  esac

  done

  if [ $? -ne 0 ] ; then
	  >&2 echo "${red}getopts failed  with ${?}${normal}"
	  return 1;
  fi

	OPTIONS[test]=${TEST}
	OPTIONS[help]=${HELP}
	OPTIONS[license]=${LICENSE}
	OPTIONS[version]=${VERSION}
	OPTIONS[color]=${COLORS}
	OPTIONS[string]=${STRING}
	OPTIONS[dev]=${DEV}
	OPTIONS[pre]=${PRE}
	OPTIONS[post]=${POST}
	OPTIONS[matches]=${MATCHES}
	OPTIONS[output-dir]=${R_DIR}
	OPTIONS[output-file]=${R_FILE}
	OPTIONS[credits]=${CREDITS}

	ARG_ERR=

	# >&2 echo "OPTIONS:"
	# for (( i=0; i < ${#OPTIONS[@]} ; i++))
	# do
	#	a="${optlist[$i]}"
	#	>&2 echo "${a}: ${OPTIONS[$a]}"
	# done

	# check for missing args
	for (( i=0; i < ${#OPTIONS[@]} ; i++))
	do
		a="${optlist[$i]}"
		if [ "${OPTIONS[$a]:0:1}" = "-" ] ; then
			ARG_ERR=1
			>&2 echo "${red}missing arg?${normal}"
			>&2 echo "${bold}${white}${optlist[$i]}${cyan} should not be ${white}\"${OPTIONS[$a]}\"${normal}"
		fi

	done

	[[ ${ARG_ERR} ]] &&	return 1

	# info and color options

	[[ ${COLORS} ]]       && check_colors
	[[ ${USE_COLORS} ]]   && init_colors
	
	[[ ${HELP} ]]         && usage ${ostream}            && exit 0
	[[ ${CREDITS} ]]      && show_credits ${ostream}     && exit 0
	[[ ${LICENSE} ]]      && show_license ${ostream}     && exit 0
	[[ ${SHOWVERSION} ]]      && show_version ${ostream}     && exit 0

	debug_fname "options"
	
	return 0
}

# check_separate_mount_points
#  @param 
#         string dev device
#         string outfile  output file
#  @output
#      int return val       
#
# make sure output dev and output file
# are on separate partitions
# or verify with user
check_separate_mount_points()
{
	local dev="${1}"
	local outfile="${2}"

	local mount1
	local mount2
	local same_mount

	if [ -b "${dev}" ] ; then mount1="${dev}" ; fi

	if [ -b "${dev}" ] && [ -f "${outfile}" ] ; then
		mount2="$( ${findmnt_bin} -n -o SOURCE --target "${outfile}")"
	else
		return 1
	fi

	# >&2 echo  "${dev}     mount1: ${mount1}"
	# >&2 echo  "${outfile} mount2: ${mount2}"


	if [ "X${mount1}" == "X${mount2}" ] ;then
		same_mount=1
	fi

	cat <<EOF
${bold}${red}
==================================================================================
WARNING: ${white}${outfile} ${red} is on the same device (${white}${dev}${red}) you are scanning.
==================================================================================

${bold}${cyan}There is a possibility of overwiting the data you want to recover.
It is safer to output the results of the scan to a file on another mount point.
${normal}
EOF
	read -p "Proceed anyway? [yN]" proceed
	proceed="${proceed:-no}"
	
	if [ "X${proceed}" == "Xy" ] ; then
		return 0
	else
		return 1
	fi


	debug_fname "check_separate_mount_points"

	return 0
}

# recover_file
#  @param  
#          string dev      device
#          string "string" search string
#          string rfile    output file
#          int    pre       lines before
#          int    post      lines after
#          int   matches    matches
#  @output
#         int return val       
#
# scan device for string
recover_file()
{
	local dev="${1}"
	local string="${2}"
	local rfile="${3}"
	local -i pre
	local -i post
	pre=${4}
	post=${5}
	matches=${6}


	# oops
	if [ $# -lt 6 ] ; then
	>&2 echo "${red}not enough args${normal}"
	return 1
	fi

	# test mode
	if [[ $TEST ]] ; then
		echo "TEST MODE"
	fi
	fmt="%-16s\t%s%s%s\n" # 16 then tab then string
	echo "${cyan}=========================================${normal}"
	printf "${fmt}"  "device:"       "${bold}"  "${dev}"     "${normal}"
	printf "${fmt}"  "string:"       "${bold}"  "${string}"  "${normal}"
	printf "${fmt}"  "output file:"  "${bold}"  "${rfile}"   "${normal}"
	printf "${fmt}"  "lines before:" "${bold}"  "${pre}"     "${normal}"
	printf "${fmt}"  "lines after:"  "${bold}"  "${post}"    "${normal}"
	printf "${fmt}"  "matches:"      "${bold}"  "${matches}" "${normal}"
	echo "${cyan}=========================================${normal}"
	echo

	# test mode -- don't actually do it
	if [[ $TEST ]] ; then
		return 1
	fi

	# OK we are doing this


	# don't overwrite recovered.txt,
	# make recovered.txt,1 .. recovered.txt.10
	if [ -f "${rfile}" ] ; then
		for((i=1; i<11; i++ ))
		   {
			   if [ ! -f "${rfile}.${i}" ] ; then
				   rfile="${rfile}.${i}"
				   break
			   fi
		   }

	fi

	touch "${rfile}"    # complains if file does not exist (why tho?)

	check_separate_mount_points "${dev}" "${rfile}"

	# here we use some programs to
	# filter garbage
	# search for the string
	# output ascii to the file

	# try to be nice
	nice -n ${niceness} \
	  ${tr_bin} -s "\0" "\n" < "${dev}" \
	| ${pv_bin} -t -a -b \
	| ${grep_bin}  -i -a -B${pre} -A${post} -m ${MATCHES} "${string}" \
	| ${strings_bin} -n 1 > "${rfile}"


	return 0
}

#check device
#  @param  
#          string dev      device
#  @output
#         int return val       
#
#  make sure device is readable
#  should be a block device ( /dev/sdX partition or /dev/mapper entry)

check_device ()
{
	local dev
	dev="${1}"

	#fatal conditions

	if [ ! -e ${dev} ] ; then
	echo >&2 "${bold}${white}${dev}${red} does not exist in this environment.${normal}"
	return 1
	fi


	# unreadable
	if [ ! -r ${dev} ] ; then
	echo >&2 "${bold}${white}${dev}${red} is not readable by ${real_user}${normal}"
	return 1
	fi

	local real_user

	if [ $SUDO_USER ]; then
		real_user=$SUDO_USER
	else
		real_user=$(whoami)
	fi



	if [ -b ${dev} ] ; then

	(read -n 1 < ${dev} && return 0) || return 1

	else
	echo >&2 "${bold}${white}${dev} ${red}is not a block device.${normal}"
	return 1
	fi

	debug_fname "check_device"
	return 0
}

# check_colors
#  @param  none
#
#  @output
#         int return val       
#
# check if colors are used
check_colors()
{
	
	local colors="${COLORS}"

	colors=${colors:-yes}

	[[ "${colors}" =~ ^(yes|y|Y|1) ]] && USE_COLORS=1

	[[ "${colors}" =~ ^(no|n|N|0)  ]] && unset USE_COLORS

	debug_fname "check_colors"
	
	return 0
}


# check_root
#
#  @param  none
#
#  @output
#         int return val       
#
# check we are running as super user
check_root()
{
   
	# ref: https://askubuntu.com/a/30157/8698
	if [ !  $(id -u) -eq 0 ] ; then
		echo "${bold}${yellow}The script need to be run as root.${normal}" >&2
		return 1
	else
		return 0
	fi

	debug_fname "check_root"
	return 0
}


# check_sane_args
#  @param  none
#
#  @output
#         int return val       
#
# check out arguments are OK
check_sane_args()
{
	local r="${red}"
	local y="${yellow}"
	local n="${normal}"
	
	
	## args = STRING DEV PRE POST
	#         MATCHES R_DIR  R_FILE  RFILE
    #        
	if [  ${#STRING}  -le 4] ; then
		>&2 echo "${r}ERROR Search string is too short. ${n}"
		return 1
	fi

	if [  ! -b "${DEV}" ] ; then
		>&2 echo "${r}ERROR ${DEV} is not a valid device name. ${n}"
		return 1
	fi

	
	if [ $PRE -le  10 ] ; then
	>&2 echo "${r}ERROR --pre must be${normal} >= 10 ${n}"
	return 1
	fi

	if [ $POST -le  49 ] ; then
	>&2 echo "${r}ERROR --pre must be${normal} <= 50 ${n}"
	return 1
	fi

	if [ ${#MATCHES} -le 8 ] ; then
	>&2 echo "${r}ERROR match  must be ${n}>= 8 chars"
	return 1
	fi

	if [ ! -d  "${R_DIR}" ] ; then
	>&2 echo "${r}ERROR ${yellow}${R_DIR} ${red}is not a directory${n}"
	return 1
	fi

	# touch check
	touchOK=$(touch "${R_DIR}/touch.check")

	if  [ $touchOK -ne 0] || [! -w  "${R_DIR}/touch.check}" ] ; then

		>&2 echo "${r}ERROR ${y}${R_DIR} ${r}is not writable by ${n}${real_user}"
		return 1
	else
		rm "${R_DIR}/touch.check"
	fi

	debug_fname "check_sane_args"
	
	return 0
}




# check_return
#  @param  
#          string funcname
#          int    val
#  @output
#          int return val       
#
# makes sure return value is 0
check_return()
{
	local funcname
	local -i val

	funcname="${1}"
	val="${2}"

	if [ $((val)) -ne 0 ] ; then
		>&2 echo "${bold}${red}${funcname} failed with ${white}${val}${normal}"
		exit $((val))
	fi

	debug_fname "check_return"
	return 0
	
}


# menu
#  @param  
#     
#
#  @output
#         
#
#
# 
menu()
{
 >&2 echo "not implemented yet"
}



# main
#  @param  
#         strings command line arguments
#
#  @output
#         int return val       
#
#
# this is where processing starts
main()
 {
	 # check requirements, options, and arguments
	 
	 check_requirements "${requires}"
	 check_return "check_requirements" "$?"

	 check_root
	 check_return "check_root" "$?"

	 options "$@"
	 check_return "options" "$?"

	 check_options
	 check_return "check_options" "$?"

	 check_device "${DEV}"
	 check_return "check_device" "$?"
	 
	 check_colors
	 check_return "check_colors" "$?"

	 
	 # OK we have all the correct arguments
	 echo
	 echo "${bold}${blue}OK this may take some time.${normal}"
	 echo

	# verify user intentions
	 echo "${bold}${yellow}Do you wish to run this program? (yes/no/quit)${normal}"
	 echo
	select yn in "yes" "no" "quit"; do
		case $yn in
			yes) break
				 ;;

			no) return 1
				;;

			quit) return 0
				  ;;

			*) >&2 echo "${bold}${red}only type ${white}'1'${red}, ${white}'2'${red}, or ${white}'3'${red}. ${normal}"
			   ;;
		esac
	done

	# do the thing
	recover_file ${DEV} "${STRING}" "${RFILE}" ${PRE} ${POST} ${MATCHES}

	check_return "recover_file" "$?"

	if [ -f "${RFILE}" ] ; then

		size=$(ls -nl "${RFILE}" | awk '{print $5}' )

		if [ $? -eq 0 ] ; then
			echo "${bold}${green}recovered something  in  ${white}${RFILE} (${size} bytes)${normal}"
		else
			>&2 echo "${bold}${white}${RFILE} ${red}created, but there were errors${normal}"
			return 1
		fi

	else
		>&2 echo "$red}${RFILE} not created. sorry${normal}"
		return 1
	fi

	debug_fname "main"
	# all done
	return 0
 }


 main  "$@"

# final exit
printf "%s\n" "${normal}"


 # Local Variables:
 # mode: shell-script
 # tab-width: 4
 # End:

# vim: set noai ts=4 sw=4: ft=bash #

# END
