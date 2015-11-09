#!/bin/bash
# Author: Yan Y. Liu <yanliu@illinois.edu>, 11/05/2015
# install python modules needed for the plantcv extractor.
# run this on standalone plantcv extractor deployment. 
# do not run in plantcv docker container
# if you use anaconda, using virtualenv with it has undefined behavior

### make sure you are in the right directory you want pyenv installed
[ ! -d $HOME/arpae ] && mkdir $HOME/arpae
cd $HOME/arpae

### root
sudo apt-get install -y -q python-pip 

### user
yes | pip install virtualenv
virtualenv pyenv
source pyenv/bin/activate && pip install pika requests wheel matplotlib && pip install git+https://opensource.ncsa.illinois.edu/stash/scm/cats/pyclowder.git && deactivate

### fix plantcv bugs
# fix plancv bugs in analyze_color()
for d in nir_sv vis_sv  vis_tv
do
  for f in `ls ${HOME}/plantcv/scripts/image_analysis/$d/*.py`
  do
    /bin/sed -i -e "s#'all','rgb'#'all'#" $f
  done
done

### prepare output dir
[ ! -d "$HOME/plantcv-output" ] && mkdir $HOME/plantcv-output
