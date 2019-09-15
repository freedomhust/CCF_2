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
		//���������/֮���ֵ 
		url_address = url_address + "/";
		int s = 0;
		string::size_type pos = url_address.find("/");
		string::size_type pos2 = url_address.find("/",pos+1);
		while(pos2 != string::npos){
			//������� / ������ 
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
		//���һ���ַ��Ƿ�Ϊ / 
		int para_has_it = 0;
		if(url_address[url_address.size()-1] == '/') para_has_it = 1;
		//���������/֮���ֵ
		url_address = url_address + "/";
		int s = 0;
		string para[105];
		
		string::size_type pos = url_address.find("/");
		string::size_type pos2 = url_address.find("/",pos+1);
		while(pos2 != string::npos){
			//������� / ������ 
			if(pos+1 != pos2){
				para[s] = url_address.substr(pos+1,pos2-pos-1);
				s++;
			}
			pos = pos2;
			pos2 = url_address.find("/",pos+1);
		}
		
		//��ʼ�����ַ���ƥ��
		//ÿ���ַ�����Ҫһһ����ƥ��
		//���Ա���n��
		//����Ҫ��������ַ��������Ƿ�Ϸ����ж�
		for(int j = 0; j < n; j++){
			int has_path = 0;
			//�Դ�ƥ���ַ��������в���һһ������� 
			bool flag = true;  
			vector<string> output;
			for(int k = 0; k < s; k++){
//				cout << k << endl;
				if(k >= url[j].url_para.size()){
					flag = false;
					break;
				}
//				cout << url[j].url_para[k] << " " << para[k] << " " << j << " " << k << " " << url[j].url_para.size() << endl;
				//���������int�ͣ���ƥ��ı��������� 
				if(url[j].url_para[k] == "<int>"){
					//������ƥ������������ַ�������з�������ƥ��ʧ�� 
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
					//���ƥ��ɹ������¼ 
					else{
						//ȥ��ǰ��0
						while(para[k][0] == '0' && para[k].size() > 1) para[k].erase(para[k].begin());
						output.push_back(para[k]);
//						cout << para[k] << endl;
					}
				}
				//�����str�� 
				else if(url[j].url_para[k] == "<str>"){
					//ֱ����ƥ��ɹ�
					output.push_back(para[k]); 
				}
				//�����path��
				else if(url[j].url_para[k] == "<path>"){
					has_path = 1;
					//ֱ����ƥ��ɹ�����ƥ���ַ�����������в���ȫ��Ҫ����һ������
					string tmp;
					tmp = para[k];
					for(int m = k+1; m < s; m++){
						tmp += "/"+para[m];
					}
//					if(para_has_it) tmp += "/";
					output.push_back(tmp);
					break;
				}
				//���ֻ�ǵ������ַ���ƥ�� 
				else{
					 //�����������������ȣ�˵��ƥ��ʧ�� 
					 if(url[j].url_para[k] != para[k]){
					 	flag = false;
					 	break;
					 }
				}
			}
			
			//������е��ַ�������ƥ��ɹ���˵��
			//�Ѿ��ҵ���ȷ����ˣ�����Ҫ�ٶԺ�����ַ���������
			//�����ȷ�����break����ѭ�� 
			if(flag == true && (s == url[j].url_para.size() || has_path)){
				cout << url[j].url_name << " ";
				for(int k = 0; k < output.size(); k++) cout << output[k] << " ";
				cout << endl; 
				break;
			}
			
			//���������һ���ַ����˵����Ǵ���
			//˵��û��ƥ����ַ��������404
			else if((flag == false || !(s == url[j].url_para.size() || has_path) ) && j == n-1){
				cout << "404" << endl;
				break;
			}
		}
		
	}
	
	
}
