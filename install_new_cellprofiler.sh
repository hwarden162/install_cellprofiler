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
module load anaconda

ENV_NAME=cellprofiler
GROUP_NAME=igmm_datastore_Drug-Discovery
DRUG_DISCOVERY_PREFIX=/exports/igmm/eddie/Drug-Discovery

# check user is in the Drug-Discovery group
if groups "$USER" | grep -qw "$GROUP_NAME"
then
    if [ ! -d "DRUG_DISCOVERY_PREFIX"/"$USER" ]; then
        mkdir "$DRUG_DISCOVERY_PREFIX"/"$USER"
    fi
    CONDA_PKGS=""$DRUG_DISCOVERY_PREFIX"/"$USER"/.conda_pkgs"
    CONDA_ENVS=""$DRUG_DISCOVERY_PREFIX"/"$USER"/.conda_envs"
else
    echo "$USER not found in Drug-Discovery group, exiting"
    exit 1
fi



# set up conda env to save packages in Drug-Discovery, not the in the home
# directory -- otherwise we run out of space

# create paths to locations in Drug-Discovery/$USER
CONDA_PKGS=""$DRUG_DISCOVERY_PREFIX"/"$USER"/.conda_pkgs"
CONDA_ENVS=""$DRUG_DISCOVERY_PREFIX"/"$USER"/.conda_envs"

# Append package and environment directory locations # to the .condarc file in
# the user's home directory. This is used by anaconda as the location to store
# dependencies and what not. If this is not set
cat <<EOT >> ~/.condarc
pkgs_dirs:
    - $CONDA_PKGS
envs_dirs:
    - $CONDA_ENVS
EOT

# If the anaconda package and environment directories:
#      /exports/eddie/Drug-Discovery/$USER/.conda_pkgs
#      /exports/eddie/Drug-Discovery/$USER/.conda_envs
# don't yet exist then these are created
if [ ! -d "$CONDA_PKGS" ]
then
    mkdir "$CONDA_PKGS"
fi

if [ ! -d "$CONDA_ENVS" ]
then
    mkdir "$CONDA_ENVS"
fi

# Create new directory to store the environment. This environment is
# unique to the user's CellProfiler installation.
CONDA_ENV_DIRECTORY=""$DRUG_DISCOVERY_PREFIX"/$USER/"$ENV_NAME"_conda_env"

if [ -d "$CONDA_ENV_DIRECTORY" ]
then
    echo "Warning: replacing $CONDA_ENV_DIRECTORY"
    rm -rf "$CONDA_ENV_DIRECTORY"
fi

mkdir "$CONDA_ENV_DIRECTORY"
cd "$CONDA_ENV_DIRECTORY"



# Create an environment file and save it as 'environment.yml' in the current
# directory. This file contains the dependencies and versions required by
# cellprofiler. Package version numbers are tricky and will need to be changed
# if a different version of CellProfiler is installed. Dependencies unique to
# CellProfiler (prokaryote, centrosome) are often updated so that they only
# work with the latest version of CellProfiler.
cat <<EOT >> environment.yml
# run: conda env create -f environment.yml
# run: conda env update -f environment.yml
# run: conda env remove -n cellprofiler
name: cellprofiler
# in order of priority: lowest (top) to highest (bottom)
channels:
    - anaconda
    - goodman # mysql-python for mac
    - bjornfjohansson
    - bioconda
    - cyclus # java-jdk for windows
    - conda-forge # libxml2 for windows
dependencies:
    - appdirs
    - cython=0.28.5
    - h5py=2.8.0
    - ipywidgets
    - java-jdk
    - jupyter=1.0.0
    - libtiff
    - libxml2
    - libxslt
    - lxml=4.2.5
    - packaging=17.1
    - pillow=5.2.0
    - pip
    - python=2
    - pyzmq=15.3.0
    - mahotas=1.4.4
    - matplotlib=2.2.3
    - mysql-python
    - numpy=1.14.5
    - raven=6.3.0
    - requests=2.18.4
    - scikit-image=0.14.0
    - scikit-learn=0.19.1
    - scipy=1.1.0
    - sphinx
    - tifffile=0.15.1
    - wxpython=3.0.2.0
    - pip:
        - cellh5==1.3.0
        - centrosome==1.0.9
        - inflect==1.0.0
        - prokaryote==2.4.0
        - javabridge==1.0.15
        - python-bioformats==1.4.0
        - git+https://github.com/CarragherLab/CellProfiler.git@master
EOT



# Fix $JAVA_HOME so javabridge points to where anaconda's java install is going
# to be.
CONDA_ENV_PREFIX="$CONDA_ENVS"/"$ENV_NAME"
export JAVA_HOME=$CONDA_ENV_PREFIX


# Call conda to create this environment from the environment.yml
conda env create -f environment.yml
# Call again and update, as sometimes prokaryote and javabridge don't install
# properly
conda env update -f environment.yml

echo "DONE!"

exit 0
