#include<cstdio>
const int MAXN = 1005;

int first_day[MAXN];
int second_day[MAXN];

int main(void){
	int n;
	scanf("%d",&n);
	for(int i = 0; i < n; i++){
		scanf("%d",&first_day[i]);
	}
	for(int i = 0; i < n; i++){
		if(i == 0) second_day[i] = (first_day[i+1]+first_day[i])/2;
		else if(i == n-1) second_day[i] = (first_day[i-1]+first_day[i])/2;
		else second_day[i] = (first_day[i-1]+first_day[i]+first_day[i+1])/3;
	}
	for(int i = 0; i < n; i++){
		printf("%d ",second_day[i]);
	}
	printf("\n");
}
