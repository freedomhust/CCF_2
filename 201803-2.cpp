#include<cstdio>
#include<algorithm>
using namespace std;

struct Ball{
	int num;
	int pos;
	int L_or_R;
}ball[105];

bool cmpA(Ball a, Ball b){
	return a.pos < b.pos;
}

bool cmpB(Ball a, Ball b){
	return a.num < b.num;
}

int main(void){
	int n,L,t;
	scanf("%d%d%d",&n,&L,&t);
	for(int i = 0; i < n; i++){
		scanf("%d",&ball[i].pos);
		ball[i].L_or_R = 1;
		ball[i].num = i;
	}
	sort(ball,ball+n,cmpA);
	for(int i = 0; i < t; i++){
		for(int j = 0; j < n; j++){
			ball[j].pos += ball[j].L_or_R;
		}
		for(int j = 0; j < n; j++){
			if(j == n-1){
				if(ball[j].pos == L) ball[j].L_or_R = ball[j].L_or_R*-1;
			}
			else if(j == 0){
				if(ball[j].pos == 0) ball[j].L_or_R = ball[j].L_or_R*-1;
				if(ball[j].pos == ball[j+1].pos){
					ball[j].L_or_R = ball[j].L_or_R*-1;
					ball[j+1].L_or_R = ball[j+1].L_or_R*-1;
				}
			}
			else{
				if(ball[j].pos == ball[j+1].pos){
					ball[j].L_or_R = ball[j].L_or_R*-1;
					ball[j+1].L_or_R = ball[j+1].L_or_R*-1;
				}
			}
		}
	}
	sort(ball,ball+n,cmpB);
	for(int i = 0; i < n; i++){
		printf("%d ",ball[i].pos);
	}
}
