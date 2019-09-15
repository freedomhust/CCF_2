#include<cstdio>
#include<queue>

using namespace std;
const int maxn = 100;

struct node{
	int x,y;
	int layer;
}S,T,Node;

int n,m;
char matrix[maxn][maxn];
bool inq[maxn][maxn] = {false};
int X[4] = {0,0,1,-1};
int Y[4] = {1,-1,0,0};

bool judge(int x, int y){
	if(x >= n || x < 0 || y >= m || y < 0) return false;
	if(matrix[x][y] == '*' || inq[x][y] == true) return false;
	return true;
}

void BFS(int x, int y){
	queue<node> Q;
	Node.x = x; Node.y = y; Node.layer = 0;
	Q.push(Node);
	inq[x][y] = true;
	while(!Q.empty()){
		node top = Q.front();
		Q.pop();
		for(int i = 0; i < 4; i++){
			int newX = top.x + X[i];
			int newY = top.y + Y[i];
			if(newX == T.x && newY == T.y){
				printf("%d\n",top.layer+1);
				return ;
			}
			if(judge(newX,newY)){
				Node.x = newX; Node.y = newY; Node.layer = top.layer+1;
				Q.push(Node);
				inq[newX][newY] = true; 
			}
		}
	}
}

int main(void){
	scanf("%d%d\n",&n,&m);
	for(int x = 0; x < n; x++){
		for(int y = 0; y < m; y++){
			scanf("%c",&matrix[x][y]);
		}
		getchar();
	}
//	for(int x = 0; x < n; x++){
//		for(int y = 0; y < m; y++){
//			printf("%c",matrix[x][y]);
//		}
//		printf("\n");
//	}
	scanf("%d%d%d%d",&S.x,&S.y,&T.x,&T.y);
//	printf("%d%d%d%d\n",S.x,S.y,T.x,T.y);
	S.layer = 0;
	BFS(S.x,S.y);
}
