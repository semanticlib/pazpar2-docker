Pazpar2 Docker base image
=========================

# Introduction

This `Dockerfile` provides [Pazpar2](https://www.indexdata.com/resources/software/pazpar2/) 
and [YAZ](https://www.indexdata.com/resources/software/yaz/) on Alpine Linux as Docker image.
The base image includes the provided [default configuration](https://github.com/indexdata/pazpar2/tree/master/etc). 
You can easily provide your own configuration either via bind mount or by extending the image. 
For more complex configurations like changed port settings it's strongly suggested to extend 
the base image.

## TODO

-  Enable the testing stuff as described in section 2.3 of the [official documentation](https://software.indexdata.com/pazpar2/doc/pazpar2.pdf).

# Quickstart

## Checkout the repository

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
git clone https://gitlab.gwdg.de/subugoe/pazpar2/pazpar2-docker-base.git
cd pazpar2-docker-base
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Make sure the directory `./pazpar2-conf` exists. You neet to set `CONF_FILE` to load a configuration from there.

# Extending the base image

Example

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM docker.gitlab.gwdg.de/subugoe/pazpar2/pazpar2-docker-base/pazpar2:1.14.0-alpine

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

The base image is build by the GitLab CI, you can get a list of existing images [there](https://gitlab.gwdg.de/subugoe/pazpar2/pazpar2-docker-base/container_registry).

The name of the images is similar to this: `docker.gitlab.gwdg.de/subugoe/pazpar2/pazpar2-docker-base/pazpar2:1.14.0-alpine`
Only the version tag should change.

Currently this repository is configured to trigger a build of [`pazpar2-docker`](https://gitlab.gwdg.de/subugoe/pazpar2/pazpar2-docker) if a new version of this base image 
has been build, the following section of `.gitlab-ci.yml` is responsible:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
trigger_build:
  stage: deploy
  script:
    - "apk add --no-cache curl"
    - "curl -X POST -F token=[Some Token] -F ref=master https://gitlab.gwdg.de/api/v4/projects/8486/trigger/pipeline"
  only:
    - master
  except:
    - tags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to want to trigger your own build from here, create a pull request for `.gitlab-ci.yml` with the additions for your project.

# Arguments

| Argument Name     | Default value | Description                                                        |
|-------------------|---------------|--------------------------------------------------------------------|
| `YAZ_VERSION`     | 5.27.2        | Version of YAZ to use, changes value of `YAZ_DOWNLOAD_URL`         |
| `PAZPAR2_VERSION` | 1.14.0        | Version of Pazpar2 to use, changes value of `PAZPAR2_DOWNLOAD_URL` |

**Note:** That you can use tihs arguments to change the version to be bundled in the base image created by the GitLab CI.

# Variables

| Variable Name          | Default value                                             | Description                                                                                                 | 
|------------------------|-----------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `YAZ_DOWNLOAD_URL`     | http://ftp.indexdata.dk/pub/yaz/yaz-5.27.2.tar.gz         | The URL of the YAZ sources                                                                                  |
| `PAZPAR2_DOWNLOAD_URL` | http://ftp.indexdata.dk/pub/pazpar2/pazpar2-1.14.0.tar.gz | The URL of the Pazpar2 sources                                                                              |
| `CONF_DIR`             | /etc/pazpar2                                              | The directory to copy the sample configuration to                                                           |
| `CONF_FILE`            | /etc/pazpar2/pazpar2.cfg                                  | The path to the configuration file, use this if you want to read a configuration file from a mounted volume |

**Note:** This list isn't complete internal variables aren't shown here.

# Updating the base image

To update the different used software versions you just need to change `Dockerfile`, if you build the image using the GitLab CI 
also make sure to change the settings in `.gitlab-ci.yml` and other variables set there.

| Software | Current version | Line to change                                        |
|----------|-----------------|-------------------------------------------------------|
| Pazpar2  | 1.14.0          | `PAZPAR2_DOWNLOAD_URL` and `PAZPAR2_VERSION` variable |
| YAZ      | 5.27.2          | `YAZ_DOWNLOAD_URL` and `YAZ_VERSION` variable         |
| Alpine   | 3.10.3          | `FROM:` line                                          |

Make also sure to update this [README](./README.md)!