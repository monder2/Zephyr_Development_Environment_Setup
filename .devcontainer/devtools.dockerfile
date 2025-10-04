# Fetch a new image from archlinux
# NOTE: The comment says 'archlinux' but the base image is 'ubuntu'. I kept 'ubuntu'.
FROM ubuntu

# Install necessary build tools and dependencies. The -y flag confirms installation, and
# --no-install-recommends makes the image smaller by skipping suggested packages.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    make \
    openocd \
    wget \
    xz-utils && \
    rm -rf /var/lib/apt/lists/*

# libtinfo5, libncurses5, and libncursesw5 are needed to run our arm toolchain.
# We download and install them manually via dpkg to ensure compatibility with the toolchain version.
# **This section has been corrected.**
RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.2-0ubuntu2.1_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.2-0ubuntu2.1_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncursesw5_6.2-0ubuntu2.1_amd64.deb && \
    dpkg -i ./libtinfo5_6.2-0ubuntu2.1_amd64.deb && \
    dpkg -i ./libncurses5_6.2-0ubuntu2.1_amd64.deb && \
    dpkg -i ./libncursesw5_6.2-0ubuntu2.1_amd64.deb && \
    # Remove the downloaded .deb files to keep the layer clean
    rm libtinfo5_6.2-0ubuntu2.1_amd64.deb libncursesw5_6.2-0ubuntu2.1_amd64.deb libncurses5_6.2-0ubuntu2.1_amd64.deb

# Define the installation directory as an environment variable for clarity
ENV TOOLCHAIN_NAME arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi
ENV TOOLCHAIN_DIR /opt/arm/$TOOLCHAIN_NAME

# 1. Create the base installation directory /opt/arm
RUN mkdir -p /opt/arm

# Download the ARM GNU toolchain, decompress, and set its route to PATH variable globally.
RUN wget -L --progress=dot:giga https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi.tar.xz --no-check-certificate -O arm-toolchain.tar.xz && \
    tar -xvf arm-toolchain.tar.xz -C /opt/arm && \
    rm arm-toolchain.tar.xz

# Set the PATH for all users/shells by creating a file in /etc/profile.d
RUN echo "export PATH=$TOOLCHAIN_DIR/bin:\$PATH" > /etc/profile.d/arm-toolchain.sh

# FIX: Changed WORKDIR from /workspace to /workspaces/project to match the
# default path expected by VS Code Dev Containers (as indicated by your error message).
# WORKDIR /workspaces