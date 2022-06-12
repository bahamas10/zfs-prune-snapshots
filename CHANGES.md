ZFS Prune Snapshots Changes
===========================

Not Yet Released
----------------

(nothing yet)

`v1.5.0`
--------

- Sanity check datasets existence before running
 - `-q` will hide warnings for datesets not existing
 - Based on ([#9](https://github.com/bahamas10/zfs-prune-snapshots/pull/9))

`v1.4.1`
--------

- Allow snapshot datasets to contain spaces
  ([#18](https://github.com/bahamas10/zfs-prune-snapshots/pull/18))

`v1.4.0`
--------

- Show snapshot size (used) and number of snapshots processed (6e3891ddd1)
- Add list only option (`-l`) to just list datasets that match (e4ba772f2c)

`v1.3.0`
--------

- Add recursive deletion option (`-R`) (482420faba)

`v1.2.0`
--------

- Add zfs binary check ([#8](https://github.com/bahamas10/zfs-prune-snapshots/pull/8))
- Support inverting of prefix/suffix match (`-i`)
  ([#17](https://github.com/bahamas10/zfs-prune-snapshots/pull/17))

`v1.1.0`
--------

- Support suffix matching (`-s`) (e7aa72160f8)

`v1.0.1`
--------

- Allow passing DESTDIR (6de152a168)

`v1.0.0`
--------

- Initial Release
