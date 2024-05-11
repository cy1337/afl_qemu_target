# Use an official Ubuntu base image
FROM ubuntu:latest

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
    vim \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r fuzz && useradd -r -g fuzz -d /usr/src/app -s /sbin/nologin fuzzuser
RUN usermod -aG sudo fuzzuser
RUN ln -s /usr/src/app /demo
# Optionally, configure sudo to allow the user to run commands without a password
RUN echo "fuzzuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /demo
COPY simple_target_server /demo
COPY remove_pie.py /demo
COPY harness.c /demo
COPY post_data.bin /demo
RUN chown -R fuzzuser:fuzz /usr/src/app

USER fuzzuser
WORKDIR /demo
# Download the AFLplusplus source from GitHub Releases
RUN wget https://github.com/AFLplusplus/AFLplusplus/archive/refs/tags/v4.20c.tar.gz \
    && tar -xzvf v4.20c.tar.gz \
    && rm v4.20c.tar.gz

# Move to the AFLplusplus directory
WORKDIR /demo/AFLplusplus-4.20c

# Compile AFLplusplus
RUN make

# Install QEMU support for AFLplusplus
RUN cd qemu_mode && ./build_qemu_support.sh

WORKDIR /demo/AFLplusplus-4.20c
RUN sudo make install

RUN pip3 install --break-system-packages lief
WORKDIR /demo
# Expose port 8080
EXPOSE 8080

CMD ["/demo/simple_target_server"]
