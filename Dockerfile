# 1) choose base container
# generally use the most recent tag

# data science notebook
# https://hub.docker.com/repository/docker/ucsdets/datascience-notebook/tags
FROM jupyter/scipy-notebook:d113a601dbb8

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# CUDA Toolkit
RUN conda install -y cudatoolkit=10.1 cudnn nccl && \
    conda clean --all -f -y


# 2) install packages
# Pytorch 1.7.*
# Copy-paste command from https://pytorch.org/get-started/locally/#start-locally
# Use the options stable, linux, pip, python and appropriate CUDA version
RUN pip install --no-cache-dir \
    torch==1.7.1+cu101 torchvision==0.8.2+cu101 torchaudio==0.7.2 \
    -f https://download.pytorch.org/whl/torch_stable.html

# #  Add startup script
USER root


# 3) Setup CARLA
RUN pip install --no-cache-dir networkx scipy python-louvain
RUN conda install -y cudatoolkit=10.1 cudnn nccl && \
    conda clean --all -f -y

# Install dependencies
RUN sudo apt-get update
RUN sudo apt-get install software-properties-common -y
RUN sudo add-apt-repository ppa:ubuntu-toolchain-r/test
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
RUN sudo apt-add-repository "deb http://apt.llvm.org/$(lsb_release -c --short)/ llvm-toolchain-$(lsb_release -c --short)-8 main"
RUN sudo apt-get update

# Change default clang version
RUN sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180
RUN sudo update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180

# 4) change back to notebook user
COPY /run_jupyter.sh /
RUN chmod 755 /run_jupyter.sh

# 5) change back to notebook user
USER $NB_UID
