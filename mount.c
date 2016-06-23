// Simple grep.  Only supports ^ . * $ operators.

#include "types.h"
#include "stat.h"
#include "user.h"


int
main(int argc, char *argv[])
{
  int partitionNumber;
  char *filePath;
  
  if(argc < 3){
    printf(1, "usage: mount [directory] [partition number]\n");
    exit();
  }
  filePath=argv[1];
  partitionNumber=atoi(argv[2]);
 if(mount(filePath,partitionNumber)==0){
     printf(1,"partition %d was successfully mounted on %s \n",partitionNumber,filePath);
 }
 else{
     printf(1,"mount failed \n");
 }
  exit();
}

