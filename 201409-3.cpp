#include<string>
#include<cstdio>
#include<cstring>
#include<algorithm>
#include<iostream>
using namespace std;

int main(void){
	string S;
	int N;
	int need_transform_or_not;
	cin >> S;
	cin >> need_transform_or_not;
	cin >> N;
	//如果字符串大小写不敏感则直接全部转换成小写 
	if(need_transform_or_not == 0){
		transform(S.begin(), S.end(), S.begin(), ::tolower);
	}
	string string_prototype;
	for(int i = 0; i < N; i++){
		string string_copy;
		cin >> string_prototype;
		string_copy = string_prototype;
		if(need_transform_or_not == 0){
			transform(string_copy.begin(), string_copy.end(), string_copy.begin(), ::tolower);
		}
		if(string_copy.find(S) != string::npos){
			cout << string_prototype << endl;
		}
	}
} 
