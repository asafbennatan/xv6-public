// sanity

#include "types.h"
#include "stat.h"
#include "user.h"



void SMLsanity()
{
    printf(1,"sanity stated\n");
    for (int i = 0; i < 20;i++) {
        int priority =1+ (i % 3);
       if(!fork()){
           if(set_prio(priority)==0){
               sleep(200);
              printf(1,"process %d with priority %d has finished \n",i,priority); 
              break;
           }
          else{
              printf(1,"unable to set priority \n");
          }
       }
       else{
           printf(1,"forked process %d \n",i);
       }
            
    
     
    }
}

int main(int argc, char* argv[])
{

    SMLsanity();

    exit();
}
