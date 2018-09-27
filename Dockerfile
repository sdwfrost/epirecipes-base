FROM jupyter/datascience-notebook:latest

LABEL maintainer="Simon Frost <sdwfrost@gmail.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -yq dist-upgrade\
    && apt-get install -yq --no-install-recommends \
    autoconf \
    automake \
    ant \
    apt-file \
    apt-utils \
    apt-transport-https \
    build-essential \
    bzip2 \
    ca-certificates \
    cmake \
    curl \
    darcs \
    debhelper \
    devscripts \
    dirmngr \
    ed \
    fonts-liberation \
    fonts-dejavu \
    gcc \
    gdebi-core \
    gfortran \
    ghostscript \
    ginac-tools \
    git \
    gnuplot \
    gnupg \
    gnupg-agent \
    gzip \
    haskell-stack \
    libffi-dev \
    libgmp-dev \
    libgsl0-dev \
    libtinfo-dev \
    libzmq3-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libmagic-dev \
    libblas-dev \
    liblapack-dev \
    libboost-all-dev \
    libcln-dev \
    libcurl4-gnutls-dev \
    libgeos-dev \
    libginac-dev \
    libginac6 \
    libgit2-dev \
    libgl1-mesa-glx \
    libgs-dev \
    libjsoncpp-dev \
    libnetcdf-dev \
    libqrupdate-dev \
    libqt5widgets5 \
    libsm6 \
    libssl-dev \
    libudunits2-0 \
    libunwind-dev \
    libxext-dev \
    libxml2-dev \
    libxrender1 \
    libxt6 \
    libzmqpp-dev \
    lmodern \
    locales \
    mercurial \
    netcat \
    octave \
    octave-dataframe \
    octave-general \
    octave-gsl \
    octave-nlopt \
    octave-odepkg \
    octave-optim \
    octave-symbolic \
    octave-miscellaneous \
    octave-missing-functions \
    octave-pkg-dev \
    openjdk-8-jdk \
    openjdk-8-jre \
    pandoc \
    pari-gp \
    pari-gp2c \
    pbuilder \
    pkg-config \
    psmisc \
    python3-dev \
    rsync \
    sbcl \
    software-properties-common \
    sudo \
    swig \
    tzdata \
    ubuntu-dev-tools \
    unzip \
    uuid-dev \
    wget \
    xz-utils \
    zlib1g-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-java-alternatives --set /usr/lib/jvm/java-1.8.0-openjdk-amd64

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -yq --no-install-recommends \
    nodejs \
    nodejs-legacy \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /bin/tar /bin/gtar

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Octave
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
RUN mv $HOME/.local/share/jupyter/kernels/c /usr/local/share/jupyter/kernels/ && \
    chmod -R go+rx /usr/local/share/jupyter && \
    fix-permissions /usr/local/share/jupyter

# C++
RUN conda install xeus-cling xtensor xtensor-blas -c conda-forge -c QuantStack

# gnuplot
RUN pip install gnuplot_kernel && \
    python3 -m gnuplot_kernel install

# pari-gp
RUN pip install pari_jupyter

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

# Scilab
ENV SCILAB_VERSION=6.0.1
ENV SCILAB_EXECUTABLE=/usr/local/bin/scilab-adv-cli
RUN mkdir /opt/scilab-${SCILAB_VERSION} && \
    cd /tmp && \
    wget http://www.scilab.org/download/6.0.1/scilab-${SCILAB_VERSION}.bin.linux-x86_64.tar.gz && \
    tar xvf scilab-${SCILAB_VERSION}.bin.linux-x86_64.tar.gz -C /opt/scilab-${SCILAB_VERSION} --strip-components=1 && \
    rm /tmp/scilab-${SCILAB_VERSION}.bin.linux-x86_64.tar.gz && \
    ln -fs /opt/scilab-${SCILAB_VERSION}/bin/scilab-adv-cli /usr/local/bin/scilab-adv-cli && \
    ln -fs /opt/scilab-${SCILAB_VERSION}/bin/scilab-cli /usr/local/bin/scilab-cli && \
    pip install scilab_kernel

# Libbi 
RUN cd /tmp && \
    wget https://github.com/thrust/thrust/releases/download/1.8.2/thrust-1.8.2.zip && \
    unzip thrust-1.8.2.zip && \
    mv thrust /usr/local/include && \
    rm thrust-1.8.2.zip && \
    fix-permissions /usr/local/include
RUN cd /opt && \
    git clone https://github.com/lawmurray/LibBi && \
    cd LibBi && \
    PERL_MM_USE_DEFAULT=1  cpan . && \
    fix-permissions /opt/LibBi ${HOME}/.cpan
ENV PATH=/opt/LibBi/script:$PATH

USER ${NB_USER}

RUN npm install -g ijavascript && \
    ijsinstall

USER root

RUN mv $HOME/.local/share/jupyter/kernels/javascript /usr/local/share/jupyter/kernels/ && \
    chmod -R go+rx /usr/local/share/jupyter && \
    fix-permissions /usr/local/share/jupyter ${HOME}/.cache /opt/conda/pkgs

USER ${NB_USER}
