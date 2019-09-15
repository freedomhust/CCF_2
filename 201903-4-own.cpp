#include<cstdio>
#include<queue>
#include<cstring>
#include<algorithm>
#include<iostream>
#include<sstream>
using namespace std;

const int MAXV = 10005;

//存放命令信息 
struct Node{
	char S_or_R;
	int target;
};

int T,n;
//代表是否生死锁 
int flag = 0;
//表示当前队列正在等待另外队列操作 
int wait[MAXV];
queue<Node> Q[MAXV];

int exe(char action, int target, int source){
	//如果目标队列为空，则表示没有与原队列相匹配的命令
	//如果目标队列也在等待，表示发生了死锁
	//两种情况下都退出循环 
	while(!Q[target].empty() && wait[target] != 1){
		Node mes;
		mes = Q[target].front();
		//如果两个命令刚好匹配，将命令出队列，递归返回到上一层 
		if(mes.S_or_R != action && mes.target == source){
			Q[target].pop();
			return 1;
		}
		//如果两个命令不匹配，那么递归查找下一个队列看是否和
		//目标队列的命令匹配 
		else if(mes.S_or_R != action && mes.target != source){
			wait[target] = 1;
			if(exe(mes.S_or_R,mes.target,target) == 1){
				Q[target].pop();
				wait[target] = 0;
			}
		}
		else if(mes.S_or_R == action){
			wait[target] = 1;
			if(exe(mes.S_or_R,mes.target,target) == 1){
				Q[target].pop();
				wait[target] = 0;
			}
		}
	}
	//如果退出循环了那么一定是不正常的，返回-1 
	return -1;
}

int exeTravel(){
	flag = 0;
	//对所有队列依次遍历 
	for(int j = 0; j < n; j++){
		while(!Q[j].empty()){
			Node mes;
			mes = Q[j].front();
			wait[j] = 1;
			//正常返回说明在目标队列中找到了匹配的命令
			//于是将命令出队列，开始查找下一个命令的匹配情况 
			if(exe(mes.S_or_R,mes.target,j) == 1){
				Q[j].pop();
				wait[j] = 0;
			}
			//如果返回的值不为1，那么一定是发生了死锁或者异常情况，flag置1直接返回 
			else {
				flag = 1;
				return -1;
			}
		}
	}
	return 0;
}

int main(void){
	scanf("%d%d",&T,&n);
	getchar();
	for(int i = 0; i < T; i++){
		//每次重新开始时初始化wait数组和队列 
		memset(wait,0,sizeof(wait))
		for(int j = 0; j < n; j++){
			while(!Q[j].empty()) Q[j].pop();
		}
		
		//利用sstream的特性分离字符串并入队列(真好用 
		for(int j = 0; j < n; j++){
			string line;
			getline(cin,line);	
			stringstream ss;
			ss.clear();
			ss.str(line);
			string tmp;
			while(ss>>tmp){
				Node mes;
				mes.S_or_R = tmp[0];
				tmp.erase(tmp.begin());
				mes.target = atoi(tmp.c_str());
				Q[j].push(mes);
			}
		}
		
		//开始遍历队列 
		exeTravel();
		printf("%d\n",flag);
	}

	

}
