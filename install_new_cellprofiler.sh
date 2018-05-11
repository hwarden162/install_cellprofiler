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
set -e
# exit the install script if anything fails

# load anaconda
module load anaconda/5.0.1

ENV_NAME=cellprofiler
GROUP_NAME=igmm_datastore_Drug-Discovery
DRUG_DISCOVERY_PREFIX=/exports/igmm/eddie/Drug-Discovery

# check user is in the Drug-Discovery group
if groups "$USER" | grep -qw "$GROUP_NAME"
then
    # get user, and set correct directory name in Drug-Discovery
    if [ $USER == "s1117349" ]
    then
        PERSON="Becka"
    elif [ $USER == "s1027820" ]
    then
        PERSON="scott"
    else
        echo "ERROR: unknown user, cannot set correct directory in $DRUG_DISCOVERY_PREFIX"
        echo "Change this script to match \$USER with what your directory in"
        echo "$DRUG_DISCOVERY_PREFIX is called"
        exit 1
    fi
else
    echo "$USER not found in Drug-Discovery group, exiting"
    exit 1
fi



# set up conda env to save packages in Drug-Discovery, not the in the home
# directory -- otherwise we run out of space
# create a .condarc file in your home directory
# create directories for conda

CONDA_PKGS=""$DRUG_DISCOVERY_PREFIX"/"$PERSON"/.conda_pkgs"
CONDA_ENVS=""$DRUG_DISCOVERY_PREFIX"/"$PERSON"/.conda_envs"

cat <<EOT >> ~/.condarc
pkgs_dirs:
    - $CONDA_PKGS
envs_dirs:
    - $CONDA_ENVS
EOT


if [ ! -d "$CONDA_PKGS" ]
then
    mkdir "$CONDA_PKGS"
fi

if [ ! -d "$CONDA_ENVS" ]
then
    mkdir "$CONDA_ENVS"
fi

# create new directory to store the environment
CONDA_ENV_DIRECTORY=""$DRUG_DISCOVERY_PREFIX"/$PERSON/"$ENV_NAME"_conda_env"

if [ -d "$CONDA_ENV_DIRECTORY" ]
then
    echo "Warning: replacing $CONDA_ENV_DIRECTORY"
    rm -rf "$CONDA_ENV_DIRECTORY"
fi

mkdir "$CONDA_ENV_DIRECTORY"
cd "$CONDA_ENV_DIRECTORY"



# create an environment file and save it as 'environment.yml'
# in the current directory
cat <<EOT >> environment.yml
# to remove run: conda env remove -n $ENV_NAME
name: $ENV_NAME
# in order of priority: lowest (top) to highest (bottom)
channels:
    - anaconda
    - goodman
    - bjornfjohansson # for wxpython on linux
    - bioconda
    - cyclus # for java stuff
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
    - wxpython=3.0.2.0
    - pip:
         - cellh5
         - centrosome
         - inflect
         - prokaryote==2.3.3
         - javabridge==1.0.15
         - python-bioformats==1.4.0
         - git+https://github.com/Swarchal/CellProfiler.git@master #CellProfiler fork frozen at version 3.0.0
EOT

# fix JAVA_HOME so javabridge points to where anaconda's java install is going to be
CONDA_ENV_PREFIX="$CONDA_ENVS"/"$ENV_NAME"
export JAVA_HOME=$CONDA_ENV_PREFIX

# call conda to create this environment from the environment.yml
conda env create -f environment.yml
# update, as sometimes prokaryote and javabridge don't install properly
conda env update -f environment.yml

echo "DONE!"

exit 0
