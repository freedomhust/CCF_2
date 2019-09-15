#include<cstdio>
#include<queue>
#include<algorithm>
#include<cstring>

using namespace std;

const int maxn = 1005;

struct node{
	int x,y;
	int layer;
}Node;

int n,m,k,d;
queue<node> Q;
int maze[maxn][maxn];
int inq_num = 0;
long long sum = 0;
bool inq[maxn][maxn] = {false};

int X[4] = {0,0,1,-1};
int Y[4] = {1,-1,0,0};

bool test(int x, int y){
	if(x < 1 || x > n || y < 1 || y > n) return false;
	if(inq[x][y] == true) return false;
	return true;
}

void BFS(){
	while(!Q.empty()){
		node top = Q.front();
		Q.pop();
		if(inq_num == k) return;
		for(int i = 0; i < 4; i++){
			int newX = top.x + X[i];
			int newY = top.y + Y[i];
			if(test(newX,newY)){
				Node.x = newX; Node.y = newY;
				Node.layer = top.layer+1;
				if(maze[newX][newY] > 0){
					sum += maze[newX][newY]*Node.layer;
					inq_num++;
				}
				Q.push(Node);
				inq[newX][newY] = true;
			}
		}
	}
}

int main(void){
	memset(maze,0,sizeof(maze));
	scanf("%d%d%d%d",&n,&m,&k,&d);
	for(int i = 0; i < m; i++){
		scanf("%d%d",&Node.x,&Node.y);
		Node.layer = 0;
		Q.push(Node);
		inq[Node.x][Node.y] = true;
 	}
// 	for(int i = 0; i < m; i++){
// 		printf("%d %d\n",Node.x,Node.y);
//	}
 	int meal;
 	for(int i = 0; i < k; i++){
 		scanf("%d%d%d",&Node.x,&Node.y,&meal);
 		maze[Node.x][Node.y] += meal;
 		Node.layer = 0;
	}
	
//	for(int i = 0; i < k; i++){
// 		printf("%d %d %d\n",Node.x,Node.y,meal);
//	}
	
	for(int i = 0; i < d; i++){
		scanf("%d%d",&Node.x,&Node.y);
		inq[Node.x][Node.y] = true;
	}
//	for(int i = 0; i < k; i++){
// 		printf("%d %d\n",Node.x,Node.y);
//	}
	BFS();
	printf("%lld\n",sum);
}
