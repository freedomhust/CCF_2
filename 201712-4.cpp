#include<cstdio>
#include<iostream>
#include<string>
#include<vector>
#include<cstring>

using namespace std;

const int MAXV = 505;
const int INF = 1000000000;

struct Node{
	int v,dis;
	int big_or_small;
}node;

vector<Node> Adj[MAXV];
int n,m;
int small_dis[MAXV];
long long d[MAXV];
bool vis[MAXV] = {false};

void Dijkstra(int s){
	fill(d,d+MAXV,INF);
	d[s] = 0;
	for(int i = 1; i <= n; i++){
		int u = -1, MIN = INF;
		for(int j = 1; j <= n; j++){
			if(vis[j] == false && d[j] < MIN){
				u = j;
				MIN = d[j];
			}
		}
			if(u == -1) return;
	vis[u] = true;
	
	for(int j = 0; j < Adj[u].size(); j++){
		int v = Adj[u][j].v;
		if(vis[v] == false){
			//如果是小道 
			if(Adj[u][j].big_or_small == 1){
				if(d[u] - small_dis[u]*small_dis[u] + (small_dis[u]+Adj[u][j].dis)*(small_dis[u]+Adj[u][j].dis) < d[v]){
					d[v] = d[u] - small_dis[u]*small_dis[u] + (small_dis[u]+Adj[u][j].dis)*(small_dis[u]+Adj[u][j].dis);
					small_dis[v] = small_dis[u]+Adj[u][j].dis;
				}
			}
			//如果是大道 
			else {
				if(d[u] + Adj[u][j].dis < d[v]){
					d[v] = d[u] + Adj[u][j].dis;
					small_dis[v] = 0;
				}
			}
		}
	}
	}

}

int main(void){
	memset(small_dis,0,sizeof(small_dis));
	scanf("%d%d",&n,&m);
	int t,a,b,c;
	for(int i = 0; i < m; i++){
		scanf("%d%d%d%d",&t,&a,&b,&c);
		node.big_or_small = t;
		node.dis = c;
		node.v = b;
		Adj[a].push_back(node);
		node.v = a;
		Adj[b].push_back(node);
	}
	Dijkstra(1);
	printf("%lld",d[n]);
}
