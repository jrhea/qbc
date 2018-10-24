# Quorum By ConsenSys

Distribution of Quorum and associated projects, tested and supported by ConsenSys.

# Download

You can download binaries created with this project under:
   https://consensys.bintray.com/binaries/qbc/0.2/

# Docker images

You can pull Docker images for Quorum, Crux, and Constellation:
```
docker pull consensys-docker-qbc.bintray.io/qbc/quorum:0.2
docker pull consensys-docker-qbc.bintray.io/qbc/crux:0.2
docker pull consensys-docker-qbc.bintray.io/qbc/constellation:0.2
```

# Development

## Docker

Install:
```
  $> curl -fsSL get.docker.com -o get-docker.sh
  $> sh get-docker.sh
```

Config:
> Add /var/folders to Preferences > File Sharing


## Binaries

On a Mac machine, install required binaries for all projects:

`$> brew install berkeley-db leveldb libsodium maven haskell-stack`

Install the Glasgow Haskell Compiler:

`stack setup`

# Building

To clean, make tarballs, containers, and run tests
```
$> make all -j4
```

To build the tarball package for Linux, run:
```
$> make tarball-linux-64 -j4
```

To build the tarball package for Mac OS X, run:
```
$> make tarball-darwin-64 -j4
```

# Testing

Run:
```
$> docker test
```

# Release

Make sure the version is correct in the Makefile.

Run:
```
$> make BINTRAY_USER=<YOUR USERNAME> BINTRAY_KEY=<YOUR KEY> release
```

Once the process has run:
* Update the download links and the Docker image versions in the README.
* Increase the version in the Makefile.
* Commit and push changes.
