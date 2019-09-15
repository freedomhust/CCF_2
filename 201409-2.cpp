#include<cstdio>
#include<cstring>

int G[102][102];

int main(void){
	int N;
	scanf("%d",&N);
	int x1,y1,x2,y2;
	for(int i = 0; i < N; i++){
		scanf("%d%d%d%d",&x1,&y1,&x2,&y2);
		for(int j = x1+1; j <= x2; j++){
			for(int k = y1+1; k <= y2; k++){
				G[j][k] = 1;
			}
		}
	}
	int num = 0;
	for(int i = 1; i <= 100; i++){
		for(int j = 1; j <= 100; j++){
			if(G[i][j] == 1) num++;
		}
	}
	printf("%d\n",num);
	return 0;
}
