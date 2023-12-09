FROM ubuntu:jammy as build

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
	ninja-build \
	python3-dev \
	python3-mako \
	python3-numpy \
	python3-requests \
	python3-scipy \
	python3-setuptools

WORKDIR /uhd

RUN git clone https://github.com/EttusResearch/uhd.git
RUN git fetch origin ${UHD_COMMIT} && git checkout ${UHD_COMMIT}

WORKDIR /uhd/host/build

RUN cmake ../ -G Ninja -DENABLE_TESTS=OFF -DENABLE_EXAMPLES=OFF && ninja -j$(nproc)
RUN ninja -j$(nproc) install

WORKDIR /srsran

RUN git clone https://github.com/srsRAN/srsRAN_4G.git srsran
RUN git fetch origin ${SRS_COMMIT} && git checkout ${SRS_COMMIT}

WORKDIR /srsran/build

RUN cmake ../ -G Ninja && ninja -j$(nproc)
RUN ninja -j$(nproc) install
RUN srsran_install_configs.sh service

RUN /usr/local/lib/uhd/utils/uhd_images_downloader.py
RUN ldconfig
RUN rm -rf uhd srsran /var/lib/apt/lists/*

FROM ubuntu:jammy as main

COPY --from=build /usr/local/ /usr/local/

RUN ldconfig

COPY start.sh start.sh
RUN chmod +x ./start.sh

CMD ./start.sh
