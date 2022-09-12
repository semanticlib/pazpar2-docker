Pazpar2 Docker base image
=========================

:information_source: Forked from: https://gitlab.gwdg.de/subugoe/pazpar2/pazpar2-docker-base

# Introduction

This `Dockerfile` provides [Pazpar2](https://www.indexdata.com/resources/software/pazpar2/) 
and [YAZ](https://www.indexdata.com/resources/software/yaz/) on Alpine Linux as Docker image.
The base image includes the provided [default configuration](https://github.com/indexdata/pazpar2/tree/master/etc). 
You can easily provide your own configuration either via bind mount or by extending the image. 
For more complex configurations like changed port settings it's strongly suggested to extend the base image.

# Quickstart

## Building the image

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
git clone https://github.com/semanticlib/pazpar2-docker.git
cd pazpar2-docker
docker build .
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Building a tagged image

A tagged image can be used to reference it in another `Dockerfile` (for extension).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker build -t pazpar2:latest .
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Running

(This examples uses the tagged image)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker run -p 9004:9004 pazpar2:latest
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Running with port exposed.

### Running with a mounted configuration directory

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker run -p 9004:9004 --mount type=bind,source=./pazpar2-conf,target=/etc/pazpar2 pazpar2:latest
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make sure the directory `./pazpar2-conf` exists. You neet to set `CONF_FILE` to load a configuration from there.

## Files and directories

`yaz` and `pazpar2` are installed to `/usr/local/`. The directory layout bellow this directory follows the pattern provided 
by `make install`. 

| Artefact             | Location                  |
|----------------------|---------------------------|
| YAZ binaries         | `/usr/local/bin`          |
| `pazpar2` executable | `/usr/local/sbin/pazpar2` |

# Variables

| Variable Name          | Default value                                             | Description                                                                                                 | 
|------------------------|-----------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `CONF_DIR`             | /etc/pazpar2                                              | The directory to copy the sample configuration to                                                           |
| `CONF_FILE`            | /etc/pazpar2/pazpar2.cfg                                  | The path to the configuration file, use this if you want to read a configuration file from a mounted volume |

**Note:** This list isn't complete internal variables aren't shown here.

# Updating the base image

To update the different used software versions you just need to change `Dockerfile`.

| Software | Current version | Line to change             |
|----------|-----------------|----------------------------|
| Pazpar2  | 1.14.1          | `PAZPAR2_VERSION` variable |
| YAZ      | 5.32.0          | `YAZ_VERSION` variable     |
| Alpine   | 3.16.2          | `FROM:` line               |
