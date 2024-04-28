# Use an official Ubuntu base image
FROM ubuntu:latest

WORKDIR /usr/src/app
COPY simple_target_server /usr/src/app/
COPY remove_pie.py /usr/src/app/
COPY in/post_data.bin /usr/src/app/


# Install necessary packages
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    curl \
    cmake \
    git \
    wget \
    python3 \
    python3-dev \
    python3-pip \
    libglib2.0-dev \
    libpixman-1-dev \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Download the AFLplusplus source from GitHub Releases
RUN wget https://github.com/AFLplusplus/AFLplusplus/archive/refs/tags/v4.20c.tar.gz \
    && tar -xzvf v4.20c.tar.gz \
    && rm v4.20c.tar.gz

# Move to the AFLplusplus directory
WORKDIR /usr/src/app/AFLplusplus-4.20c

# Compile AFLplusplus
RUN make

# Install QEMU support for AFLplusplus
RUN cd qemu_mode && ./build_qemu_support.sh

WORKDIR /usr/src/app/AFLplusplus-4.20c
RUN make install

RUN pip3 install --break-system-packages lief
WORKDIR /usr/src/app

# Expose port 8080
EXPOSE 8080

CMD ["/usr/src/app/simple_target_server"]
