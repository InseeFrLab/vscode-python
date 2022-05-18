FROM codercom/code-server:4.4.0
ARG PYTHON_VERSION=3.10
ARG QUARTO_VERSION="0.9.393"

USER root

# Install common softwares
RUN apt-get -y update && \ 
    curl -s https://raw.githubusercontent.com/InseeFrLab/onyxia/main/resources/common-software-docker-images.sh | bash -s && \
    apt-get install -y --no-install-recommends cmake g++ && \
    rm -rf /var/lib/apt/lists/*

# Install QUARTO
RUN wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb"
RUN apt install "./quarto-${QUARTO_VERSION}-linux-amd64.deb"

# INSTALL MINICONDA -------------------------------
ARG CONDA_DIR=/home/coder/local/bin/conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p $CONDA_DIR
RUN rm -f Miniconda3-latest-Linux-x86_64.sh

# Install mamba (speed up packages install with conda)
# Must be in base conda env
ENV PATH="/home/coder/local/bin/conda/bin:${PATH}"
RUN conda install mamba -n base -c conda-forge

# Install env requirements
RUN conda create -n basesspcloud python=$PYTHON_VERSION
COPY environment.yml .
RUN mamba env update -n basesspcloud -f environment.yml

# Make basesspcloud env activated by default in shells
ENV PATH="/home/coder/local/bin/conda/envs/basesspcloud/bin:${PATH}"
RUN echo "export PATH=$PATH" >> /home/coder/.bashrc  # Temporary fix while PATH gets overwritten by code-server

# Additional VSCode settings
# Put in remote settings because : https://github.com/coder/code-server/issues/4609
RUN mkdir -p /home/coder/.local/share/code-server/Machine/
COPY settings.json /home/coder/.local/share/code-server/Machine/settings.json

# INSTALL VSTUDIO EXTENSIONS
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
RUN code-server --install-extension ms-azuretools.vscode-docker
RUN code-server --install-extension njpwerner.autodocstring
RUN code-server --install-extension redhat.vscode-yaml
RUN code-server --install-extension quarto.quarto
