#!/bin/bash

README="
update PDB, and save the PDB locally in the same data structure as the RCSB archive
   pdb/data/structures/divided/pdb             : the main PDB archive, experimental structures
   pdb/data/structures/obsolete/pdb            : the obsolete PDB archive, experimental structures
   pdb/data/structures/models/current/pdb      : for theoretical structures, main archive
   pdb/data/structures/models/obsolete/pdb     : for theoretical structures, obsolete archive

and the decompressed data are stored at
   pdb/data/structures/divided/pdb_dcp         : the main PDB archive, experimental structures
   pdb/data/structures/obsolete/pdb_dcp        : the obsolete PDB archive, experimental structures
   pdb/data/structures/models/current/pdb_dcp  : for theoretical structures, main archive
   pdb/data/structures/models/obsolete/pdb_dcp : for theoretical structures, obsolete archive

Usage:
    ./updatepdb.sh 
    Created 2011-03-16, updated 2012-03-23, Nanjiang Shu
 "

if [ "$DATADIR" == "" ]; then
    echo "The environmental variable DATADIR does not exist, please set it. Exit!" >&2
    exit 1
elif [ ! -d $DATADIR ] ; then 
    echo DATADIR $DATADIR unaccessable, exit >&2
    exit 1
fi


function IsProgExist() #{{{
# usage: IsProgExist prog
# prog can be both with or without absolute path
{
    type -P $1 &>/dev/null || { echo "The program \"$1\" is required but it's not installed. Aborting." >&2; exit 1; }
}
#}}}

function IsPathExist() #{{{
# supply the effective path of the program 
{
    if ! test -d $1; then
        echo "Directory $1 does not exist. Aborting." >&2
        exit
    fi
}
#}}}
function AddAbsolutePath() #$path#{{{
{
    local var=$1
    if [ "${var:0:1}" != "/" ];then
        var=$PWD/$var # add the absolut path
    fi
    echo $var
    return 0
}
#}}}

function CopyNewEntry() #sourceDIR targetDIR#{{{
{
    local sourceDIR=$1
    local targetDIR=$2
    local tmppdblist=$(mktemp /tmp/tmp.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
    local tmppdb_dcplist=$(mktemp /tmp/tmp.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
#     echo $tmppdb_dcplist
#     echo $tmppdblist

    IsPathExist $sourceDIR
    mkdir -p $targetDIR
    find $sourceDIR -name "*.gz"  -printf "%p %TY-%Tm-%Td %TH:%TM:%TS\n"  > $tmppdblist
    find $targetDIR -name "*.ent" -printf "%p %TY-%Tm-%Td %TH:%TM:%TS\n"  > $tmppdb_dcplist
    $binpath/copy_new_entry.py $tmppdblist $tmppdb_dcplist $sourceDIR $targetDIR -v

    rm -f $tmppdblist $tmppdb_dcplist
}
#}}}

IsProgExist dirname
IsProgExist find
IsProgExist gzip

binpath=`dirname $0`
binpath=`AddAbsolutePath $binpath`
echo "======================================================"
echo "Date=`date '+%F %H:%M:%S %A Week %V'`"
echo "======================================================"
echo "Begin time=`date '+%F %H:%M:%S'`"

### step 1. download pdb
$binpath/downloadpdbnew.sh

### step 2. extract gz files and upload to the pdb_dcp folder

echo "======================================================"
echo "main"
echo
sourceDIR=$DATADIR/pdb/data/structures/divided/pdb/
targetDIR=$DATADIR/pdb/data/structures/divided/pdb_dcp/ 
CopyNewEntry $sourceDIR $targetDIR

echo "======================================================"
echo "main obsolete"
echo
sourceDIR=$DATADIR/pdb/data/structures/obsolete/pdb/
targetDIR=$DATADIR/pdb/data/structures/obsolete/pdb_dcp/ 
CopyNewEntry $sourceDIR $targetDIR

echo "======================================================"
echo "models"
echo
sourceDIR=$DATADIR/pdb/data/structures/models/current/pdb/
targetDIR=$DATADIR/pdb/data/structures/models/current/pdb_dcp/ 
CopyNewEntry $sourceDIR $targetDIR

echo "======================================================"
echo "models obsolete"
echo
sourceDIR=$DATADIR/pdb/data/structures/models/obsolete/pdb/
targetDIR=$DATADIR/pdb/data/structures/models/obsolete/pdb_dcp/ 
CopyNewEntry $sourceDIR $targetDIR

echo "======================================================"
echo "End time=`date '+%F %H:%M:%S'`"
echo
