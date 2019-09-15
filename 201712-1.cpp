#include<cstdio>
#include<algorithm>
using namespace std;

int  num[1005];

bool cmp(int a, int b){
	return a > b;
}

int main(void){
	int n;
	scanf("%d",&n);
	for(int i = 0; i < n; i++){
		scanf("%d",&num[i]);
	}
	sort(num,num+n,cmp);
	int min  = num[0]-num[1];
	for(int i = 1; i < n-1; i++){
		if(num[i]-num[i+1] < min) min = num[i]-num[i+1];
		if(min == 0) break;
	}
	printf("%d\n",min);
}
