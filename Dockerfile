FROM codercom/code-server:4.0.1

RUN sudo apt-get -y update && \
    sudo apt-get -y install wget \
                            cmake \
                            jq \
                            bash-completion
                            
RUN sudo wget "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" -O /usr/local/bin/kubectl && \
    sudo chmod +x /usr/local/bin/kubectl
    
RUN sudo sh -c "kubectl completion bash >/etc/bash_completion.d/kubectl" 

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

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

# RUN sudo chown -R coder:coder /home/coder/local/bin/conda
RUN sudo ln -s /home/coder/local/bin/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

ENV PATH="/home/coder/local/bin/conda/bin:${PATH}"

# Install mamba (speed up packages install with conda)
# Must be in base conda env
RUN conda install mamba -n base -c conda-forge

# Install env requirements in base env
COPY environment.yml .
RUN mamba env update -n base -f environment.yml

RUN echo "alias pip=pip3" >> ~/.bashrc
RUN echo "alias python=python3" >> ~/.bashrc

RUN mkdir -p /home/coder/.vscode/
COPY settings.json /home/coder/.vscode/settings.json

# Nice colors in python terminal
RUN echo "import sys ; from IPython.core.ultratb import ColorTB ; sys.excepthook = ColorTB() ;" >> /home/coder/local/bin/conda/lib/python3.9/site-packages/sitecustomize.py

# INSTALL VSTUDIO EXTENSIONS

RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
RUN code-server --install-extension eamodio.gitlens
RUN code-server --install-extension coenraads.bracket-pair-colorizer
RUN code-server --install-extension ms-azuretools.vscode-docker
RUN code-server --install-extension njpwerner.autodocstring
