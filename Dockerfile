FROM codercom/code-server:3.10.2

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
    
ENV PYTHONPATH="${PYTHONPATH}:/home/coder/.local/bin"
ENV PATH="/home/coder/.local/bin:${PATH}"
ADD requirements.txt /home/coder/requirements.txt
RUN pip3 install --upgrade -r /home/coder/requirements.txt
RUN rm /home/coder/requirements.txt
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
RUN code-server --install-extension redhat.vscode-yaml  
#ADD vscode-settings.json /home/coder/.local/share/code-server/User/settings.json


RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN sudo mkdir -p /usr/local/bin/conda

RUN bash Miniconda3-latest-Linux-x86_64.sh -b -u /usr/local/bin/conda \
    && rm -f Miniconda3-latest-Linux-x86_64.sh
RUN sudo useradd -s /bin/bash miniconda
    
RUN sudo chown -R miniconda:miniconda /usr/local/bin/conda \
    && sudo chmod -R go-w /usr/local/bin/conda

    
RUN sudo ln -s /usr/local/bin/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
    
ENV PATH /usr/local/bin/conda/bin:$PATH
RUN conda --version

# Create the environment:
COPY environment.yml .
RUN conda env create -f environment.yml -n base


RUN echo "alias pip=pip3" >> ~/.bashrc
RUN echo "alias python=python3" >> ~/.bashrc

RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc