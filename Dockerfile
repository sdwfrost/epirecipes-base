FROM jupyter/datascience-notebook:latest

LABEL maintainer="Simon Frost <sdwfrost@gmail.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

# Octave
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    octave && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir octave_kernel

# Fortran
RUN cd /tmp && \
    git clone https://github.com/ZedThree/jupyter-fortran-kernel && \
    cd jupyter-fortran-kernel && \
    pip install --no-cache-dir . && \
    jupyter-kernelspec install fortran_spec/ && \
    cd /tmp && \
    rm -rf jupyter-fortran-kernel

# C
RUN pip install --no-cache-dir cffi_magic \
    jupyter-c-kernel && \
    install_c_kernel

# C++
RUN conda install xeus-cling xtensor xtensor-blas -c conda-forge -c QuantStack


