LOG: 2011-03-17 13:39:43 Thursday  Week 11 <nanjiang@illergard>
  
update PDB, and save the PDB locally in the same data structure as the RCSB archive 
under $DATADIR

   pdb/data/structures/divided/pdb             : the main PDB archive, experimental structures
   pdb/data/structures/obsolete/pdb            : the obsolete PDB archive, experimental structures
   pdb/data/structures/models/current/pdb      : for theoretical structures, main archive
   pdb/data/structures/models/obsolete/pdb     : for theoretical structures, obsolete archive

and the decompressed data are stored at
   pdb/data/structures/divided/pdb_dcp         : the main PDB archive, experimental structures
   pdb/data/structures/obsolete/pdb_dcp        : the obsolete PDB archive, experimental structures
   pdb/data/structures/models/current/pdb_dcp  : for theoretical structures, main archive
   pdb/data/structures/models/obsolete/pdb_dcp : for theoretical structures, obsolete archive

Usage: updatepdb.sh
