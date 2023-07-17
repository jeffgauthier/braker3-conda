#!/bin/bash

# create conda environment for the container
source $CONDA_PREFIX/etc/profile.d/conda.sh
conda create -n braker3_env
conda activate braker3_env

# install singularity for loading the BRAKER3 container
conda install -c conda-forge singularity

# pull BRAKER3 container
singularity build braker3.sif docker://teambraker/braker3:latest

# test execution (print setup)
singularity exec braker3.sif print_braker3_setup.py

# move GeneMark-ETP license to home folder as required
cat << 'EOF' > ~/gm_key
[!!!!!!!!!!!!!!!!!! Copy the contents of GeneMark-ETP's licence file here !!!!!!!!!!!!!!]
EOF

# test BRAKER3 execution
singularity exec braker3.sif braker.pl

# pull test-data checks
singularity exec -B $PWD:$PWD braker3.sif cp -v /opt/BRAKER/example/singularity-tests/test1.sh .
singularity exec -B $PWD:$PWD braker3.sif cp -v /opt/BRAKER/example/singularity-tests/test2.sh .
singularity exec -B $PWD:$PWD braker3.sif cp -v /opt/BRAKER/example/singularity-tests/test3.sh .

# export path to BRAKER3 container for test scripts
export BRAKER_SIF=$(realpath braker3.sif) # may need to modify

# fix augustus config write permissions workaround
git clone https://github.com/Gaius-Augustus/Augustus
sed -i 's#braker.pl --genome#braker.pl --AUGUSTUS_CONFIG_PATH=$PWD/Augustus/config --genome#g' test*.sh

#run tests
bash test1.sh
bash test2.sh
bash test3.sh

# if installation and tests are successful (set -e), move container
# to conda environment and build wrapper script
cp -vr braker3.sif Augustus $CONDA_PREFIX
cat << 'EOF' > $CONDA_PREFIX/bin/run_braker3
#!/bin/bash
ln -s $CONDA_PREFIX/braker3.sif braker3-lnk.sif
git clone https://github.com/Gaius-Augustus/Augustus
singularity exec -B $PWD:$PWD braker3-lnk.sif braker.pl \
        --AUGUSTUS_CONFIG_PATH=$PWD/Augustus/config $*
rm braker3-lnk.sif Augustus -rf
EOF

# test wrapper script
chmod 775 $CONDA_PREFIX/bin/run_braker3
run_braker3

# clean install
echo "Cleaning temporary install files..."
rm Augustus test1* test2* test3* -rvf
