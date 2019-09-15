#include<cstdio>
#include<algorithm>
using namespace std;

int main(void){
	int N,M;
	scanf("%d",&N);
	int max,min,mid;
	int mid_1,mid_2;
	//Å¼Êý 
	if(N%2 == 0){
		for(int i = 1; i <= N; i++){
			if(i == 1) scanf("%d",&min);
			else if(i == N) scanf("%d",&max);
			else if(i == N/2) scanf("%d",&mid_1);
			else if(i == N/2 + 1) scanf("%d",&mid_2);
			else scanf("%d",&M);
		}
		if(min > max) swap(min,max);
		printf("%d ",max);
		if((mid_1+mid_2)%2 == 0) printf("%d ",(mid_1+mid_2)/2);
		else printf("%d.5 ",(mid_1+mid_2)/2);
		printf("%d\n",min);
	} 
	//ÆæÊý 
	else{
//		printf("%d\n",N);
		for(int i = 1; i <= N; i++){
			if(i == 1){
				scanf("%d",&min);
			}
			else if(i == N){
				scanf("%d",&max);
//				printf("N = %d max = %d\n",N,max);
			}
			else if(i == N/2 + 1){
				scanf("%d",&mid);
			}
			else scanf("%d",&M);
		}
		if(min > max) swap(min,max);
		printf("%d ",max);
		printf("%d ",mid);
		printf("%d\n",min);
	} 
}
