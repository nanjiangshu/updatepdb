#!/usr/bin/python
#

import sys, os ;
import datetime;
from bisect import bisect;

usage="""
Usage:  copy_new_entry.py pdb_list pdb_dcp_list sourcedir targetdir
  
Options:
  -h|--help       : print this help message and exit
  -v              : verbose
Created 2011-03-16, updated 2011-03-16, Nanjiang
"""

def PrintHelp():
    print usage

numArgv=len(sys.argv)
if numArgv < 2:
    PrintHelp()
    sys.exit()

isQuiet=False
argList=[];    # supplied files
isPrintVerbose=False;

def mybinaryfind(sortedList, key, lo=0,hi=-1): #{{{
#this function just return True (find) or False (not find)
    i = bisect(sortedList,key,lo,hi);
    if i == 0:
        return False;
    elif sortedList[i-1] == key:
        return True;
    else:
        return False;
#}}}

def ReadInList(inFile): #{{{
#pdblist is a dict
#  format: pdblist['1d0l']={'filename':"name1",'pdbcode':"code1"}
    pdblist={};
    fpin = open(inFile, "r");
    lines = fpin.readlines();
    fpin.close();
    i=0;
    while i < len(lines):
        line = lines[i];
        if line:
            strs=line.split();
            filename=strs[0];
            basename=os.path.basename(filename);
            pdbcode = basename[3:7];
            pdblist[pdbcode]={};
            pdblist[pdbcode]['filename'] = filename;
            pdblist[pdbcode]['pdbcode'] = pdbcode;
            datestrs=strs[1].split('-');
            pdblist[pdbcode]['date'] = datetime.date(int(datestrs[0]),int(datestrs[1]),int(datestrs[2]));
        i+=1;
    return (pdblist);
#}}}
def CopyNewEntry(pdbcodelist_copy, sourcedir, targetdir):#{{{
    for pdbcode in pdbcodelist_copy:
        subdir=pdbcode[1:3];
        gzfilename="pdb"+pdbcode+".ent.gz";
        sfile=sourcedir + os.sep + subdir + os.sep +gzfilename;
        tdir=targetdir+os.sep+subdir;
        command="mkdir -p " +  tdir;
        os.system(command);
        command="cp -f " + sfile + " " + tdir + os.sep;
        os.system(command);
        command="gzip -dN -f " + tdir + os.sep + gzfilename;
        os.system(command);

#}}}
def DeleteEntry(pdbcodelist_delete, targetdir):#{{{
    for pdbcode in pdbcodelist_delete:
        subdir=pdbcode[1:3];
        filename=targetdir + os.sep + subdir + os.sep + "pdb" + pdbcode +".ent";
        os.remove(filename);
#}}}

def GetUpdateList(pdbList, pdb_dcpList):#{{{
    i=0;
    pdbcodelist_copy=[];
    pdbcodelist_delete=[];
    DT=datetime.timedelta(days=90); #date threshold is 90 days


    dcp_pdbcodelist = pdb_dcpList.keys();
    pdb_pdbcodelist = pdbList.keys();
    dcp_pdbcodelist.sort();
    pdb_pdbcodelist.sort();

    for pdbcode in pdb_dcpList.keys():  #remove item which is not in the remote source
        if not mybinaryfind(pdb_pdbcodelist, pdbcode):
            pdbcodelist_delete.append(pdbcode);

    for pdbcode in pdbList.keys(): # for item in the remote source, update if it is newer
        if mybinaryfind(dcp_pdbcodelist, pdbcode):
            date1=pdbList[pdbcode]['date'];
            date2=pdb_dcpList[pdbcode]['date'];
            if date1 > date2 and date1-date2 >= DT:
                pdbcodelist_copy.append(pdbcode);
        else: # if not exist in the local storage, copy
            pdbcodelist_copy.append(pdbcode);

    return (pdbcodelist_copy, pdbcodelist_delete);
#}}}

i = 1
isNonOptionArg=False
while i < numArgv:
    if isNonOptionArg == True:
        argList.append(sys.argv[i])
        isNonOptionArg=False;
        i = i + 1;
    elif sys.argv[i] == "--":
        isNonOptionArg=True
        i = i + 1;
    elif sys.argv[i][0] == "-":
        if sys.argv[i] ==  "-h" or  sys.argv[i] == "--help":
            PrintHelp()
            sys.exit()
        elif sys.argv[i] == "-q":
            isQuiet=True
            i = i + 1;
        elif sys.argv[i] == "-v":
            isPrintVerbose=True;
            i = i + 1;
        else:
            print "Error! Wrong argument:", sys.argv[i];
            sys.exit();
    else:
        argList.append(sys.argv[i]);
        i = i + 1;

if len(argList) != 4:
    print >> sys.stderr,"Argument error, four arguments should be supplied";
    sys.exit();

pdbListFile=argList[0];
pdb_dcpListFile=argList[1];
sourcedir=argList[2];
targetdir=argList[3];

try:
    (pdbList ) = ReadInList(pdbListFile);
    (pdb_dcpList ) = ReadInList(pdb_dcpListFile);
    (pdbcodelist_copy, pdbcodelist_delete) = GetUpdateList(pdbList, pdb_dcpList);
    if isPrintVerbose:#{{{
        print "To be copied ", len(pdbcodelist_copy);
        for pdbcode in pdbcodelist_copy:
            print pdbcode, pdbList[pdbcode]['filename'], pdbList[pdbcode]['date'];
        print
        print "To be deleted", len(pdbcodelist_delete);
        for pdbcode in pdbcodelist_delete:
            print pdbcode, pdb_dcpList[pdbcode]['filename'],  pdb_dcpList[pdbcode]['date'];
#}}}

    CopyNewEntry(pdbcodelist_copy, sourcedir, targetdir);
    DeleteEntry(pdbcodelist_delete, targetdir);
except:
    print >> sys.stderr,"except";
    raise;

