#include<cstdio>
#include<cstring>
#include<algorithm>
#include<iostream>
using namespace std;

const int MAXV = 600;
const int INF = 1000000000;

int N,M;
int G[MAXV][MAXV];
int d[MAXV];
int w[MAXV];
int num[MAXV];
int weight[MAXV];
bool vis[MAXV] = {false};

void Dijkstra(int s){
	fill(d,d+MAXV,INF);
	memset(num,0,sizeof(num));
	memset(w,0,sizeof(w));
	d[s] = 0;
	w[s] = weight[s];
	num[s] = 1;
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
			if(vis[v] == false && G[u][v] != INF){
				if(d[u] + G[u][v] < d[v]){
					d[v] = d[u] + G[u][v];
					w[v] = w[u] + weight[v];
					num[v] = num[u];
				}
				else if(d[u] + G[u][v] == d[v]){
					if(w[u]+weight[v] > w[v]){
						w[v] = w[u] + weight[v]; 
					}
					num[v] += num[u];
				}
			}
		}
	}
}

int main(void){
	fill(G[0],G[0]+MAXV*MAXV,INF);
	int start,end;
	scanf("%d%d%d%d",&N,&M,&start,&end);
	for(int i = 0; i < N; i++){
		scanf("%d",&weight[i]);
	}
	
	int c1,c2,L;
	for(int i = 0; i < M; i++){
		scanf("%d%d%d",&c1,&c2,&L);
		G[c1][c2] = L;
		G[c2][c1] = L;
	}
	
	Dijkstra(start);
	printf("%d %d\n",num[end],w[end]);
	return 0;
}
