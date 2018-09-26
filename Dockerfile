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
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    libgsl0-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir cffi_magic \
    jupyter-c-kernel && \
    install_c_kernel

# C++
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    libboost-all-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN conda install xeus-cling xtensor xtensor-blas -c conda-forge -c QuantStack

# Maxima
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    autoconf \
    automake \
    sbcl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN cd /tmp && \
    git clone https://github.com/andrejv/maxima && \
    cd maxima && \
    sh bootstrap && \
    ./configure --enable-sbcl && \
    make && \
    make install && \
    cd /tmp && \
    rm -rf maxima
RUN mkdir /opt/quicklisp && \
    cd /tmp && \
    curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --load quicklisp.lisp --non-interactive --eval '(quicklisp-quickstart:install :path "/opt/quicklisp/")' && \
    yes '' | sbcl --load /opt/quicklisp/setup.lisp --non-interactive --eval '(ql:add-to-init-file)' && \
    rm quicklisp.lisp && \
    fix-permissions /opt/quicklisp
RUN cd /opt && \
    git clone https://github.com/robert-dodier/maxima-jupyter && \
    cd maxima-jupyter && \
    python3 ./install-maxima-jupyter.py --root=/opt/maxima-jupyter && \
    sbcl --load /opt/quicklisp/setup.lisp --non-interactive load-maxima-jupyter.lisp && \
    fix-permissions /opt/maxima-jupyter /usr/local/share/jupyter/kernels

RUN npm install -g ijavascript \
    plotly-notebook-js \
    ode-rk4 && \
    ijsinstall

USER $NB_USER
