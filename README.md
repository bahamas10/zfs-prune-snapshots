ZFS Prune Snapshots
===================

Remove snapshots from one or more zpools that match given criteria

Examples
--------

Remove snapshots older than a week across all zpools

    zfs-prune-snapshots 1w

Same as above, but with increased verbosity and without
actually deleting any snapshots (dry-run)

    zfs-prune-snapshots -vn 1w

Remove snapshots older than 3 weeks on tank1 and tank2/backup.
Note that this script will recurse through *all* of tank1 and
*all* datasets below tank2/backup

    zfs-prune-snapshots 3w tank1 tank2/backup

Remove snapshots older than a month on the zones pool that start
with the string "autosnap_"

    zfs-prune-snapshots -p 'autosnap_' 1M zones

Timespec
--------

The first argument denotes how old a snapshot must be for it to
be considered for deletion - possible specifiers are

- `s` seconds
- `m` minutes
- `h` hours
- `d` days
- `w` weeks
- `M` months
- `y` years

Usage
-----

    usage: zfs-prune-snapshots [-hnv] [-p <prefix] <time> [[dataset1] ...]

    remove snapshots from one or more zpools that match given criteria

    examples
        # zfs-prune-snapshots 1w
        remove snapshots older than a week across all zpools

        # zfs-prune-snapshots -vn 1w
        same as above, but with increased verbosity and without
        actually deleting any snapshots (dry-run)

        # zfs-prune-snapshots 3w tank1 tank2/backup
        remove snapshots older than 3 weeks on tank1 and tank2/backup.
        note that this script will recurse through *all* of tank1 and
        *all* datasets below tank2/backup

        # zfs-prune-snapshots -p 'autosnap_' 1M zones
        remove snapshots older than a month on the zones pool that start
        with the string "autosnap_"

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
        -p <prefix>    snapshot prefix string to match
        -q             quiet, do not printout removed snapshots
        -v             increase verbosity
        -V             print the version number and exit

License
-------

MIT License
