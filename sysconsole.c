//
//file containing console related system calls
//

#include "types.h"
#include "defs.h"
#include "param.h"
#include "stat.h"
#include "mmu.h"
#include "proc.h"
#include "fs.h"
#include "fcntl.h"


#define MAX_HISTORY 16
#define MAX_LINE 128
static char[MAX_HISOTRY][MAX_LINE] history;

int sys_history(void)
{

   char * buffer;
  int history_id;

  if(argstr(0, &buffer) < 0 || argint(1, &history_id) < 0 )
    return -1;
  return get_history(buffer,history_id);
 
}


int get_history(char *buffer,int history_id){
  if(history_id<0 || history_id>MAX_HISTORY-1){
    return -2;
  }
  else{
    if(history[history_id]==0){
      return -1;
    }
      return history[history_id];
  }

}
