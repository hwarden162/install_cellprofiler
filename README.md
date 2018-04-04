# Installing CellProfiler on eddie3

*Note: these instructions will only work for the Drug-Discovery group at the
University of Edinburgh. You should be able to change the filepaths if you're
using this elsewhere.*

To install cellprofiler run the following in a qlogin session with at least 8GB
of memory:
```shell
wget https://raw.githubusercontent.com/CarragherLab/install_cellprofiler/master/install_new_cellprofiler.sh | bash
```

This takes a while, it probably hasn't frozen.

This creates an anaconda environment for each user.

To load this environment run:
```shell
module load anaconda/5.0.1
source activate cellprofiler
```
