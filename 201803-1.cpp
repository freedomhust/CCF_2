#include<cstdio>

int main(void){
	int n;
	int score = 0;
	int sum = 0;
	while(1){
		scanf("%d",&n);
		if(n == 1){
			sum = 0;
			score += 1;
		}
		else if(n == 2){
			sum++;
			score += sum*2;
		}
		else if(n == 0){
			printf("%d\n",score);
			return 0;
		}
	}
}
