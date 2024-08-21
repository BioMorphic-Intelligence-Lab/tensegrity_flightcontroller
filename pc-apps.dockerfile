# Define Base image
FROM ubuntu:22.04

# Add aliases
WORKDIR /root
ADD .bash_aliases .bash_aliases
RUN echo "$(<.bash_aliases)" >> .bashrc

# Ad the source code to the correct folder
WORKDIR /home/ws/
ADD ./GeneralCode/Common/ ./Common
ADD ./GeneralCode/Components/ ./Components
ADD ./GeneralCode/PC-Apps/ ./PC-Apps/
ADD ./GeneralCode/Scripts/MonteCarloSim/monteCarloSim.py ./monteCarloSim.py
RUN mkdir ./Logs

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq && apt-get install -y \
    build-essential \
    cmake \
    libeigen3-dev \
    python3 python-is-python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install numpy

# Build the Common library
WORKDIR /home/ws/Common
RUN mkdir -p build && cd build && cmake -DCMAKE_CXX_FLAGS="-I/usr/include/eigen3" .. && make

# Build the Components library
WORKDIR /home/ws/Components
RUN mkdir -p build && cd build && cmake -DCOMMON_DIR=/home/ws/Common -DCMAKE_CXX_FLAGS="-I/usr/include/eigen3" .. && make

WORKDIR /home/ws/PC-Apps
RUN mkdir -p build && cd build && \
    cmake -DCOMMON_DIR=/home/ws/Common \
          -DCOMPONENTS_DIR=/home/ws/Components \
          -DCMAKE_CXX_FLAGS="-I/usr/include/eigen3" \  
          -DCMAKE_EXE_LINKER_FLAGS="-L/home/ws/Common/build/lib -L/home/ws/Components/build/lib" \
          .. \
    && make

WORKDIR /home/ws

CMD ["bash"]
