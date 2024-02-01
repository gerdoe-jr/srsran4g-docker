# outdated

# Dockerized srsRAN 4G

First of all you need to install Docker according to your OS instructions.

Before you start with working on this make sure you have enabled your `sctp` kernel module:

```bash
$ lsmod | grep sctp # check if module is loaded
$ modprobe sctp     # load if there's none
```

## Build

Since there's no image of this repository on official Docker Hub, you need to build it on your own:

```bash
$ git clone https://github.com/gerdoe-jr/srsran4g-docker.git
$ cd srsran4g-docker
$ docker build -t srsran4g .
```

## USB Connection

This image was only tested using USB connection between host machine and USRP. To run container you need to get your USRP identifier with `lsusb` and then expose device:

```bash
$ lsusb | grep USRP
$ docker --privileged --device=/dev/bus/usb/000/000 run srsran4g
```
