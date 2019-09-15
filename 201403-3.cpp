#include<string>
#include<iostream>
#include<algorithm>
#include<cmath>
#include<cstdio>

using namespace std;

struct Para{
	char zimu;
	int with_para;
	int exist;
	string para;
}paras[100];

bool cmp(Para a, Para b){
	return a.zimu < b.zimu;
}

int main(void){
	string parameter;
	int N; 
	cin >> parameter;
	//将可选参数取出
	int para_number = 0;
	for(int i = 0; i < parameter.length(); i++){
		paras[para_number].zimu = parameter[i];
		if(i+1 < parameter.length() && parameter[i+1] == ':'){
			paras[para_number].with_para = 1;
			i++;
		}
		para_number++;
	}
	//将参数以字典序进行排序 
	sort(paras,paras+para_number,cmp);
//	for(int i = 0; i < para_number; i++){
//		printf("%c %d\n",paras[i].zimu,paras[i].with_para);
//	}
	scanf("%d\n",&N);
	//开始处理输入的行 
	string w;
	string k[256];
	
	for(int i = 1; i <= N; i++){
		getline(cin,w);
		//将输入的行以空格进行分割
		w = " " + w + " ";
		int s = 0;
		string::size_type pos = w.find(" ");
		string::size_type pos2 = w.find(" ",pos+1);
		while(pos2 != string::npos){
			//如果两个 / 不相邻 
			if(pos+1 != pos2){
				k[s] = w.substr(pos+1,pos2-pos-1);
				s++;
			}
			pos = pos2;
			pos2 = w.find(" ",pos+1);
		}
//		for(int j = 1; j < s; j++) cout << k[j] << endl;
		//分割好之后遍历所有的子字符串进行比较操作
		for(int j = 1; j < s; j++){
			int para_exist = 0;
			if(k[j][0] != '-' || k[j].size() > 2) break;
			//遍历看有没有这个参数
			for(int num = 0; num < para_number; num++){
				if(paras[num].zimu == k[j][1]){
					para_exist = 1;
					if(paras[num].with_para == 1){
						if(j+1 != s){
							paras[num].exist = 1;
							paras[num].para = k[j+1];
							j++;
						}
					}
					else paras[num].exist = 1;
				}
			}
			if(para_exist == 0) break;
		}
		printf("Case %d: ",i);
		//比较完之后，输出所有满足条件的参数以及他们的参数
		for(int j = 0; j < para_number; j++){
			if(paras[j].exist == 1){
				printf("-%c ",paras[j].zimu);
				if(paras[j].with_para == 1){
					cout << paras[j].para << " "; 
				}
			}
			paras[j].exist = 0;
		}
		printf("\n");
	}
	
}
