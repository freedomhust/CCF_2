#include<cstdio>
#include<queue>
#include<cstring>
#include<algorithm>
#include<iostream>
#include<sstream>
using namespace std;

const int MAXV = 10005;

//���������Ϣ 
struct Node{
	char S_or_R;
	int target;
};

int T,n;
//�����Ƿ������� 
int flag = 0;
//��ʾ��ǰ�������ڵȴ�������в��� 
int wait[MAXV];
queue<Node> Q[MAXV];

int exe(char action, int target, int source){
	//���Ŀ�����Ϊ�գ����ʾû����ԭ������ƥ�������
	//���Ŀ�����Ҳ�ڵȴ�����ʾ����������
	//��������¶��˳�ѭ�� 
	while(!Q[target].empty() && wait[target] != 1){
		Node mes;
		mes = Q[target].front();
		//�����������պ�ƥ�䣬����������У��ݹ鷵�ص���һ�� 
		if(mes.S_or_R != action && mes.target == source){
			Q[target].pop();
			return 1;
		}
		//����������ƥ�䣬��ô�ݹ������һ�����п��Ƿ��
		//Ŀ����е�����ƥ�� 
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
	//����˳�ѭ������ôһ���ǲ������ģ�����-1 
	return -1;
}

int exeTravel(){
	flag = 0;
	//�����ж������α��� 
	for(int j = 0; j < n; j++){
		while(!Q[j].empty()){
			Node mes;
			mes = Q[j].front();
			wait[j] = 1;
			//��������˵����Ŀ��������ҵ���ƥ�������
			//���ǽ���������У���ʼ������һ�������ƥ����� 
			if(exe(mes.S_or_R,mes.target,j) == 1){
				Q[j].pop();
				wait[j] = 0;
			}
			//������ص�ֵ��Ϊ1����ôһ���Ƿ��������������쳣�����flag��1ֱ�ӷ��� 
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
		//ÿ�����¿�ʼʱ��ʼ��wait����Ͷ��� 
		memset(wait,0,sizeof(wait))
		for(int j = 0; j < n; j++){
			while(!Q[j].empty()) Q[j].pop();
		}
		
		//����sstream�����Է����ַ����������(����� 
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
		
		//��ʼ�������� 
		exeTravel();
		printf("%d\n",flag);
	}

	

}
