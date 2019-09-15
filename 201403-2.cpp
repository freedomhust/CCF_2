#include<cstdio>
#include<cstring>
#include<cmath>
#include<algorithm>

using namespace std;

struct Window{
	int x1,y1;
	int x2,y2;
	int level;
	int id;
}window[12];

bool cmp(Window a, Window b){
	return a.level < b.level;
}

int main(void){
	int N,M;
	scanf("%d %d",&N,&M);
	for(int i = 1; i <= N; i++){
		scanf("%d %d %d %d",&window[i].x1,&window[i].y1,
		&window[i].x2,&window[i].y2);
		window[i].level = i;
		window[i].id = i;
	}
	
	
	int x,y;
	for(int i = 0; i < M; i++) {
		int max_level = 0;
		scanf("%d %d",&x,&y);
		//从顶层窗口开始判断该点是否在窗口上 
		for(int j = N; j >= 1; j--){
			if(window[j].x1 <= x && window[j].x2 >= x && window[j].y1 <= y && window[j].y2 >= y){
				max_level = j;
				break;
			}
		}
		
		//开始将层次修改 
		if(max_level != 0){
			printf("%d\n",window[max_level].id);
			//将该窗口的层次调到最高
			window[max_level].level = N;
			//将前面窗口的层级依次降低
			for(int j = max_level+1; j <= N; j++){
				window[j].level--;
			}
			sort(window+1,window+N+1,cmp);
		}
		else printf("IGNORED\n");
		
	}
}
