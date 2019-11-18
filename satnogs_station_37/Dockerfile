FROM ubuntu:18.04 AS base
RUN apt update && apt install -y gnuradio
RUN apt install -y rtl-sdr gr-osmosdr libusb-1.0-0-dev git
RUN apt install -y cmake
RUN apt install -y swig python-pip


FROM base AS fisk


WORKDIR /home/developer

RUN git clone https://github.com/daniestevez/libfec.git
WORKDIR /home/developer/libfec
RUN ./configure
RUN make && make install

RUN pip install construct
RUN pip install requests

WORKDIR /home/developer
RUN git clone -b maint-3.7 https://github.com/daniestevez/gr-satellites.git
RUN cd gr-satellites && mkdir build

WORKDIR /home/developer/gr-satellites/build
RUN cmake ../
RUN make -j$(nproc)
RUN make install
RUN ldconfig
RUN cd .. && ./compile_hierarchical.sh


WORKDIR /home/developer
RUN mkdir /home/developer/workspace
CMD gnuradio-companion
EXPOSE 5555

