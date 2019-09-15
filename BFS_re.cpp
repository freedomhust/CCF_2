#include<queue> 

void BFS(int s){
	queue<int> q;
	q.push(s);
	while(!q.empty()){
		//取出队首元素
		//访问队首元素top
		//将队首元素出队列
		//将top的下一层节点中未曾入队的节点全部入队，并设置为已入队 
	}
} 

#include<cstdio>
#include<queue>
using namespace std;
const int maxn = 100;
struct node{
	int x,y;
}Node;

int n,m;
int matrix[maxn][maxn];
bool inq[maxn][maxn] = {false};
int X[4] = {0,0,1,-1};
int Y[4] = {1,-1,0,0};

bool judge(int x, int y){
	if(x >= n || x < 0 || y >= m || y < 0) return false;
	if(matrix[x][y] == 0 || inq[x][y] == true) return false;
	return true;
}

void BFS(int x,int y){
	queue<node> Q;
	Node.x = x; Node.y = y;
	Q.push(Node);
	inq[x][y] = true;
	while(!Q.empty()){
		node top = Q.front();
		Q.pop();
		for(int i = 0; i < 4; i++){
			int newX = top.x + X[i];
			int newY = top.y + Y[i];
			if(judge(newX,newY)){
				Node.x = newX; Node.y = newY;
				Q.push(Node);
				inq[newX][newY] = true;
			}
		}
	}
}

int main(void){
	scanf("%d%d",&n,&m);
	for(int x = 0; x < n; x++){
		for(int y = 0; y < m; y++){
			scanf("%d",&matrix[x][y]);
		}
	}
	int ans = 0;
	for(int x = 0; x < n; x++){
		for(int y = 0; y < m; y++){
			if(matrix[x][y] == 1 && inq[x][y] = false){
				ans++;
				BFS(x,y);
			}
		}
	}
	printf("%d\n",ans);
}
