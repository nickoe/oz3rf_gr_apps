FROM ubuntu:19.10 AS base
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt-get install -y \
  gnuradio \
  rtl-sdr gr-osmosdr libusb-1.0-0-dev git \
  cmake swig python-pip xterm \
  libpng-dev libpng++-dev zlib1g-dev pkg-config \
  libhamlib-utils libhamlib-dev \
  libvorbis-dev

FROM base AS gnuradio
WORKDIR /home/developer
RUN mkdir /home/developer/workspace

# libfec
RUN git clone https://github.com/daniestevez/libfec.git
WORKDIR /home/developer/libfec
RUN ./configure
RUN make && make install
RUN pip install construct
RUN pip install requests

# gr-satellites
WORKDIR /home/developer
RUN git clone -b maint-3.7 https://github.com/daniestevez/gr-satellites.git
RUN cd gr-satellites && mkdir build
WORKDIR /home/developer/gr-satellites/build
RUN cmake ../
RUN make -j$(nproc)
RUN make install
RUN ldconfig
RUN cd .. && ./compile_hierarchical.sh

# gr-aausat DEPRICATED
WORKDIR /home/developer
RUN git clone https://github.com/daniestevez/gr-aausat.git
RUN cd gr-aausat && mkdir build
WORKDIR /home/developer/gr-aausat/build
RUN cmake ../
RUN make -j$(nproc)
RUN make install
RUN ldconfig


FROM gnuradio AS satnogs_client
RUN echo 3
WORKDIR /home/developer
#RUN git clone https://gitlab.com/librespacefoundation/satnogs/gr-satnogs.git
RUN git clone -b rigctl_ip https://github.com/nickoe/gr-satnogs.git
RUN cd gr-satnogs && mkdir build
WORKDIR /home/developer/gr-satnogs/build
RUN cmake .. && make -j$(nproc) && make install && ldconfig

WORKDIR /home/developer
#RUN git clone https://gitlab.com/librespacefoundation/satnogs/satnogs-client.git
RUN git clone -b aausat4_hacks https://gitlab.com/nickoe/satnogs-client.git
RUN pip install -e satnogs-client

RUN git clone -b refactor_2 https://github.com/nickoe/aausat4_beacon_parser.git
RUN cd aausat4_beacon_parser/gr-aausat4 && mkdir build && mkdir lib
WORKDIR /home/developer/aausat4_beacon_parser/gr-aausat4/build
RUN cmake ..
RUN make -j$(nproc)
RUN make install
RUN ldconfig
RUN pip install config --user
RUN pip install tracker --user
WORKDIR /home/developer
RUN pip install pyusb --user
RUN git clone https://github.com/satlab/bbctl.git && \
    cd bbctl && \
    pip install -e . --user
RUN pip install pypredict --user


#gr-satnogs new-arch
RUN git clone -b new-arch https://gitlab.com/surligas/gr-satnogs.git gr-satnogs_new-arch
RUN cd gr-satnogs_new-arch && mkdir build
WORKDIR /home/developer/gr-satnogs_new-arch/build
RUN apt update && apt-get install -y libjsoncpp-dev
#RUN cmake .. && make -j$(nproc) && make install && ldconfig

ENV PYTHONPATH="/home/developer/aausat4_beacon_parser:${PYTHONPATH}"
ENV PATH="/home/developer/workspace/bin:$PATH"

WORKDIR /home/developer/workspace
RUN mkdir -p tmp
RUN pip install aenum --user

FROM gnuradio as grc
WORKDIR /home/developer/workspace
CMD gnuradio-companion
EXPOSE 5555

