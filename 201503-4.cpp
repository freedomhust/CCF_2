#include<cstdio>
#include<queue>
#include<algorithm>

using namespace std;

const int INF = 1000000000;
const int MAXV = 10001;

int n,m;
int node;

int dis[MAXV][MAXV];

void Floyd(){
	for(int k = 1; k <= n+m; k++){
		for(int i = 1; i <= n+m; i++){
			for(int j = 1; j <= n+m; j++){
				if(dis[i][k] != INF && dis[k][j] != INF && dis[i][k] + dis[k][j] < dis[i][j]){
					dis[i][j] = dis[i][k] + dis[k][j];
				}
			}
		}
	}
}

int main(void){
	fill(dis[0],dis[0]+MAXV*MAXV,INF);
	scanf("%d%d",&n,&m);
	for(int i = 2; i <= n; i++){
		scanf("%d",&node);
		dis[i][node] = 1;
		dis[node][i] = 1; 
	}
	for(int i = n+1; i <= n+m; i++){
		scanf("%d",&node);
		dis[i][node] = dis[node][i] = 1;
	}
	Floyd();
	int max = 0;
	for(int i = 1; i <= n+m; i++){
		for(int j = 1; j <= n+m; j++){
			if(dis[i][j] > max){
				max = dis[i][j];
			}
		}
	}
	printf("%d\n",max);
}
