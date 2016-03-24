// sanity

#include "types.h"
#include "stat.h"
#include "user.h"



#define LOOP_SIZE 10
//static char* buff [LOOP_SIZE];


void SMLsanity()
{
    printf(1,"sanity started\n");
    int i;
    
    //int proc[LOOP_SIZE];
    for (i = 0; i < LOOP_SIZE;i++) {
        int priority =1+ (i % 3);
       if(!fork()){
           if(set_prio(priority)==0){
            while (uptime()<500)
            {
              sleep(1);
            }

             printf (2,"proc %d finished\n", i);
             exit(); 
              
           }
          else{
              printf(1,"unable to set priority \n");
          }
       }
       else{
           //printf(1,"forked process %d \n",i);
       }
    }

    for (i=0; i < LOOP_SIZE ; i++)
    {
      wait();
    }
}


int main(int argc, char* argv[])
{
    SMLsanity();
    exit();
}
