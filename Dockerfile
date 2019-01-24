FROM ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

# Update the base system
COPY ./badproxy /etc/apt/apt.conf.d/99fixbadproxy
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      apt-utils \
      ca-certificates \
      git \
      vim \
      wget

# Clean up
RUN apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a default user and home directory
ENV NAME pyuser
ENV HOME /home/$NAME
RUN useradd -d $HOME -s /bin/bash -u 10000 -U -p $NAME $NAME && \
    mkdir $HOME && \
    addgroup $NAME staff && \
    mkdir $HOME/.jupyter && \
    mkdir $HOME/.cert

COPY bashrc.sh $HOME/.bashrc
COPY ./jupyter_notebook_config.py $HOME/.jupyter
COPY ./create_hashed_password.py $HOME/
RUN chown -R $NAME:$NAME $HOME

# Create a shared directory
RUN mkdir /share && \
    chown -R $NAME:$NAME /share
    
USER $NAME
WORKDIR $HOME

# Install Miniconda3
ENV CONDA_DOWNLOAD_URL https://repo.anaconda.com/miniconda
ENV CONDA_INSTALLER Miniconda3-latest-Linux-x86_64.sh

RUN wget --progress=bar:force $CONDA_DOWNLOAD_URL/$CONDA_INSTALLER && \
    bash $CONDA_INSTALLER -b -p $HOME/miniconda3
RUN $HOME/miniconda3/bin/conda update -y conda

# Add security and certificates to Jupyter
RUN cd $HOME/.cert/ && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "mycert.key" -out "mycert.pem" -batch

RUN $HOME/miniconda3/bin/python create_hashed_password.py

# Clean up
RUN rm create_hashed_password.py $CONDA_INSTALLER

EXPOSE 8888
VOLUME /share

CMD ["bash"]

