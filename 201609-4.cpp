#include<cstdio>
#include<algorithm>
using namespace std;

const int MAXV = 10005;
const int INF = 1000000000;

int n,m,G[MAXV][MAXV];
int d[MAXV];
bool vis[MAXV] = {false};

int Dijkstra(int s){
	fill(d,d+MAXV,INF);
	d[1] = 0;
	int ans = 0;
	int small = 0;
	for(int i = 1; i <= n; i++){
		int u = -1, MIN = INF;
		for(int j = 1; j <= n; j++){
			if(vis[j] == false && d[j] < MIN){
				u = j;
				MIN = d[j];
			}
		}
		if(u == -1) return -1;
		vis[u] = true;
		for(int v = 1; v <= n; v++){
			if(vis[v] == false && G[u][v] != INF){
				if(d[u] + G[u][v] < d[v]){
					d[v] = G[u][v]+d[u];
					ans += G[u][v];
					small = G[u][v];
				}
				else if(d[u] + G[u][v] == d[v]){
					if(G[u][v] < small){
						ans = ans - small + G[u][v];
						small = G[u][v];
					}
				}

			}
		}
	}
	return ans;
}

int main(void){
	int u,v,w;
	scanf("%d%d",&n,&m);
	fill(G[0],G[0]+MAXV*MAXV,INF);
	for(int i = 0; i < m; i++){
		scanf("%d%d%d",&u,&v,&w);
		G[u][v] = G[v][u] = w;
	}
	int ans = Dijkstra(1);
	printf("%d\n",ans);
	return 0;
}
