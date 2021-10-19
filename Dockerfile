FROM codercom/code-server:3.12.0

RUN sudo apt-get -y update && \
    sudo apt-get -y install wget \
                            python3-pip \
                            pipenv \ 
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
RUN sudo cd /usr/bin && \
    wget https://releases.hashicorp.com/vault/1.3.4/vault_1.3.4_linux_amd64.zip && \
    unzip vault_1.3.4_linux_amd64.zip && \
    rm vault_1.3.4_linux_amd64.zip
RUN sudo vault -autocomplete-install


ENV PYTHONPATH="${PYTHONPATH}:/home/coder/.local/bin"
ENV PATH="/home/coder/.local/bin:${PATH}"
ADD requirements.txt /home/coder/requirements.txt
RUN pip3 install --upgrade -r /home/coder/requirements.txt
RUN rm /home/coder/requirements.txt


# INSTALL VSTUDIO EXTENSIONS

RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
RUN code-server --install-extension redhat.vscode-yaml  

RUN code-server --install-extension coenraads.bracket-pair-colorizer
RUN code-server --install-extension eamodio.gitlens
RUN code-server --install-extension ms-azuretools.vscode-docker
#RUN code-server --install-extension ms-python.vscode-pylance
#RUN code-server --install-extension ms-toolsai.jupyter
RUN code-server --install-extension dongli.python-preview
RUN code-server --install-extension njpwerner.autodocstring
RUN code-server --install-extension bierner.markdown-emoji


#ADD vscode-settings.json /home/coder/.local/share/code-server/User/settings.json



# INSTALL MINICONDA -------------------------------

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
#RUN sudo mkdir -p /home/coder/local/bin/conda

RUN sudo bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/coder/local/bin/conda
RUN rm -f Miniconda3-latest-Linux-x86_64.sh
RUN sudo useradd -s /bin/bash miniconda
    
RUN sudo chown -R miniconda:miniconda /home/coder/local/bin/conda \
    && sudo chmod -R go-w /home/coder/local/bin/conda

    
RUN sudo ln -s /home/coder/local/bin/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
    
ENV PATH="/home/coder/local/bin/conda/bin:${PATH}"
RUN conda --version

# Create the environment:
COPY environment.yml .
RUN conda env create -f environment.yml -n basesspcloud


# MAKE SURE THE basesspcloud CONDAENV IS USED ----------------

ENV CONDA_DEFAULT_ENV="basesspcloud"


RUN echo "alias pip=pip3" >> ~/.bashrc
RUN echo "alias python=python3" >> ~/.bashrc

#RUN echo "conda activate basesspcloud" >> ~/.bashrc
RUN echo "{\"workbench.colorTheme\": \"Default Dark+\", \"python.pythonPath\": \"/home/coder/.conda/envs/basesspcloud/bin\"}" >> /home/coder/.local/share/code-server/User/settings.json

# Nice colors in python terminal
RUN echo "import sys ; from IPython.core.ultratb import ColorTB ; sys.excepthook = ColorTB() ;" >> /home/coder/.conda/envs/basesspcloud/lib/python3.9/site-packages/sitecustomize.py

ENV PATH="/home/coder/.conda/envs/basesspcloud/bin:$PATH"
