#include<cstdio>
#include<iostream>
#include<string>
#include<cstring>
#include<algorithm>
#include<cmath>
using namespace std;



int main(void){
	int N;
	scanf("%d",&N);
	for(int i = 0; i < N; i++){
		char line[10];
		scanf("%s",line);
		int x1,x2,x3,x4;
		char signal_1[4];
		int y1,y2,y3;
		char signal_2[4];
		int z1,z2;
		char signal_3[4];
		int sum;
		x1 = line[0]-'0';
		signal_1[1] = line[1];
		x2 = line[2]-'0';
		signal_1[2] = line[3];
		x3 = line[4]-'0';
		signal_1[3] = line[5];
		x4 = line[6]-'0';
		//第一轮
		if(signal_1[1] == 'x' || signal_1[1] == '/'){
			if(signal_1[1] == 'x') y1 = x1*x2;
			else y1 = x1/x2;
			y2 = x3;
			y3 = x4;
			signal_2[1] = signal_1[2];
			signal_2[2] = signal_1[3];
		}
		else if(signal_1[2] == 'x' || signal_1[2] == '/'){
			y1 = x1;
			signal_2[1] = signal_1[1];
			if(signal_1[2] == 'x') y2 = x2*x3;
			else y2 = x2/x3;
			y3 = x4;
			signal_2[2] = signal_1[3];
		}
		else if(signal_1[3] == 'x' || signal_1[3] == '/'){
			y1 = x1;
			signal_2[1] = signal_1[1];
			y2 = x2;
			signal_2[2] = signal_1[2];
			if(signal_1[3] == 'x') y3 = x3*x4;
			else y3 = x3/x4;
		}
		else {
			if(signal_1[1] == '+') y1 = x1+x2;
			else if(signal_1[1] == '-') y1 = x1-x2;
			signal_2[1] = signal_1[2];
			y2 = x3;
			signal_2[2] = signal_1[3];
			y3 = x4;
		}
		
		//第二轮
		if(signal_2[1] == 'x' || signal_2[1] == '/'){
			if(signal_2[1] == 'x') z1 = y1*y2;
			else z1 = y1/y2;
			signal_3[1] = signal_2[2];
			z2 = y3;
		} 
		else if(signal_2[2] == 'x' || signal_2[2] == '/'){
			z1 = y1;
			signal_3[1] = signal_2[1];
			if(signal_2[2] == 'x') z2 = y2*y3;
			else z2 = y2/y3;
		}
		else{
			if(signal_2[1] == '+') z1 = y1+y2;
			else z1 = y1-y2;
			signal_3[1] = signal_2[2];
			z2 = y3;
		}
		//第三轮
		if(signal_3[1] == 'x') sum = z1*z2;
		else if(signal_3[1] == '/') sum = z1/z2;
		else if(signal_3[1] == '+') sum = z1+z2;
		else if(signal_3[1] == '-') sum = z1-z2;
		
		if(sum == 24) printf("Yes\n");
		else printf("No\n");
	}
} 
