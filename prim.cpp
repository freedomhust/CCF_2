const int MAXV = 1000;
const int INF = 1000000000;

int n,G[MAXV][MAXV];
int d[MAXV];
bool vis[MAXV] = {false};

int prim(){
	fill(d,d+MAXV,INF);
	d[0] = 0;
	int ans = 0;
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
		ans += d[j];
		for(int v = 0; v < n; v++){
			if(vis[v] == false && G[u][v] != INF && G[u][v] < d[j]){
				d[v] = G[u][v];
			}
		}
	}
	return ans;
}
