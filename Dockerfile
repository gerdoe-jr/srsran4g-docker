FROM ubuntu:jammy as build

# ZMQ 4.3.5
ARG ZMQ_COMMIT=622fc6dde99ee172ebaa9c8628d85a7a1995a21d
# CZMQ 4.2.1
ARG CZMQ_COMMIT=4a50c2153586cf510d6cc3fcfbb9f5ea2e02c419
# UHD 4.5.0.0
ARG UHD_COMMIT=471af98f6b595f5fd52d62303287d968ed2a8d0b
# SRSRAN 4G 23.04.1
ARG SRS_COMMIT=fa56836b14dc6ad7ce0c3484a1944ebe2cdbe63b

RUN apt-get update && \
	apt-get install --no-install-recommends -y \
	autoconf \
	automake \
	build-essential \
	ccache \
	cmake \
	cpufrequtils \
	doxygen \
	ethtool \
	git \
	inetutils-tools \
	iputils-ping \
	iproute2 \
	iptables \
	libfftw3-dev \
	libmbedtls-dev \
	libboost-program-options-dev \
	libconfig++-dev \
	libsctp-dev \
	libboost-all-dev \
	libncurses5 \
	libncurses5-dev \
	libusb-1.0-0 \
	libusb-1.0-0-dev \
	libusb-dev \
	libtool \
	ninja-build \
	python3-dev \
	python3-mako \
	python3-numpy \
	python3-requests \
	python3-scipy \
	python3-setuptools

RUN git clone https://github.com/zeromq/libzmq.git
RUN git clone https://github.com/zeromq/czmq.git
RUN git clone https://github.com/EttusResearch/uhd.git
RUN git clone https://github.com/srsRAN/srsRAN_4G.git srsran

RUN git -C libzmq fetch origin ${ZMQ_COMMIT} && git -C libzmq checkout ${ZMQ_COMMIT}
RUN git -C czmq fetch origin ${CZMQ_COMMIT} && git -C czmq checkout ${CZMQ_COMMIT}
RUN git -C uhd fetch origin ${UHD_COMMIT} && git -C uhd checkout ${UHD_COMMIT}
RUN git -C srsran fetch origin ${SRS_COMMIT} && git -C srsran checkout ${SRS_COMMIT}

WORKDIR /libzmq

RUN ./autogen.sh && ./configure && make check
RUN make install

WORKDIR /czmq

RUN ./autogen.sh && ./configure && make check
RUN make install

WORKDIR /uhd/host/build

RUN cmake ../ -G Ninja -DENABLE_TESTS=OFF -DENABLE_EXAMPLES=OFF && ninja -j$(nproc)
RUN ninja -j$(nproc) install

WORKDIR /srsran/build

RUN cmake ../ -G Ninja && ninja -j$(nproc)
RUN ninja -j$(nproc) install
RUN srsran_install_configs.sh service

RUN /usr/local/lib/uhd/utils/uhd_images_downloader.py
RUN ldconfig

FROM ubuntu:jammy as srsran-base

COPY --from=build /usr/local/ /usr/local/
COPY --from=build /usr/bin/ /usr/bin/
COPY --from=build /usr/lib/ /usr/lib/
COPY --from=build /etc/ /etc/

COPY ./config /config

RUN ldconfig
