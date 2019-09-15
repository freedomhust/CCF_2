#include<cstdio>
#include<cstring>

int reader[1002];

int main(void){
	memset(reader,0,sizeof(reader));
	int n,m;
	scanf("%d",&n);
	for(int i = 0; i < n; i++){
		scanf("%d",&m);
		reader[m]++;
		printf("%d ",reader[m]);
	}
	printf("\n");
}
