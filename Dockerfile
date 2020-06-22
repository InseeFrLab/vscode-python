FROM codercom/code-server:3.4.1
RUN sudo apt-get -y update && sudo apt-get -y install python3-pip pipenv cmake
RUN export PYTHONPATH="${PYTHONPATH}:/home/coder/.local/bin"
ADD requirements.txt /home/coder/requirements.txt
RUN pip3 install --upgrade -r /home/coder/requirements.txt
RUN rm /home/coder/requirements.txt
RUN code-server --install-extension ms-python.python
#ADD vscode-settings.json /home/coder/.local/share/code-server/User/settings.json

