#!/bin/bash

usage(){
cat <<EOF
usage: `basename $0` options
Installs genomedisco.
OPTIONS
   -h               Show this message and exit
   --pathtopython   Path to python. DEFAULT: python
   --pathtor        Path to R. DEFAULT: R
   --rlib           Path to R libraries. DEFAULT=''
   --pathtobedtools Path to bedtools. DEFAULT=bedtools
   --modules        Names of modules to be loaded. Comma-delimited. This can be used on computing clusters with shared installations, and will be loaded as 'module load modulename'. DEFAULT=''

EOF
}

ARGS=`getopt -o "h" -l "pathtopython:,pathtor:,rlib:,pathtobedtools:,modules:" -- "$@"`
#eval set -- "$ARGS"

#DEFAULTS
PATHTOPYTHON="python"
PATHTO="R"
RLIB=""
PATHTOBEDTOOLS=""
MODULES=""

while [ $# -gt 0 ]; do
    case $1 in
    -h) usage; exit 1;;
    --pathtopython) PATHTOPYTHON=$2; shift 2;;
    --pathtor) PATHTOR=$2; shift 2;;
    --rlib) RLIB=$2; shift 2;;
    --pathtobedtools) PATHTOBEDTOOLS=$2; shift 2;;
    --modules) MODULES=$2; shift 2;;
    *) usage; exit 1;;
    esac          
done

#============================
# install location
#============================
dir_of_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
repo_dir=$(dirname ${dir_of_script})

#if any modules should be loaded, load them now
for modulename in $(echo ${MODULES} | sed 's/,/ /g');
do
    module load ${modulename}
done

#for plotting score heatmaps
cmd="${PATHTOR} -e 'install.packages(\"pheatmap\"${libtext},repos=\"http://cran.rstudio.com/\")'"
eval "${cmd}"

#==================
#make a bashrc file
#==================
mkdir -p ${repo_dir}/scripts
bashrc_file=${repo_dir}/scripts/bashrc.genomedisco

#for genomedisco
echo "CODEDIR=${repo_dir}/" > ${bashrc_file}
echo "mypython=${PATHTOPYTHON}" >> ${bashrc_file}
echo "export PYTHONPATH=\""'$'"{PYTHONPATH}:"'$'"{CODEDIR}:"'$'"{CODEDIR}/genomedisco/comparison_types/\"" >> ${bashrc_file}

#add any module load commands
for modulename in $(echo ${MODULES} | sed 's/,/ /g');
do
    echo "module load ${modulename}" >> ${bashrc_file}
done

#point to R libraries
if [[ ${RLIB} != "" ]];
then
    echo "export R_LIBS=\"$(echo ${RLIB})\"" >> ${bashrc_file}
    echo "export R_LIBS_USER="'$'"{R_LIBS}" >> ${bashrc_file}
fi

#point to bedtools
echo "mybedtools=${PATHTOBEDTOOLS}" >> ${bashrc_file}
