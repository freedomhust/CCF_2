#include<cstdio>
#include<algorithm>

using namespace std;

const int MAXV = 1005;
const int INF = 1000000000;

int n,m,G[MAXV][MAXV];
int d[MAXV];
bool vis[MAXV] = {false};

long long prim(){
	fill(d,d+MAXV,INF);
	d[1] = 0;
	long long sum = 0;
	for(int i = 0; i < n; i++){
		int u = -1, MIN = INF;
		for(int j = 1; j <= n; j++){
//			printf("%d ",d[j]);
			if(vis[j] == false && d[j] < MIN){
				u = j;
				MIN = d[j];
			}
		}
//		printf("u = %d\n",u);
		if(u == -1) return -1;
		vis[u] = true;
		sum += d[u];
		for(int v = 1; v <= n; v++){
			if(vis[v] == false && G[u][v] != INF && G[u][v] < d[v]){
				d[v] = G[u][v];
			}
		}
	}
	return sum;
	
}

int main(void){
	int u,v,w;
	scanf("%d%d",&n,&m);
	fill(G[0],G[0]+MAXV*MAXV,INF);
	for(int i = 0; i < m; i++){
		scanf("%d%d%d",&u,&v,&w);
		G[u][v] = G[v][u] = w;
	}
	long long sum = prim();
	printf("%lld\n",sum);
	return 0;
}
