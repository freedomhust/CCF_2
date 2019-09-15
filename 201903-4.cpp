#include<cstdio>
#include<cstdlib>
#include<cstring>
#include<iostream>
#include<string>
#include<sstream>
#include<queue>
using namespace std;
const int MAXN=10005;

struct Mes{ //消息结构体
	char flag; //R：收，S：发
	int target; //目标进程
};

struct Pro{ //进程结构体
	queue<Mes> task; //消息队列
};

Pro pro[MAXN]; //进程数组，pro[i]代表进程i
int wait[MAXN]; //进程等待标志，1为等待，0为就绪

int exe(int no); //执行进程no
int receiveM(int from, int to); //进程from从进程to那里接收消息
int sendM(int from, int to); //进程from向进程to那里发送消息

int exe(int no){
	if(wait[no]==1) return -1; //如果进程处于等待状态，那么发生死锁
	if(pro[no].task.empty()) return 0; //如果进程的消息队列为空，那么表示该进程成功结束
	Mes cur=pro[no].task.front(); //取第一个消息
	if(cur.flag=='R'){
		wait[no]=1;
		if(receiveM(no, cur.target)==-1) return -1;
		
		//如果该消息成功执行 
		pro[no].task.pop();
		wait[no]=0;
		if(exe(no)==-1) return -1; //递归处理该进程的下一个消息
		return 0;
	}
	else if(cur.flag=='S'){
		wait[no]=1;
		if(sendM(no, cur.target)==-1) return -1;
		
		//如果该消息成功执行 
		pro[no].task.pop();
		wait[no]=0;
		if(exe(no)==-1) return -1; //递归处理该进程的下一个消息
		return 0;
	}
}

int receiveM(int from, int to){ 
	if(wait[to]==1) return -1; //判断目标进程的状态
	if(pro[to].task.empty()) return -1; //判断目标进程的消息队列是否为空
	Mes cur=pro[to].task.front(); //获取目标进程的消息队列中的第一个消息，判断能否处理来自from的消息 
	if(cur.flag=='R'){ //不能处理 
		wait[to]=1;
		if(receiveM(to, cur.target)==-1)  return -1;//递归处理目标进程的下个消息
		 
		wait[to]=0;
		pro[to].task.pop();
		if(receiveM(from, to)==0) return 0; //递归判断之前的消息能否得到处理 
		return -1;
	}
	else if(cur.flag=='S'){ //因为是'S'，或许可以处理当前消息 
		if(cur.target==from){ //确实可以处理当前消息 
			pro[to].task.pop();
			return 0;
		}
		
		//不能处理当前消息 
		wait[to]=1;
		if(sendM(to, cur.target)==-1) return -1; //递归处理目标进程的下个消息 
		
		wait[to]=0;
		pro[to].task.pop();
		if(receiveM(from, to)==0) return 0; //递归判断之前的消息能否得到处理
		return -1; 
	}
	return -1;
}

int sendM(int from, int to){ 
	if(wait[to]==1) return -1;
	if(pro[to].task.empty()) return -1;
	Mes cur=pro[to].task.front();
	if(cur.flag=='R'){
		if(cur.target==from){
			pro[to].task.pop();
			return 0;
		}
		
		wait[to]=1;
		if(receiveM(to, cur.target)==-1) return -1;
			
		wait[to]=0;
		pro[to].task.pop();
		if(sendM(from, to)==0) return 0;
		return -1;
	}
	else if(cur.flag=='S'){
		wait[to]=1;
		if(sendM(to, cur.target)==-1) return -1;
		
		wait[to]=0;
		pro[to].task.pop();
		if(sendM(from, to)==0) return 0;
		return -1;
	}
	return -1;
}

int T,n;

int main(){
	scanf("%d%d",&T,&n);
	getchar();
	for(int i=0;i<T;i++){
		
		memset(wait,0,sizeof(wait));
		
		for(int j=0;j<n;j++){ //初始化每个进程的消息队列
			while(!pro[j].task.empty()) pro[j].task.pop();
		}
		
		for(int j=0;j<n;j++){ //存储进程的消息队列
			string line;
			getline(cin,line);
			istringstream ss(line);
			string tmp;
			while(ss>>tmp){
				Mes mes;
				mes.flag=tmp[0];
				mes.target=atoi(tmp.c_str()+1);
				pro[j].task.push(mes);
			}
		}
		
		int flag=0;
		for(int j=0;j<n;j++){
			if(!pro[j].task.empty()){ //如果某个进程的消息队列非空，就执行该进程
				if(exe(j)==-1){
					flag=1;
					break;
				}
			}
		}
		
		printf("%d\n",flag);
		
	}
	return 0;
}
