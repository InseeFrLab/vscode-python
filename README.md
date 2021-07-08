# What is vscode-python?

A docker image based on https://github.com/cdr/code-server tailored for python programming.

It aims to provide a state-of-the-art IDE with some modules adapted to `Python` to help developers.  

# How to use it

To run a `Python` script in interactive mode, create a new file with `.py` extension, write some commands, e.g. 

```python
import pandas as pd
pd.DataFrame([0, 1, 2])
```

and press ```SHIFT + ENTER```

If you need a package, e.g. `flask`, open a terminal and run 

```shell
pip install flask
```

Everything is integrated within a `conda` environment. You can also use

```shell
conda install flask
```

in a terminal if you prefer. 

You can also edit a `Jupyter Notebook` (extension `.ipynb`) file. The Jupyter
extension as well as additional useful extensions (`Git Lens` among others)
is available. 

Please visit https://github.com/cdr/code-server to learn how to use this image.


# How to contribute
If you find something is missing for general python programming with this image, don't hesitate to let us know, either with an issue or by submitting a PR.

# Tips

- Use [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync) to sync up your custom configuration and extension and start a new properly tuned session in a heartbeat.
- The paste shortcut in the terminal is: ```SHIFT + INSER```
- To execute code use ```SHIFT + ENTER```

# Run in a local container

First pull the image:

```shell
docker pull InseeFrLab/vscode-python
```

```shell
docker run -it -p 127.0.0.1:8080:8080 -e PASSWORD="YOUR_PASSWORD" InseeFrLab/vscode-python
```

:tada: open your browser at `http://localhost:8080/` and use the password you chose (e.g. `YOUR_PASSWORD`)
