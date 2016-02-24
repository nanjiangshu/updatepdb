#!/bin/bash

#ChangeLog 2014-11-26
#   exclude validation_reports

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
 "

if [ "$DATADIR" == "" ]; then
    echo "The environmental variable DATADIR does not exist, please set it. Exit!" >&2
    exit
fi

function IsProgExist()#{{{
# usage: IsProgExist prog
# prog can be both with or without absolute path
{
    type -P $1 &>/dev/null || { echo "The program \"$1\" is required but it's not installed. Aborting." >&2; exit 1; }
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

IsProgExist dirname
IsProgExist rsync

targetDIR=$DATADIR/pdb/data/structures/divided/pdb/ 
mkdir -p $targetDIR
rsync -rlpt -v -z --delete --port=33444 rsync.wwpdb.org::ftp_data/structures/divided/pdb/  $targetDIR

targetDIR=$DATADIR/pdb/data/structures/obsolete/pdb/ 
mkdir -p $targetDIR
rsync -rlpt -v -z --delete --port=33444 rsync.wwpdb.org::ftp_data/structures/obsolete/pdb/  $targetDIR

targetDIR=$DATADIR/pdb/data/structures/models/current/pdb/ 
mkdir -p $targetDIR
rsync -rlpt -v -z --delete --port=33444 rsync.wwpdb.org::ftp_data/structures/models/current/pdb/  $targetDIR

targetDIR=$DATADIR/pdb/data/structures/models/obsolete/pdb/ 
mkdir -p $targetDIR
rsync -rlpt -v -z --delete --port=33444 rsync.wwpdb.org::ftp_data/structures/models/obsolete/pdb/  $targetDIR

# derived date
targetDIR=$DATADIR/pdb/derived_data/
mkdir -p $targetDIR
rsync -rlpt -v -z --delete --port=33444 rsync.wwpdb.org::ftp_derived $targetDIR

# download other information, but not structure
targetDIR=$DATADIR/pdb/
rsync -rlpt -v -z --delete --exclude="data" --exclude="derived_date"  --exclude="validation_reports" --port=33444 rsync.wwpdb.org::ftp $targetDIR
