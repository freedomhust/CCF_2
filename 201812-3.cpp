#include<cstdio>
#include<string>
#include<cstring>
#include<iostream>
#include<algorithm>
using namespace std;

struct IP_addr{
	int a[5];
	int len;
}IP[105];

bool cmp(IP_addr a, IP_addr b){
	if(a.a[1] != b.a[1]) return a.a[1] < b.a[1];
	else if(a.a[2] != b.a[2]) return a.a[2] < b.a[2];
	else if(a.a[3] != b.a[3]) return a.a[3] < b.a[3];
	else if(a.a[4] != b.a[4]) return a.a[4] < b.a[4];
	else return a.len < b.len;
}

int main(void){
	int N;
	scanf("%d",&N);
	for(int i = 0; i < N; i++){
		string ip_string;
		cin >> ip_string;
		int position = ip_string.find("/");
		//如果输入中有"/" 
		if(position != string::npos){
			string ip_len;
			ip_len = ip_string.substr(position+1,ip_string.size()-position-1);
			IP[i].len = atoi(ip_len.c_str());
			ip_string.erase(position,ip_string.size()-position);
			ip_string = "."+ip_string+".";
				string k[5];
				//分离出所有.之间的值 
				int s = 0;
				string::size_type pos = ip_string.find(".");
				string::size_type pos2 = ip_string.find(".",pos+1);
				while(pos2 != string::npos){
					//如果两个 / 不相邻 
					if(pos+1 != pos2){
						k[s] = ip_string.substr(pos+1,pos2-pos-1);
						s++;
					}
					pos = pos2;
					pos2 = ip_string.find(".",pos+1);
				}
				if(s == 1){
					IP[i].a[1] = atoi(k[0].c_str());
					IP[i].a[2] = 0;
					IP[i].a[3] = 0;
					IP[i].a[4] = 0;
				}
				else if(s == 2){
					IP[i].a[1] = atoi(k[0].c_str());
					IP[i].a[2] = atoi(k[1].c_str());
					IP[i].a[3] = 0;
					IP[i].a[4] = 0;
				}
				else if(s == 3){
					IP[i].a[1] = atoi(k[0].c_str());
					IP[i].a[2] = atoi(k[1].c_str());
					IP[i].a[3] = atoi(k[2].c_str());
					IP[i].a[4] = 0;
				}
				else if(s == 4){
					IP[i].a[1] = atoi(k[0].c_str());
					IP[i].a[2] = atoi(k[1].c_str());
					IP[i].a[3] = atoi(k[2].c_str());
					IP[i].a[4] = atoi(k[3].c_str());
				}
		}
		else{
			ip_string = "."+ip_string+".";
				string k[5];
				//分离出所有.之间的值 
				int s = 0;
				string::size_type pos = ip_string.find(".");
				string::size_type pos2 = ip_string.find(".",pos+1);
				while(pos2 != string::npos){
					//如果两个 / 不相邻 
					if(pos+1 != pos2){
						k[s] = ip_string.substr(pos+1,pos2-pos-1);
						s++;
					}
					pos = pos2;
					pos2 = ip_string.find(".",pos+1);
				}
				if(s == 1){
					IP[i].a[1] = atoi(k[0].c_str());
					IP[i].a[2] = 0;
					IP[i].a[3] = 0;
					IP[i].a[4] = 0;
					IP[i].len = 8;
				}
				else if(s == 2){
					IP[i].a[1] = atoi(k[0].c_str());
					IP[i].a[2] = atoi(k[1].c_str());
					IP[i].a[3] = 0;
					IP[i].a[4] = 0;
					IP[i].len = 16;
				}
				else if(s == 3){
					IP[i].a[1] = atoi(k[0].c_str());
					IP[i].a[2] = atoi(k[1].c_str());
					IP[i].a[3] = atoi(k[2].c_str());
					IP[i].a[4] = 0;
					IP[i].len = 24;
				}
				else if(s == 4){
					IP[i].a[1] = atoi(k[0].c_str());
					IP[i].a[2] = atoi(k[1].c_str());
					IP[i].a[3] = atoi(k[2].c_str());
					IP[i].a[4] = atoi(k[3].c_str());
					IP[i].len = 32;
				}
		}
	}
	sort(IP,IP+N,cmp);
	for(int i = 0; i < N; i++){
		printf("%d.%d.%d.%d/%d\n",IP[i].a[1],IP[i].a[2],IP[i].a[3],IP[i].a[4],IP[i].len);
	}
}
