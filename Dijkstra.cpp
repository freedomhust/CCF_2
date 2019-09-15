#include<cstdio>
#include<vector>
#include<string>

using namespace std;

const int MAXV = 1000;
const int INF = 1000000000;

int n, G[MAXV][MAXV];
int d[MAXV];
bool vis[MAXV] = {false};

void Dijkstra(int s){
	fill(d,d+MAXV,INF);
	d[s] = 0;
	for(int i = 0; i < n; i++){
		int u = -1, MIN = INF;
		for(int j = 0; j < n; j++){
			if(vis[j] == false && d[j] < MIN){
				u = j;
				MIN = d[j];
			}
		}
		if(u == -1) return;
		vis[u] = true;
		for(int v = 0; v < n; v++){
			if(vis[v] == false && G[u][v] != INF && d[u]+G[u][v] < d[v]){
				d[v] = d[u]+G[u][v];
			}
		}
	}
}

//***************************
struct Node{
	int v,dis;
};
vector<Node> Adj[MAXV];
int n;
int d[MAXV];
bool vis[MAXV] = {false};

void Dijkstra(int s){
	fill(d,d+MAXV,INF);
	d[s] = 0;
	for(int i = 0; i < n; i++){
		int u = -1, MIN = INF;
		//�ҵ�δ���ʶ�����dis��С�� 
		//���ں������Ż� 
		for(int j = 0; j < n; j++){
			if(vis[j] == false && d[j] < MIN){
				u = j;
				MIN = d[j];
			}
		}
		
		if(u == -1) return;
		
		vis[u] = true;
		for(int j = 0; j < Adj[u].size(); j++){
			int v = Adj[u][j].v;
			if(vis[v] == false && d[u] + Adj[u][j].dis < d[v]){
				d[v] = d[u] + Adj[u][j].dis;
			}
		}
	}
}
