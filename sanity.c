// sanity

#include "types.h"
#include "stat.h"
#include "user.h"





void dummy_loop(){
        for(int j=0;j<1000000;j++){
            
        }
}

void sanity(int n){
    int rtime;
    int retime;
    int stime;
    for (int i=0;i<3*n;i++){
        if(!fork()){
            int o=i % 3;
            switch(o){
                case 0 :
                    for(int i=0;i<100;i++){
                        dummy_loop();
                    }
                    break;
                case 1 :
                     for(int i=0;i<100;i++){
                        dummy_loop();
                        yield();
                    }
                    break;
                case 2 :
                      for(int i=0;i<100;i++){
                        dummy_loop();
                        sleep(1);
                    }
                    break;
            }
            break;
        }
        else{
            wait2(&retime,&rtime,&stime);
            cprintf("type %d,wait time: %d, run time: %d, sleep time: %d",(i % 3),retime,rtime,stime);
        }
    }
}

int
main(int argc, char *argv[])
{
  int n;
  
  if(argc <= 0){
    printf(2, "usage: sanity <number of proccess>\n");
    exit();
  }
  n=atoi(argv[1]);
  
 sanity(n);

  exit();
}

