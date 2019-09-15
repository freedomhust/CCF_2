#include<cstdio>
#include<queue>
using namespace std;

const int MAXN = 110;

struct node{
	int x,y;
}Node;

int matrix[MAXN][MAXN];
bool inq[MAXN][MAXV] = {false};
int X[4] = {0,0,1,-1};
int Y[4] = {1,-1,0,0};

bool judge(int x,int y){
	if(x >= n || x < 0 || y >= m || y < 0) return false;
	if(matrix[x][y] == 0 || inq[x][y] == true) return false;
	return true;
}

void BFS(int x,int y){
	queue<node> Q;
	Node.x = x;
	Node.y = y;
	Q.push(Node);
	inq[x][y] = true;
	while(!Q.empty()){
		node top = Q.front();
		Q.pop();
		for(int i = 0; i < 4; i++){
			int newX = top.x+X[i];
			int newY = top.y+Y[i];
			if(judge(newX,newY)){
				Node.x = newX;
				Node.y = newY;
				Q.push(Node);
				inq[newX][newY] = true;
			}
		}
	}
}

int main(void){
	int m,n;
	scanf("%d%d",&n,&m);
	for(int i = 0; i < n; i++){
		for(int j = 0; j < m; j++){
			scanf("%d",&matrix[i][j]);
		}
	}
	int sum = 0;
	for(int i = 0; i < n; i++){
		for(int j = 0; j < m; j++){
			if(inq[i][j] == false && matrix[i][j] == 1){
				BFS(i,j);
				sum++;
			}
		}
	}
	printf("%d\n",sum);
	return 0;
}
