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
	//��Ԫ������� 
	q.push(u);
	//���Ƿ���ʱ��Ϊ�ѷ��� 
	inq[u] = true;
	//��ʼ����ͼ 
	while(!q.empty()){
		//������Ԫ��ȡ�� 
		int u = q.front();
		q.pop();
		//�Զ���Ԫ�ر���ͼ�����еĵ㿴�Ƿ񱻷������Ƿ��ܵ��� 
		for(int v = 0; v < n; v++){
			if(inq[v] == false && G[u][v] != INF){
				//��������������У��Ƿ���ʱ��Ϊ�ѷ��� 
				q.push(v);
				inq[v] = true;
			}
		}
	}
}

void BFSTrave(){
	//����ͼ�����еĵ㣬��ͼ���е�δ�����ʣ���ͨ���õ����
	//��������ͨͼ�����е� 
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



