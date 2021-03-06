#!/bin/bash
# extract plantcv info from an input image.
# it calls the appropriate python script in plantcv based on input file
# name pattern, e.g., VIS_SV_180_z700_379476.jpg will call 
# plantcv/scripts/image_analysis/vis_sv/vis_sv_z700_L1.py
# output is stored in a directory named fileid (as input argument).
# a file .filelist is created to list output files
# a file .log is created to show a summary of plantcv execution.
# a file .stdouterr is created to include redirected python std, for debug

function nicequit { # nicequit 0, or nicequit 1
  returncode=$1
  [ ! -z "$infolog" ] && echo -e "$infolog" > $odir/.log
  [ -n $tdirnum ] && rm -fr /tmp/$tdirnum
  exit $returncode
}

### set up env
# read input file name and id
infile="$1"
filename="$2"
fileid="$3"
odir="$4" #must be absolute path
if [[ ! -f $infile || -z $filename || -z $fileid || ! -d $odir ]]; then
  echo "Missing arguments or inaccessible paths: $infile $filename $fileid $odir"
  echo "usage: extract.sh input_image filename fileid outputdir"
  exit 1
fi
mkdir -p $odir/$fileid
if [ ! -d "$odir/$fileid" ]; then
  echo "ERROR: cannot create output dir $odir"
  exit 1
fi
odir=$odir/$fileid # new output dir
if [ -z "$PLANTCV_HOME" ]; then
  export PLANTCV_HOME=$HOME/plantcv
fi
# infile filename != filename
tdirnum=$RANDOM
mkdir /tmp/$tdirnum
cp $infile /tmp/$tdirnum/$filename
infile=/tmp/$tdirnum/$filename # new infile

T0=`date +%s`
infolog="===plantcv:extract.sh start@$T0 `date`===" # log info

infostd=$odir/.stdouterr
infolst=$odir/.filelist
toolConvert="convert" # imagemagick convert, optional

### run plantcv script
# parse file name pattern
tags=`echo "$filename" | awk -F_ '{print tolower($1) " " tolower($2) " " tolower($3) " " tolower($4)}'`
tagsa=($tags)
pytype="${tagsa[0]}_${tagsa[1]}"
if [ $pytype == "vis_sv" ]; then
  zoom=${tagsa[3]}
else
  zoom=${tagsa[2]}
fi
pyname="${pytype}_${zoom}_L1.py"
pyscript=$PLANTCV_HOME/scripts/image_analysis/$pytype/$pyname
[ ! -f "$pyscript" ] && \
  infolog="$infolog\nERROR: cannot access plantcv script $pyscript" && \
  nicequit 1
# find mask
case "$pytype" in
  vis_tv)
    vvv=`echo "$pytype" | awk -F_ '{print $2}'`
    maskopt="-m $PLANTCV_HOME/masks/$pytype/mask_brass_${vvv}_${zoom}_L1.png"
    ;;
  nir_tv)
    vvv=`echo "$pytype" | awk -F_ '{print $1}'`
    maskopt="-m $PLANTCV_HOME/masks/$pytype/background_${vvv}_${zoom}.png"
    ;;
  *)
    maskopt="" # vis_sv doesn't need mask, either
esac
# call script
infolog="$infolog\nEXEC: $pyscript -i $infile $maskopt -o $odir"
python $pyscript -i $infile $maskopt -o $odir >$infostd 2>&1
[ $? -ne 0 ] && \
  infolog="$infolog\nWARNING: $pyscript did not finish nicely"
### check output, create result info
ofiles=""
for f in `ls $odir/*.jpg`; do
  ofiles="$ofiles `basename $f`"
done
for f in `ls $odir/*.svg`; do
  jpgf="`basename $f .svg`.jpg"
  convert $f "`dirname $f`/$jpgf"
  ofiles="$ofiles $jpgf"
done
if [ -z "$ofiles" ]; then
  infolog="$infolog\nERROR: plantcv did not produce anything." && \
    nicequit 1
fi
infolog="$infolog\nOUTPUT: $ofiles"
for f in $ofiles; do
  echo "$odir/$f" >> $infolst
done
# copy input image to output dir too for jupyter use
cp "$infile" $odir/
chmod +r "$odir/`basename $infile`"

T1=`date +%s`
infolog="$infolog\nDONE in `expr $T1 \- $T0` seconds."
infolog="$infolog\n===plantcv:extract.sh end@$T1 `date`===" # log info
nicequit 0
