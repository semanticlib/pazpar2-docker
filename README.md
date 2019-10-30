Pazpar2 Docker base image
=========================

# Introduction

This `Dockerfile` provides [Pazpar2](https://www.indexdata.com/resources/software/pazpar2/) 
and [YAZ](https://www.indexdata.com/resources/software/yaz/) on Alpine Linux as Docker image.
The base image includes the provided [default configuration](https://github.com/indexdata/pazpar2/tree/master/etc). 
You can easily provide your own configuration either via bind mount or by extending the image. 
For more complex configurations like changed port settings it's strongly suggested to extend 
the base image.

# Quickstart

## Building the image

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker build .
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Building a tagged image

A tagged image can be used to reference it in another `Dockerfile` (for extension).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker build -t pazpar2-base:latest .
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

Make sure the directory `./pazpar2-conf` exists.


# Extending the base image

Example

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM pazpar2-base:latest

ENV CONFIG_FILE=/etc/pazpar2/SUB.xml \
    PAZPAR2_DIR=/opt/pazpar2

USER root

COPY $BUILD_CONTEXT/docker/sub-pazpar2/pazpar2-SUB $PAZPAR2_DIR/pazpar2-SUB
RUN ln -s $PAZPAR2_DIR/pazpar2-SUB/*.xml /etc/pazpar2/ && \
    sed -i 's/listen host=\"localhost\" port=\"9004\"/listen host=\"127.0.0.1\" port=\"9004\"/g' $PAZPAR2_DIR/pazpar2-SUB/*.xml

USER $USER

EXPOSE 9004

ENTRYPOINT /usr/local/sbin/pazpar2 -f $CONFIG_FILE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This example copies some configuration files inside the extended container, creates some links in the configuration directory 
and changes the interface where the daemon binds. On start (`ENTRYPOINT`) the daemon is started with the configuration file set 
by `$CONFIG_FILE`

## Files and directories

`yaz` and `pazpar2` are installed to `/usr/local/`. The directory layout bellow this directory follows the pattern provided 
by `make install`. 

| Artefact             | Location                  |
|----------------------|---------------------------|
| YAZ binaries         | `/usr/local/bin`          |
| `pazpar2` executable | `/usr/local/sbin/pazpar2` |

# Using the pre build image from the GitLab registry


# Updating the base image

To update the different used software versions you just need to change `Dockerfile`:

| Software | Current version | Line to change                  |
|----------|-----------------|---------------------------------|
| Pazpar2  | 1.14.0          | `PAZPAR2_DOWNLOAD_URL` variable |
| YAZ      | 5.27.2          | `YAZ_DOWNLOAD_URL` variable     |
| Alpine   | 3.10.3          | `FROM:` line                    |
