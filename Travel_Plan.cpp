#include<stdio.h>
#include<cstring>
#include<algorithm>
using namespace std;

const int MAXV = 510;
const int INF = 1000000000;

int n,m,st,ed,G[MAXV][MAXV],cost[MAXV][MAXV];
int d[MAXV],c[MAXV],pre[MAXV];
bool vis[MAXV] = {false};

void Dijkstra(int s){
    fill(d,d+MAXV,INF);
    fill(c,c+MAXV,INF);
    for(int i = 0; i < n; i++){
        pre[i] = i;
    }
    d[s] = 0;
    c[s] = 0;

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

        for(int v= 0; v <n; v++){
            if(vis[v] == false && G[u][v] != INF){
                if(d[u] + G[u][v] < d[v]){
                    d[v] = d[u]+G[u][v];
                    c[v] = c[u]+cost[u][v];
                    pre[v] = u;
                }
                else if(d[u] + G[u][v] == d[v]){
                    if(c[u] + cost[u][v] < c[v]){
                        c[v] = c[u] + cost[u][v];
                        pre[v] = u;
                    }
                }
            }
        }

    }
}

void DFS(int v){
    if(v == st){
        printf("%d ",v);
        return;
    }
    DFS(pre[v]);
    printf("%d",v);
}

int main(void){
    scanf("%d%d%d%d",&n,&m,&st,&ed);
    int u,v;
    fill(G[0],G[0]+MAXV*MAXV,INF);
    for(int i = 0; i < m; i++){
        scanf("%d%d",&u,&v);
        scanf("%d%d",&G[u][v],&cost[u][v]);
        G[v][u] = G[u][v];
        cost[v][u] = cost[u][v];
    }
    Dijkstra(st);
    DFS(ed);
    printf("%d %d\n",d[ed],c[ed]);
    return 0;
}

//************************Dijkstra+DFS****************
#include<cstdio>
#include<cstring>
#include<vector>
#include<algorithm>
using namespace std;

const int MAXV = 510;
const int INF = 1000000000;

int n,m,st,ed,G[MAXV][MAXV], cost[MAXV][MAXV];
int d[MAXV],minCost[MAXV];
bool vis[MAXV] = {false};
vector<int> pre[MAXV];
vector<int> tempPath, path;

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
			if(vis[v] == false && G[u][v] != INF){
				if(d[u] + G[u][v] < d[v]){
					d[v] = d[u]+G[u][v];
					pre[v].clear();
					pre[v].push_back(u);
				}else if(d[u]+G[u][v] == d[v]){
					pre[v].push_back(u);
				}
			}
		}
	}
}

void DFS(int v){
	if(v == st){
		tempPath.push_back(v);
		int tempCost = 0;
		for(int i = tempPath.size()-1; i>0; i--){
			int id = tempPath[i], idNext = tempPath[i-1];
			tempCost += cost[id][idNext];
		}
		if(tempCost < minCost){
			minCost = tempCost;
			path = tempPath;
		}
		tempPath.pop_back();
		return;
	}
	tempPath.push_back(v);
	for(int i = 0; i < pre[v].size(); i++){
		DFS(pre[v][i]);
	}
	tempPath.pop_back();
}
