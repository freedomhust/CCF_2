#include<cstdio>

int main(void){
	int r,y,g;
	int n,k,t;
	long long sum = 0;
	scanf("%d%d%d",&r,&y,&g);
	scanf("%d",&n);
	for(int i = 0; i < n; i++){
		scanf("%d%d",&k,&t);
		//·�� 
		if(k == 0) sum += t;
		//��� 
		else if(k == 1){
			sum += t;
		}
		//�Ƶ� 
		else if(k == 2){
			sum += t+r;
		}
		//�̵� 
		else if(k == 3){
			sum += 0; 
		}
	}
	printf("%d\n",sum);
}
