#include<cstdio>
#include<cstring>
#include<string>
#include<algorithm>
#include<iostream>
#include<sstream>
using namespace std;

struct Node{
	string element;
	int has_id;
	string id;
	int layer;
}Element[105];

int N,M;
int son_num = 0;
string tmp[100];
int num = 0;
int line_number[20];
string line;

//void exe(int j, int num){
//	while(num != son_num){
//		for(int k = j+1; k <= N; k++){
//			
//		}
//	}
//}

int main(void){
	scanf("%d%d",&N,&M);
	getchar();
	for(int i = 1; i <= N; i++){
		getline(cin,line);
		//如果有id属性 
		string::size_type pos = line.find("#");
		if(pos != string::npos){
			Element[i].has_id = 1;
			Element[i].id = line.substr(pos,line.size()-pos);
			line.erase(pos-1,line.size()-pos+1);
			//看有多少个. 
			int s = 0;
			while(line.find(".",s) != string::npos) s++;
			Element[i].layer = s/2;
			Element[i].element = line.substr(s,line.size()-s);
			transform(Element[i].element.begin(), Element[i].element.end(), Element[i].element.begin(), ::tolower);
		}
		else {
			Element[i].has_id = 0;
			int s = 0;
			while(line.find(".",s) != string::npos) s++;
			Element[i].layer = s/2;
			Element[i].element = line.substr(s,line.size()-s);
			transform(Element[i].element.begin(), Element[i].element.end(), Element[i].element.begin(), ::tolower);
		}
	}
//	for(int i = 1; i <= N; i++){
//		cout << Element[i].element << " ";
//		if(Element[i].has_id) cout << Element[i].id << " ";
//		cout << Element[i].layer << endl;
//	} 
	//开始处理数据
	for(int i = 0; i < M; i++){
		getline(cin,line);
		//后代选择器 
		if(line.find(" ") != string::npos){
			num = 0;
			son_num = 0;
			transform(line.begin(), line.end(), line.begin(), ::tolower);
			stringstream ss;
			ss.clear();
			ss.str(line);
			while(ss >> tmp[son_num]){
				son_num++;
			}
			
			for(int j = 1; j <= N; j++){
				if(Element[j].element == tmp[0]){
					for(int k = j+1; k <= N; k++){
						if(Element[k].layer < Element[j].layer) break;
						if(Element[k].element == tmp[1] && Element[k].layer > Element[j].layer){
							line_number[num] = k;
							num++;
							break;
						}
					}
				}
			}
		}
		//不是后代选择器 
		else{
			num = 0;
			if(line[0] == '#'){
				for(int j = 1; j <= N; j++){
					if(Element[j].has_id && Element[j].id == line){
						line_number[num] = j;
						num++;
					}
				}
			}
			else{
				transform(line.begin(), line.end(), line.begin(), ::tolower);
				for(int j = 1; j <= N; j++){
					if(Element[j].element == line){
						line_number[num] = j;
						num++;
					}
				}
			}
		}
		printf("%d ",num);
		for(int i = 0; i < num; i++){
			printf("%d ",line_number[i]);
		}
		printf("\n");
	}

	
}
