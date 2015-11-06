#!/bin/bash
# Author: Yan Y. Liu <yanliu@illinois.edu>, 11/05/2015
# install python modules needed for the plantcv extractor.
# run this on standalone plantcv extractor deployment. 
# do not run in plantcv docker container
# if you use anaconda, using virtualenv with it has undefined behavior

### root
sudo apt-get install -y -q python-pip 

### user
yes | pip install virtualenv
virtualenv pyenv
source pyenv/bin/activate && pip install pika requests && pip install git+https://opensource.ncsa.illinois.edu/stash/scm/cats/pyclowder.git && deactivate

