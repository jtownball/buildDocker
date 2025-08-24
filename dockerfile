#--------------------------------------------------
# Base Image
#--------------------------------------------------
FROM python:3.11-slim

# Disable interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

#--------------------------------------------------
# 1. Install System Packages & Dev Libraries
#--------------------------------------------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      sudo \
      build-essential \
      cmake \
      ninja-build \
      git \
      wget \
      curl \
      unzip \
      pkg-config \
      ca-certificates \
      ccache \
      passwd \
      libpam-modules \
      gfortran \
      clang \
      clang-format \
      gdb \
      valgrind \
      libssl-dev \
      zlib1g-dev \
      libbz2-dev \
      liblzma-dev \
      libcurl4-openssl-dev \
      libsqlite3-dev \
      libjpeg-dev \
      libpng-dev \
      libtiff-dev \
      libgif-dev \
      libgtk-3-dev \
      libopencv-dev \
      libboost-all-dev \
      libeigen3-dev \
      libblas-dev \
      liblapack-dev \
      python3-dev \
      libuv1-dev \
      lcov \
      graphviz \
      btop \
 && rm -rf /var/lib/apt/lists/*

#--------------------------------------------------
# 2. Configure Ccache via symlink farm
#--------------------------------------------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends ccache \
 && rm -rf /var/lib/apt/lists/*

# Prepend the symlink farm so gcc, cc, clang, etc go to ccache
ENV PATH="/usr/lib/ccache:${PATH}" \
    CCACHE_DIR="/ccache" \
    CCACHE_MAXSIZE="5G" \
    CC="gcc" \
    CXX="g++"

# Initialize / zero stats
RUN ccache --max-size="${CCACHE_MAXSIZE}" \
 && ccache -z

#--------------------------------------------------
# 4. Install google test and google mock
#--------------------------------------------------
RUN git clone https://github.com/google/googletest.git /tmp/googletest \
 && cd /tmp/googletest && cmake -DBUILD_GMOCK=ON -DBUILD_GTEST=ON . \
 && make -j$(nproc) && make install \
 && rm -rf /tmp/googletest

#--------------------------------------------------
# 5. Install Rust & Sccache
#--------------------------------------------------
ENV RUSTUP_HOME=/root/.rustup \
    CARGO_HOME=/root/.cargo \
    PATH=/root/.cargo/bin:$PATH

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
 && rustup default stable \
 && rustup component add rustfmt clippy \
 && cargo install sccache \
 && mkdir -p /root/.cargo \
 && printf '[build]\nrustc-wrapper = "sccache"\n' >> /root/.cargo/config

#--------------------------------------------------
# 6. Upgrade pip & Install Python Packages
#--------------------------------------------------
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir \
      astral \
      uvloop

#--------------------------------------------------
# 7. Add user
#--------------------------------------------------
ARG USERNAME
ARG HOST_UID=1000
ARG HOST_GID=1000

RUN groupadd -g "${HOST_GID}" "${USERNAME}" \
 && useradd -m -u "${HOST_UID}" -g "${HOST_GID}" -s /bin/bash "${USERNAME}"

USER ${USERNAME}

#--------------------------------------------------
# 8. Workspace and Default Command
#--------------------------------------------------
# WORKDIR /workspace
# VOLUME ["/workspace/.ccache"]
CMD ["bash"]
