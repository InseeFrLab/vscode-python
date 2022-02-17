FROM codercom/code-server:4.0.2
ARG PYTHON_VERSION=3.10

RUN sudo apt-get -y update && \
    sudo apt-get -y install wget \
                            cmake \
                            jq \
                            bash-completion \
                            vim

# Install kubectl
RUN sudo wget "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" -O /usr/local/bin/kubectl && \
    sudo chmod +x /usr/local/bin/kubectl
RUN sudo sh -c "kubectl completion bash >/etc/bash_completion.d/kubectl" 

# Install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Install mc
RUN sudo wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    sudo chmod +x /usr/local/bin/mc

# Install vault
RUN sudo apt-get install -y unzip
RUN cd /usr/bin && \
    sudo wget https://releases.hashicorp.com/vault/1.8.4/vault_1.8.4_linux_amd64.zip && \
    sudo unzip vault_1.8.4_linux_amd64.zip && \
    sudo rm vault_1.8.4_linux_amd64.zip
RUN sudo vault -autocomplete-install

# INSTALL MINICONDA -------------------------------
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/coder/local/bin/conda
RUN rm -f Miniconda3-latest-Linux-x86_64.sh

# Install mamba (speed up packages install with conda)
# Must be in base conda env
ENV PATH="/home/coder/local/bin/conda/bin:${PATH}"
RUN conda install mamba -n base -c conda-forge

# Install env requirements
RUN conda create -n basesspcloud python=$PYTHON_VERSION
COPY environment.yml .
RUN mamba env update -n basesspcloud -f environment.yml
ENV PATH="/home/coder/local/bin/conda/envs/basesspcloud/bin:${PATH}"

# Put additional VSCode settings in remote configuration
RUN mkdir -p /home/coder/.local/share/code-server/Machine/
COPY settings.json /home/coder/.local/share/code-server/Machine/settings.json

# Nice colors in python terminal
RUN echo "import sys ; from IPython.core.ultratb import ColorTB ; sys.excepthook = ColorTB() ;" >> /home/coder/local/bin/conda/envs/basesspcloud/lib/python${PYTHON_VERSION}/site-packages/sitecustomize.py

# INSTALL VSTUDIO EXTENSIONS
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
RUN code-server --install-extension ms-azuretools.vscode-docker
RUN code-server --install-extension njpwerner.autodocstring
RUN code-server --install-extension redhat.vscode-yaml  

ENTRYPOINT ["conda", "run", "-n", "basesspcloud", "/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]
