#!/bin/bash

################################################################################
######### Script to install cellprofiler into an anaconda environment. #########
################################################################################
#
# Need to run this in qlogin session, with around 8GB of memory:
#
# >>> qlogin -l h_vmem=8G
#
# then find this script and run:
#
# >>> ./install_new_cellprofiler.sh
#
# It should take a few minutes, and looks like it's frozen after downloading
# scikit-image, but it's fine.
#
# You'll also have to re-install cptools2 for the generated analysis scripts to
# point to the new anaconda environment.

# >>> module load python
# >>> cd /exports/igmm/eddie/Drug-Discovery/tools/cptools2
# >>> python setup.py install --user
#
################################################################################



# this makes sure ctrl-c properly stops the script
trap "exit" INT

# exit the install script if anything fails
set -e


# load anaconda
module load anaconda/5.0.1


# get user, and set correct directory name in Drug-Discovery
if [ $USER == "s1117349" ]
then
    PERSON="Becka"
elif [ $USER == "s1027820" ]
then
    PERSON="scott"
else
    echo "ERROR: unknown user, cannot set correct directory in /exports/igmm/eddie/Drug-Discovery"
    echo "Change this script to match \$USER with what your directory in"
    echo "/exports/igmm/eddie/Drug-Discovery is called"
    exit 1
fi



# set up conda env to save packages in Drug-Discovery, not the in the home
# directory -- otherwise we run out of space
# create a .condarc file in your home directory
cat <<EOT >> ~/.condarc
pkgs_dirs:
    - /exports/igmm/eddie/Drug-Discovery/$PERSON/.conda_pkgs
envs_dirs:
    - /exports/igmm/eddie/Drug-Discovery/$PERSON/.conda_envs
EOT

# create directories for conda
CONDA_PKGS="/exports/igmm/eddie/Drug-Discovery/$PERSON/.conda_pkgs"
CONDA_ENVS="/exports/igmm/eddie/Drug-Discovery/$PERSON/.conda_envs"

if [ ! -d "$CONDA_PKGS" ]
then
    mkdir "$CONDA_PKGS"
fi

if [ ! -d "$CONDA_ENVS" ]
then
    mkdir "$CONDA_ENVS"
fi

# create new directory to store the environment
CONDA_ENV_DIRECTORY="/exports/igmm/eddie/Drug-Discovery/$PERSON/cellprofler_conda_env"

if [ -d "$CONDA_ENV_DIRECTORY" ]
then
    echo "Error: $CONDA_ENV_DIRECTORY already exists"
    exit 1
fi

mkdir /exports/igmm/eddie/Drug-Discovery/$PERSON/cellprofiler_conda_env

# move to the newly created directory
cd /exports/igmm/eddie/Drug-Discovery/$PERSON/cellprofiler_conda_env



# create an environment file and save it as 'environment.yml'
# in the current directory
cat <<EOT >> environment.yml
# to remove run: conda env remove -n cellprofiler
name: cellprofiler
# in order of priority: lowest (top) to highest (bottom)
channels:
    - anaconda
    - bjornfjohansson # for wxpython on linux
    - bioconda
    - conda-forge # for mahotas
dependencies:
    - appdirs
    - boto3
    - cython
    - h5py
    - ipywidgets
    - java-jdk
    - jupyter
    - libtiff
    - libxml2
    - libxslt
    - lxml
    - packaging
    - pillow
    - pip
    - python=2
    - pyzmq=15.3.0
    - mahotas
    - matplotlib!=2.1.0,>2.0.0
    - mysql-python
    - numpy
    - raven
    - requests
    - scikit-image>=0.13
    - scikit-learn
    - scipy
    - sphinx
    - tifffile
    - wxpython
    - pip:
         - cellh5
         - centrosome
         - inflect
         - prokaryote==2.3.3
         - javabridge==1.0.15
         - python-bioformats==1.4.0
         - git+https://github.com/Swarchal/CellProfiler.git@master # CellProfiler fork frozen at version 3.1.3
EOT

# call conda to create this environment from the environment.yml
conda env create -f environment.yml
# update, as sometimes prokaryote and javabridge don't install properly
conda env update -f environment.yml

echo "DONE!"

exit 0
