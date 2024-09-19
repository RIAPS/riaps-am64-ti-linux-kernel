The Debian Bookworm version of the "ghcr.io/texasinstruments/debian-arm64" docker.  

This information is from https://github.com/TexasInstruments/ti-docker-images/.

## Building docker image

The docker image takes about 1 hour to build, with 46 minutes spent cloning the TI kernel repository

```
sudo docker pull multiarch/qemu-user-static
sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
sudo docker build -t --platform=linux/arm64 riaps/ghcr.io/texasinstruments/debian-arm64:bookworm .
```

## Save docker image

For ease of use in the building process, the built docker image is saved using the following commands:

```
sudo docker run --rm -id riaps/ghcr.io/texasinstruments/debian-arm64:bookworm
sudo docker save -o ~/RIAPS/riaps-ti-debian-arm64-docker-bookworm.tar riaps/ghcr.io/texasinstruments/debian-arm64:bookworm

```