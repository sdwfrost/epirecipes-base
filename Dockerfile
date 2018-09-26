FROM jupyter/datascience-notebook:latest

LABEL maintainer="Simon Frost <sdwfrost@gmail.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

# Octave
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    octave && \
    octave --eval 'pkg install -forge dataframe' && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN pip install octave_kernel feather-format


# C
RUN pip install cffi_magic \
    jupyter-c-kernel && \
    install_c_kernel && \
    rm -rf /home/$NB_USER/.cache/pip

# Fortran
RUN cd /tmp && \
    git clone https://github.com/ZedThree/jupyter-fortran-kernel && \
    cd jupyter-fortran-kernel && \
    pip install . && \
    jupyter-kernelspec install fortran_spec/ && \
    cd /tmp && \
    rm -rf jupyter-fortran-kernel && \
    rm -rf /home/$NB_USER/.cache/pip
