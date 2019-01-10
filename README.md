# UpdatePDB
## Description:
Save the PDB locally in the same data structure as the RCSB archive under $DATADIR

<pre>
   pdb/data/structures/divided/pdb             : the main PDB archive, experimental structures
   pdb/data/structures/obsolete/pdb            : the obsolete PDB archive, experimental structures
   pdb/data/structures/models/current/pdb      : for theoretical structures, main archive
   pdb/data/structures/models/obsolete/pdb     : for theoretical structures, obsolete archive

and the decompressed data are stored at
   pdb/data/structures/divided/pdb_dcp         : the main PDB archive, experimental structures
   pdb/data/structures/obsolete/pdb_dcp        : the obsolete PDB archive, experimental structures
   pdb/data/structures/models/current/pdb_dcp  : for theoretical structures, main archive
   pdb/data/structures/models/obsolete/pdb_dcp : for theoretical structures, obsolete archive
</pre>

## Contact:
Nanjiang Shu

Email: nanjiang.shu@scilifelab.se

System developers at NBIS

## Usage:

First set the DATADIR, e.g., if you want to store your local PDB at /data, then
run

    export DATADIR=/data

After that, just run

    bash updatepdb.sh

It is recommended to set up a cron job so that the database will be kept updated.
For example:

run updatepdb.sh every Sunday at 1am

    0 1 * * 0 (export DATADIR=/data; /usr/local/share/updatepdb/updatepdb.sh) >> /var/log/updatepdb.log 2>&1


