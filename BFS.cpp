#include<cstdio>
#include<queue>
#include<string>
#include<iostream> 
#include<vector>

using namespace std;

int n,G[MAXV][MAXV]; 
bool inq[MAXV] = {false};

void BFS(int u){
	queue<int> q;
	q.push(u);
	inq[u] = true;
	while(!q.empty()){
		int u = q.front();
		q.pop();
		for(int v = 0; v < n; v++){
			if(inq[v] == false && G[u][v] != INF){
				q.push(v);
				inq[v] = true;
			}
		}
	}
}

int BFS(int u){
	queue<int> q;
	//将元素入队列 
	q.push(u);
	//将是否访问标记为已访问 
	inq[u] = true;
	//开始遍历图 
	while(!q.empty()){
		//将队首元素取出 
		int u = q.front();
		q.pop();
		//对队首元素遍历图上所有的点看是否被访问且是否能到达 
		for(int v = 0; v < n; v++){
			if(inq[v] == false && G[u][v] != INF){
				//满足条件则进队列，是否访问标记为已访问 
				q.push(v);
				inq[v] = true;
			}
		}
	}
}

void BFSTrave(){
	//遍历图上所有的点，若图上有点未被访问，则通过该点访问
	//它所在连通图的所有点 
	for(int u = 0; u < n; u++){
		if(inq[u] == false){
			BFS(u);
		}
	}
}

void BFSTrave(){
	for(int u = 0; u < n; u++){
		if(inq[u] == false){
			BFS(u);
		}
	}
}

struct Node{
	int v;
	int layer;
};

vector <Node> Adj[N];

void BFS(int s){
	queue<Node> q;
	Node start;
	start.v = s;
	start.layer = 0;
	q.push(start);
	inq[start.v] = true;
	while(!q.empty()){
		Node topNode = q.front();
		q.pop();
		int u = topNode.v;
		for(int i = 0; i < Adj[u].size(); i++){
			Node next = Adj[u][i];
			next.layer = topNode.layer+1;
			if(inq[next.v] == false){
				q.push(next);
				inq[next.v] = true;
			} 
		}
	}
}



