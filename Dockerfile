FROM codercom/code-server:3.0.1
RUN sudo apt-get -y update && sudo apt-get -y install python3-pip
RUN export PYTHONPATH="${PYTHONPATH}:/home/coder/.local/bin"
ADD requirements.txt /home/coder/requirements.txt
RUN pip3 install --upgrade -r /home/coder/requirements.txt
RUN rm /home/coder/requirements.txt
RUN code-server --install-extension ms-python.python
RUN mkdir /home/coder/hello-world
RUN echo "print('hello')" >> /home/coder/hello-world/main.py
#ADD vscode-settings.json /home/coder/.local/share/code-server/User/settings.json

#RUN pip3 install --upgrade shapely descartes geopandas rtree gsconfig-py3 cython fasttext tensorflow keras kerasvis pytorch spark pyspark pandas numpy scikit-learn datetime unidecode spacy nltk xgboost
