# Quorum By ConsenSys

Distribution of Quorum and associated projects, tested and supported by ConsenSys.

# Download

You can download binaries created with this project under:
   https://consensys.bintray.com/binaries/qbc/0.1/

# Docker images

You can pull Docker images for Quorum, Crux and Tessera:
```
docker pull consensys-docker-qbc.bintray.io/qbc/quorum:0.1
docker pull consensys-docker-qbc.bintray.io/qbc/crux:0.1
docker pull consensys-docker-qbc.bintray.io/qbc/tessera:0.1
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

`$> brew install berkeley-db libsodium maven`

# Building

To build the tarball package for Linux, run:
```
$> make build/qbc-$(VERSION)-linux-386.tar.gz -j8
```

To build the tarball package for Mac OS X, run:
```
$> make build/qbc-$(VERSION)-darwin-64.tar.gz -j8
```

To create the Docker images, you can run:
```
$> make -j8
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
