#include<cstdio>

int main(void){
	int r,y,g;
	int n,k,t;
	long long sum = 0;
	scanf("%d%d%d",&r,&y,&g);
	scanf("%d",&n);
	for(int i = 0; i < n; i++){
		scanf("%d%d",&k,&t);
		//Â·¶Î 
		if(k == 0) sum += t;
		//ºìµÆ 
		else if(k == 1){
			sum += t;
		}
		//»ÆµÆ 
		else if(k == 2){
			sum += t+r;
		}
		//ÂÌµÆ 
		else if(k == 3){
			sum += 0; 
		}
	}
	printf("%d\n",sum);
}
