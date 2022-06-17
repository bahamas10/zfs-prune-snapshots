#!/usr/bin/env bash
#
# script to prune zfs snapshots over a given age
#
# Author: Dave Eddy <dave@daveeddy.com>
# Date: November 20, 2015
# License: MIT

VERSION='v1.5.0'

usage() {
	local prog=${0##*/}
	cat <<EOF
usage: $prog [-hnliqRvV] [-p <prefix>] [-s <suffix>] <time> [[dataset1] ...]

remove snapshots from one or more zpools that match given criteria

examples
    # $prog 1w
    remove snapshots older than a week across all zpools

    # $prog -vn 1w
    same as above, but with increased verbosity and without
    actually deleting any snapshots (dry-run)

    # $prog 3w tank1 tank2/backup
    remove snapshots older than 3 weeks on tank1 and tank2/backup.
    note that this script will recurse through *all* of tank1 and
    *all* datasets below tank2/backup

    # $prog -p 'autosnap_' 1M zones
    remove snapshots older than a month on the zones pool that start
    with the string "autosnap_"

    # $prog -s '_frequent' 2M tank
    remove snapshots older than two months on the tank pool that end
    with the string "_frequent"

    # $prog -i -p 'autosnap_' 1M zones
    remove snapshots older than a month on the zones pool that do not
    start with the string "autosnap_"

timespec
    the first argument denotes how old a snapshot must be for it to
    be considered for deletion - possible specifiers are

	s seconds
	m minutes
	h hours
	d days
	w weeks
	M months
	y years

options
    -h             print this message and exit
    -n             dry-run, don't actually delete snapshots
    -l             list only mode, just list matching snapshots names
		   without deleting (like dry-run mode with machine-parseable
		   output)
    -p <prefix>    snapshot prefix string to match
    -s <suffix>    snapshot suffix string to match
    -i             invert matching of prefix and suffix
    -q             quiet, do not printout removed snapshots
    -R             recursively delete, pass '-R' directly to 'zfs destroy'
    -v             increase verbosity
    -V             print the version number and exit
EOF
}

debug() {
	((verbosity >= 1)) && echo '>' "$@" >&2
	return 0
}

# get epoch time
get-epoch() {
	local time=0

	# try bash built-in, date(1), and finally perl
	time=$(printf '%(%s)T\n' -1 2>/dev/null)
	_validate-epoch "$time" 'printf' && return 0

	time=$(date '+%s' 2>/dev/null)
	_validate-epoch "$time" 'date'   && return 0

	time=$(perl -le 'print time' 2>/dev/null)
	_validate-epoch "$time" 'perl'   && return 0

	return 1
}

# validate a given epoch time for sanity
_validate-epoch() {
	local time=$1
	local method=$2
	local num_re='^([0-9]+)$'

	debug "checking time received from $method"

	if [[ -z $time ]]; then
		debug "time invalid - empty"
		return 1
	elif ! [[ $time =~ $num_re ]]; then
		debug "time invalid - not a number :: '$time'"
		return 1
	elif ! (( time > 0 )); then
		debug "time invalid - not greater than 0 :: '$time'"
		return 1
	fi

	debug "successfully got epoch time :: $time"
	echo "$time"
	return 0
}

# given a time in seconds, return the "human readable" string
human-time() {
	local seconds=$1
	if ((seconds < 0)); then
		((seconds *= -1))
	fi

	local times=(
	$((seconds / 60 / 60 / 24 / 365)) # years
	$((seconds / 60 / 60 / 24 / 30))  # months
	$((seconds / 60 / 60 / 24 / 7))   # weeks
	$((seconds / 60 / 60 / 24))       # days
	$((seconds / 60 / 60))            # hours
	$((seconds / 60))                 # minutes
	$((seconds))                      # seconds
	)
	local names=(year month week day hour minute second)

	local i
	for ((i = 0; i < ${#names[@]}; i++)); do
		if ((${times[$i]} > 1)); then
			echo "${times[$i]} ${names[$i]}s"
			return
		elif ((${times[$i]} == 1)); then
			echo "${times[$i]} ${names[$i]}"
			return
		fi
	done
	echo '0 seconds'
}

# convert bytes to a human-readable string
human-size() {
	local bytes=$1

	local times=(
	$((bytes / 1024 / 1024 / 1024)) # gb
	$((bytes / 1024 / 1024))        # mb
	$((bytes / 1024))               # kb
	$((bytes))                      # b
	)
	local names=(GB MB KB B)

	local i
	for ((i = 0; i < ${#names[@]}; i++)); do
		if ((${times[$i]} >= 1)); then
			echo "${times[$i]} ${names[$i]}"
			return
		fi
	done
	echo '0 B'
}

recursive=false
dryrun=false
listonly=false
verbosity=0
prefix=
suffix=
invert=false
quiet=false
while getopts 'hniqlRp:s:vV' option; do
	case "$option" in
		h) usage; exit 0;;
		n) dryrun=true;;
		i) invert=true;;
		l) listonly=true;;
		p) prefix=$OPTARG;;
		s) suffix=$OPTARG;;
		q) quiet=true; exec 1>/dev/null;;
		R) recursive=true;;
		v) ((verbosity++));;
		V) echo "$VERSION"; exit 0;;
		*) usage; exit 1;;
	esac
done
shift "$((OPTIND - 1))"

# extract the first argument - the timespec - and
# convert it to seconds
t=$1
time_re='^([0-9]+)([smhdwMy])$'
seconds=
if [[ $t =~ $time_re ]]; then
	# ex: "21d" becomes num=21 spec=d
	num=${BASH_REMATCH[1]}
	spec=${BASH_REMATCH[2]}

	case "$spec" in
		s) seconds=$((num));;
		m) seconds=$((num * 60));;
		h) seconds=$((num * 60 * 60));;
		d) seconds=$((num * 60 * 60 * 24));;
		w) seconds=$((num * 60 * 60 * 24 * 7));;
		M) seconds=$((num * 60 * 60 * 24 * 30));;
		y) seconds=$((num * 60 * 60 * 24 * 365));;
		*) echo "error: unknown spec '$spec'" >&2; exit 1;;
	esac
elif [[ -z $t ]]; then
	echo 'error: timespec must be specified as the first argument' >&2
	exit 1
else
	echo "error: failed to parse timespec '$t'" >&2
	exit 1
fi

shift

destroyargs=()
code=0
totalused=0
numsnapshots=0

if $recursive; then
	destroyargs+=('-R')
fi

if ! now=$(get-epoch); then
	echo 'failed to get epoch time' >&2
	exit 1
fi

if ! command -v zfs &>/dev/null; then
	echo "Error! zfs command not found. Are you on the right machine?" >&2
	exit 1
fi

# validate pools given, print warnings if not in quiet mode
pools=()
for arg in "$@"; do
	debug "checking '$arg' exists"

	error=$(zfs list "$arg" 2>&1 1>/dev/null)
	code=$?
	debug "zfs list '$arg' -> exited $code"

	if ((code == 0)) && [[ -z $error ]]; then
		debug "adding dataset '$arg'"
		pools+=("$arg")
	else
		msg="dataset '$arg' invalid: $error"
		debug "$msg"
		if ! $quiet; then
			echo "$msg" >&2
		fi
	fi
done

# it is an error if arguments were given but all datasets were invalidated
if [[ -n $1 && -z ${pools[0]} ]]; then
	echo 'no valid dataset names provided' >&2
	exit 1
fi

humanpools=${pools[*]}
humanpools=${humanpools:-<all>}

# first pass of the pools (to calculate totals and filter unwanted datasets
lines=()
while read -r line; do
	read -r creation used snapshot <<< "$line"

	# ensure optional prefix matches
	snapname=${snapshot#*@}
	if [[ -n $prefix ]]; then
		match=false
		if [[ $prefix == "${snapname:0:${#prefix}}" ]]; then
			match=true
		fi

		if $invert && $match; then
			debug "skipping $snapshot: does match prefix '$prefix'"
			continue
		fi

		if ! $invert && ! $match; then
			debug "skipping $snapshot: doesn't match prefix '$prefix'"
			continue
		fi
	fi

	# ensure optional suffix matches
	if [[ -n $suffix ]]; then
		match=false
		if [[ $suffix == "${snapname: -${#suffix}}" ]]; then
			match=true
		fi

		if $invert && $match; then
			debug "skipping $snapshot: does match suffix '$suffix'"
			continue
		fi

		if ! $invert && ! $match; then
			debug "skipping $snapshot: doesn't match suffix '$suffix'"
			continue
		fi
	fi

	# ensure snapshot is older than the cutoff time
	delta=$((now - creation))
	ht=$(human-time "$delta")
	if ((delta <= seconds)); then
		debug "skipping $snapshot: $ht old"
		continue
	fi

	# print the snapshot here if `-l`
	if $listonly; then
		echo "$snapshot"
	fi

	# we care about this dataset
	((totalused += used))
	((numsnapshots++))
	lines+=("$line")
done < <(zfs list -Hpo creation,used,name -t snapshot -r "${pools[@]}")

# finish if running with `-l`
if $listonly; then
	debug "running in '-l' mode - exiting here"
	exit 0
fi

humantotal=$(human-size "$totalused")

echo "found $numsnapshots snapshots ($humantotal) on pools: $humanpools"

# process snapshots found
i=0
for line in "${lines[@]}"; do
	read -r creation used snapshot <<< "$line"

	((i++))

	delta=$((now - creation))
	ht=$(human-time "$delta")
	hu=$(human-size "$used")

	if $dryrun; then
		echo -n '[dry-run] '
	fi

	echo "[$i/$numsnapshots] removing $snapshot: $ht old ($hu)"

	if ! $dryrun; then
		zfs destroy "${destroyargs[@]}" "$snapshot" || code=1
	fi
done

echo "removed $numsnapshots snapshots ($humantotal)"

exit "$code"
