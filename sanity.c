// sanity

#include "types.h"
#include "stat.h"
#include "user.h"

void dummy_loop()
{
    for (int j = 0; j < 1000000; j++) {
    }
}

void sanity(int n)
{
    int rtime[3*n];
    int retime[3*n];
    int stime[3*n];
    int stats[3][3];
    int child=-1;
    printf(1,"sanity stated \n");
    for (int i = 0; i < 3 * n; i++) {
        int o = i % 3;
        if (!(child=fork())) {  
            
            switch (o) {
            case 0:
                for (int i = 0; i < 100; i++) {
                    dummy_loop();
                }
                break;
            case 1:
                for (int i = 0; i < 100; i++) {
                    dummy_loop();
                    yield();
                }
                break;
            case 2:
                for (int i = 0; i < 100; i++) {
                    dummy_loop();
                    sleep(1);
                }
                break;
            }
            break;
        }
            else {
                
            if(wait2(&retime[i], &rtime[i], &stime[i])>=0){
            stats[o][0]+=retime[i];
            stats[o][1]+=rtime[i];
            stats[o][2]+=stime[i];
            printf(1,"type %d,wait time: %d, run time: %d, sleep time: %d \n", (i % 3), retime[i], rtime[i], stime[i]);
           
            }
             

        }
    }
    if(child>0){
        for(int i =0 ; i< 3;i++){
        printf(1,"type %d, avg ready time: %d , avg run time: %d ,avg turnaround time: %d \n", (i % 3), stats[i][0] / n,stats[i][1] /n ,  (stats[i][0]+stats[i][1]+stats[i][2]) /n);
    }
    }
    
     
}

int main(int argc, char* argv[])
{
    int n;

    if (argc <= 1) {
        printf(2, "usage: sanity <number of proccess>\n");
        exit();
    }
    n = atoi(argv[1]);

    sanity(n);

    exit();
}
