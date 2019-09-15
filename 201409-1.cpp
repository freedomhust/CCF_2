#include<cstdio>
#include<cstring>

int array[10002];

int main(void){
	memset(array,0,sizeof(array));
	int N;
	int m;
	scanf("%d",&N);
	for(int i = 0; i < N; i++){
		scanf("%d",&m);
		array[m] = 1;
	}
	
	int num = 0;
	for(int i = 0; i <= 10000; i++){
		if(array[i] == 1){
			if(i+1 <= 10000 && array[i+1] == 1){
				num++;
			}
		}
	}
	printf("%d\n",num);
	
}
