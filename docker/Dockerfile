# Using debian:bookworm-slim as the base image
FROM arm64v8/debian:bookworm-slim
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update ; apt-get -y install net-tools git wget vim sudo zip corkscrew rsync iputils-ping locales apt-utils gpg tzdata devscripts equivs debmake
RUN locale-gen en_US en_US.UTF-8
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash && \
    export LC_ALL="en_US.UTF-8" && \
    export LC_CTYPE="en_US.UTF-8" && \
    export LC_NUMERIC="en_US.UTF-8"

RUN mkdir /home/riaps
RUN git clone https://github.com/RIAPS/riaps-am64-ti-linux-kernel.git /home/riaps/riaps-am64-ti-linux-kernel
RUN mkdir /home/riaps/riaps-am64-ti-linux-kernel/build
RUN mkdir /home/riaps/riaps-am64-ti-linux-kernel/build/sources
#RUN git clone https://git.ti.com/git/ti-linux-kernel/ti-linux-kernel.git /home/riaps/riaps-am64-ti-linux-kernel/build/sources/ti-linux-kernel-rt