#include<cstdio>
#include<iostream>
#include<string>
#include<cstring>
#include<algorithm>
#include<vector>
using namespace std;

struct url_addr{
	vector<string> url_para;
	string url_name;
}url[105];

int n,m;
string url_address;

int main(void){
	scanf("%d%d",&n,&m);
	for(int i = 0; i < n; i++){
		cin >> url_address >> url[i].url_name;
		//分离出所有/之间的值 
		url_address = url_address + "/";
		int s = 0;
		string::size_type pos = url_address.find("/");
		string::size_type pos2 = url_address.find("/",pos+1);
		while(pos2 != string::npos){
			//如果两个 / 不相邻 
			if(pos+1 != pos2){
				url[i].url_para.push_back(url_address.substr(pos+1,pos2-pos-1));
				s++;
			}
			pos = pos2;
			pos2 = url_address.find("/",pos+1);
		}
	}

	for(int i = 0; i < m; i++){
		cin >> url_address;
		//最后一个字符是否为 / 
		int para_has_it = 0;
		if(url_address[url_address.size()-1] == '/') para_has_it = 1;
		//分离出所有/之间的值
		url_address = url_address + "/";
		int s = 0;
		string para[105];
		
		string::size_type pos = url_address.find("/");
		string::size_type pos2 = url_address.find("/",pos+1);
		while(pos2 != string::npos){
			//如果两个 / 不相邻 
			if(pos+1 != pos2){
				para[s] = url_address.substr(pos+1,pos2-pos-1);
				s++;
			}
			pos = pos2;
			pos2 = url_address.find("/",pos+1);
		}
		
		//开始进行字符串匹配
		//每个字符串都要一一进行匹配
		//所以遍历n次
		//首先要对输入的字符串进行是否合法的判断
		for(int j = 0; j < n; j++){
			int has_path = 0;
			//对待匹配字符串的所有参数一一进行配对 
			bool flag = true;  
			vector<string> output;
			for(int k = 0; k < s; k++){
//				cout << k << endl;
				if(k >= url[j].url_para.size()){
					flag = false;
					break;
				}
//				cout << url[j].url_para[k] << " " << para[k] << " " << j << " " << k << " " << url[j].url_para.size() << endl;
				//如果类型是int型，则匹配的必须是数字 
				if(url[j].url_para[k] == "<int>"){
					//遍历待匹配参数的所有字符，如果有非数字则匹配失败 
					for(int m = 0; m < para[k].size(); m++){
//						cout << para[k][m] << " ";
						if(para[k][m] != '0' && para[k][m] != '1' && para[k][m] != '2'
						&& para[k][m] != '3' && para[k][m] != '4' && para[k][m] != '5'
						&& para[k][m] != '6' && para[k][m] != '7' && para[k][m] != '8' && para[k][m] != '9'){
							flag = false;
							break;
						}
					}
					if(flag == false) break;
					//如果匹配成功，则记录 
					else{
						//去掉前导0
						while(para[k][0] == '0' && para[k].size() > 1) para[k].erase(para[k].begin());
						output.push_back(para[k]);
//						cout << para[k] << endl;
					}
				}
				//如果是str型 
				else if(url[j].url_para[k] == "<str>"){
					//直接算匹配成功
					output.push_back(para[k]); 
				}
				//如果是path型
				else if(url[j].url_para[k] == "<path>"){
					has_path = 1;
					//直接算匹配成功，待匹配字符串后面的所有参数全部要化成一个参数
					string tmp;
					tmp = para[k];
					for(int m = k+1; m < s; m++){
						tmp += "/"+para[m];
					}
//					if(para_has_it) tmp += "/";
					output.push_back(tmp);
					break;
				}
				//如果只是单纯的字符串匹配 
				else{
					 //如果两个参数并不相等，说明匹配失败 
					 if(url[j].url_para[k] != para[k]){
					 	flag = false;
					 	break;
					 }
				}
			}
			
			//如果所有的字符串都被匹配成功了说明
			//已经找到正确结果了，不需要再对后面的字符串遍历了
			//输出正确结果，break掉大循环 
			if(flag == true && (s == url[j].url_para.size() || has_path)){
				cout << url[j].url_name << " ";
				for(int k = 0; k < output.size(); k++) cout << output[k] << " ";
				cout << endl; 
				break;
			}
			
			//遍历到最后一条字符串了但还是错误
			//说明没有匹配的字符串，输出404
			else if((flag == false || !(s == url[j].url_para.size() || has_path) ) && j == n-1){
				cout << "404" << endl;
				break;
			}
		}
		
	}
	
	
}
