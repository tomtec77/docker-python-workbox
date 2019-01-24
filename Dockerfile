FROM ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

# Update the base system
COPY ./badproxy /etc/apt/apt.conf.d/99fixbadproxy
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      apt-utils \
      git \
      wget

# Create a default user and home directory
ENV NAME pyuser
ENV HOME /home/$NAME
RUN useradd -d $HOME -s /bin/bash -u 10000 -U -p $NAME $NAME && \
    mkdir $HOME && \
    addgroup $NAME staff && \
    mkdir $HOME/.jupyter && \
    mkdir $HOME/.cert

COPY bashrc.sh $HOME/.bashrc

RUN chown -R $NAME:$NAME $HOME

USER $NAME
WORKDIR $HOME

# Install Miniconda3
ENV CONDA_DOWNLOAD_URL https://repo.anaconda.com/miniconda
ENV CONDA_INSTALLER Miniconda3-latest-Linux-x86_64.sh

RUN wget --progress=bar:force $CONDA_DOWNLOAD_URL/$CONDA_INSTALLER && \
    bash $CONDA_INSTALLER -b -p $HOME/miniconda3

# Clean up
RUN apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&
    rm $CONDA_INSTALLER    

EXPOSE 8888

CMD ["bash"]

