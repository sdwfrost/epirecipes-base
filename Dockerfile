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
RUN mv $HOME/.local/share/jupyter/kernels/c /usr/local/share/jupyter/kernels/ && \
    chmod -R go+rx /usr/local/share/jupyter && \
    fix-permissions /usr/local/share/jupyter

# C++
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    libboost-all-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN conda install xeus-cling xtensor xtensor-blas -c conda-forge -c QuantStack

# gnuplot
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    gnuplot && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN pip install gnuplot_kernel && \
    python3 -m gnuplot_kernel install

# XPP
ENV XPP_DIR=/opt/xppaut
RUN mkdir /opt/xppaut && \
    cd /tmp && \
    wget http://www.math.pitt.edu/~bard/bardware/xppaut_latest.tar.gz && \
    tar xvf xppaut_latest.tar.gz -C /opt/xppaut && \
    cd /opt/xppaut && \
    make && \
    ln -fs /opt/xppaut/xppaut /usr/local/bin/xppaut && \
    rm /tmp/xppaut_latest.tar.gz && \
    fix-permissions $XPP_DIR /usr/local/bin

# VFGEN
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    ginac-tools \
    libginac-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# First needs MiniXML
RUN cd /tmp && \
    mkdir /tmp/mxml && \
    wget https://github.com/michaelrsweet/mxml/releases/download/v2.11/mxml-2.11.tar.gz && \
    tar xvf mxml-2.11.tar.gz -C /tmp/mxml && \
    cd /tmp/mxml && \
    ./configure && \
    make && \
    make install && \
    cd /tmp && \
    rm mxml-2.11.tar.gz && \
    rm -rf /tmp/mxml
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

RUN mkdir /opt/vfgen && \
    cd /tmp && \
    git clone https://github.com/WarrenWeckesser/vfgen && \
    cd vfgen/src && \
    make -f Makefile.vfgen && \
    cp ./vfgen /opt/vfgen && \
    cd /tmp && \
    rm -rf vfgen && \
    ln -fs /opt/vfgen/vfgen /usr/local/bin/vfgen

# Maxima

RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    automake \
    autoconf \
    ed \
    gzip \
    libzmq3-dev \
    sbcl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN ln -s /bin/tar /bin/gtar

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
    install -D maxima.js /opt/conda/lib/python3.6/site-packages/notebook/static/components/codemirror/mode/maxima/maxima.js && \
    patch /opt/conda/lib/python3.6/site-packages/notebook/static/components/codemirror/mode/meta.js /opt/maxima-jupyter/codemirror-mode-meta-patch && \  
    install /opt/maxima-jupyter/maxima_lexer.py /opt/conda/lib/python3.6/site-packages/pygments/lexers/maxima_lexer.py && \
    patch /opt/conda/lib/python3.6/site-packages/pygments/lexers/_mapping.py /opt/maxima-jupyter/pygments-mapping-patch && \
    fix-permissions /opt/maxima-jupyter

RUN fix-permissions ${HOME}/.local

USER ${NB_USER}

RUN npm install -g ijavascript && \
    ijsinstall

USER root

RUN mv $HOME/.local/share/jupyter/kernels/javascript /usr/local/share/jupyter/kernels/ && \
    chmod -R go+rx /usr/local/share/jupyter && \
    fix-permissions /usr/local/share/jupyter

USER ${NB_USER}
