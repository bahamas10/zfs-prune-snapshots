ZFS-PRUNE-SNAPSHOTS 1 "NOV 2018" "User Commands"
================================================

NAME
----

`zfs-prune-snapshots` - Remove snapshots from one or more zpools that match
given criteria

SYNOPSIS
--------

`zfs-prune-snapshots [OPTIONS] <time> [[DATASET1] ...]`

DESCRIPTION
-----------

Remove snapshots from one or more zpools that match a criteria given over the
command line.

OPTIONS
-------

`-h`
  print this message and exit

`-n`
  dry-run, don't actually delete snapshots

`-p <prefix>`
  snapshot prefix string to match

`-q`
  quiet, do not printout removed snapshots

`-v`
  increase verbosity

`-V`
  print the version number and exit

`TIMESPEC`

The first argument denotes how old a snapshot must be for it to be considered
for deletion - possible specifiers are

  `s` seconds

  `m` minutes

  `h` hours

  `d` days

  `w` weeks

  `M` months

  `y` years

EXAMPLES
--------

`zfs-prune-snapshots 1w`
  Remove snapshots older than a week across all zpools

`zfs-prune-snapshots -vn 1w`
  Same as above, but with increased verbosity and without actually deleting any
  snapshots (dry-run)

`zfs-prune-snapshots 3w tank1 tank2/backup`
  Remove snapshots older than 3 weeks on tank1 and tank2/backup.  Note that this
  script will recurse through *all* of tank1 and *all* datasets below
  tank2/backup

`zfs-prune-snapshots -p 'autosnap_' 1M zones`
  Remove snapshots older than a month on the zones pool that start with the
  string `"autosnap_"`

BUGS
----

https://github.com/bahamas10/zfs-prune-snapshots

AUTHOR
------

`Dave Eddy <bahamas10> <dave@daveeddy.com> (https://www.daveeddy.com)`

SEE ALSO
--------

zpool(1M), zfs(1M)

LICENSE
-------

MIT License
