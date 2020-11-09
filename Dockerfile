FROM codercom/code-server:3.6.1
RUN sudo apt-get -y update && sudo apt-get -y install wget python3-pip pipenv cmake  
RUN sudo wget "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" -O /usr/local/bin/kubectl && \
    sudo chmod +x /usr/local/bin/kubectl
RUN sudo wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    sudo chmod +x /usr/local/bin/mc
ENV PYTHONPATH="${PYTHONPATH}:/home/coder/.local/bin"
ENV PATH="/home/coder/.local/bin:${$PATH}"
ADD requirements.txt /home/coder/requirements.txt
RUN pip3 install --upgrade -r /home/coder/requirements.txt
RUN rm /home/coder/requirements.txt
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
RUN code-server --install-extension redhat.vscode-yaml  
#ADD vscode-settings.json /home/coder/.local/share/code-server/User/settings.json
