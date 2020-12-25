FROM ubuntu:20.04 AS base
ARG DEBIAN_FRONTEND=noninteractive

# random stuff for a pre-packaged gnuradio and gr-satnogs...
RUN apt update && apt-get install -y \
  rtl-sdr gr-osmosdr libusb-1.0-0-dev git \
  cmake swig python3-pip xterm \
  libpng-dev libpng++-dev zlib1g-dev pkg-config \
  libhamlib-utils libhamlib-dev \
  libvorbis-dev libjsoncpp-dev

# gnuradio dependencies
RUN apt-get install -y \
git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy \
python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
python3-zmq python3-scipy

# more ned stuff I needed to be able to start gnuradio-companion
RUN apt-get install -y python3-gi gobject-introspection gir1.2-gtk-3.0

# new depends
RUN apt-get install -y \
libsoapysdr-dev

# needed for grc of gnuradio
RUN apt-get install -y python3-gi-cairo


FROM base AS gnuradio
WORKDIR /home/developer
RUN mkdir /home/developer/workspace

# libfec
RUN git clone https://github.com/daniestevez/libfec.git
WORKDIR /home/developer/libfec
RUN sed -i "s/ldconfig/#ldconfig/g" configure
RUN ./configure
RUN make && make install

# things
RUN pip3 install construct
RUN pip3 install requests

WORKDIR /home/developer
COPY install_oot_helper.sh .
COPY gnuradio.env .
ENV LOCALPREFIX=/home/developer/_install
ENV PREFIX=$LOCALPREFIX
#RUN source gnuradio.env
RUN ./install_oot_helper.sh https://github.com/gnuradio/gnuradio.git maint-3.8
RUN ./install_oot_helper.sh https://github.com/daniestevez/gr-satellites.git master
#RUN cd gr-satellites && bash -c "source ../gnuradio.env && ./compile_hierarchical.sh"
RUN pwd
RUN ./install_oot_helper.sh https://gitlab.com/librespacefoundation/gr-soapy.git



FROM gnuradio AS satnogs_client
WORKDIR /home/developer
RUN apt-get install -y nlohmann-json3-dev
RUN ./install_oot_helper.sh https://gitlab.com/librespacefoundation/satnogs/gr-satnogs.git
RUN apt-get install -y python3-soapysdr
RUN ./install_oot_helper.sh https://gitlab.com/librespacefoundation/satnogs/satnogs-flowgraphs.git

RUN git clone https://gitlab.com/librespacefoundation/satnogs/satnogs-client.git
RUN pip3 install -e satnogs-client

# things
RUN pip3 install config --user
RUN pip3 install tracker --user
WORKDIR /home/developer
RUN pip3 install pyusb --user
RUN git clone https://github.com/satlab/bbctl.git && \
    cd bbctl && \
    pip3 install -e . --user
RUN pip3 install pypredict --user


RUN apt-get install -y python3-libhamlib2

# needed to get rid of some dbus log warnings in stdout
RUN apt-get install -y dbus-x11


#gr-satnogs new-arch
#RUN git clone -b new-arch https://gitlab.com/surligas/gr-satnogs.git gr-satnogs_new-arch
#RUN cd gr-satnogs_new-arch && mkdir build
#WORKDIR /home/developer/gr-satnogs_new-arch/build
#RUN cmake .. && make -j$(nproc) && make install && ldconfig

ENV PYTHONPATH="/home/developer/aausat4_beacon_parser:${PYTHONPATH}"
ENV PATH="/home/developer/workspace/bin:$PATH"

WORKDIR /home/developer/workspace
RUN mkdir -p tmp
RUN pip3 install aenum --user

FROM gnuradio as grc
WORKDIR /home/developer/workspace
CMD gnuradio-companion
EXPOSE 5555

