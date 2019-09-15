#include<cstdio>
#include<cstring>
#include<cmath>
#include<algorithm>

#define num 1001

int main(void){
	int N,M;
	int array[num];
	memset(array,0,sizeof(array));
	scanf("%d",&N);
	for(int i = 0; i < N; i++){
		scanf("%d",&M);
		M = fabs(M);
		array[M]++;
	}
	int sum = 0;
	for(int i = 1; i < num; i++){
		if(array[i] == 2) sum++;
	}
	printf("%d\n",sum);
}
