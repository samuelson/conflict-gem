conflict-gem
============

Recursively searches gem dependencies and subdependencies to find possible conflicts

Takes a list of gems and versions in the format gem,version separated by spaces
The version string can be 0 for any version, a version number such as 0.1.0, or a string such as "~> 1.2.3"

Currently returns the versions in a format that can be easily pasted into a particular puppet manifest
used for getting local caches of gems in the puppetlabs learning VM.

Example Usage
=============

To find mutual dependencies for adressable 2.2.6, r10k 1.0 or greater, and any compatible version of rake and puppet-lint:
```
./conflict-gem.rb rake,0 r10k,">= 1.0.0" puppet-lint,0 addressable,2.2.6
```
