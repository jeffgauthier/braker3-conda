# braker3-singularity-wrapper
A workaround to run BRAKER3 (Singularity version) from a conda env. Based on the install and testing instructions available at:
https://github.com/Gaius-Augustus/BRAKER

It also fixes a write permission issue with AUGUSTUS in the singularity container by using a `git clone` of Augustus config path.

## IMPORTANT NOTE
BRAKER3's dependency GeneMark-ETP requires a license file to be in your `/home` folder, even if running from a singularity image. To obtain it for free, register here: 
http://exon.gatech.edu/genemark/license_download.cgi
Then, copy this file as `gm_key` in your home folder, e.g.: `/home/user/gm_key` or `~/gm_key`

# USAGE
(Assuming that minoconda3 is installed)

`bash install.sh`

Then, BRAKER3 can be run from the command-line using a wrapper script generated during the installing process:

`run_braker3 [options...]`
