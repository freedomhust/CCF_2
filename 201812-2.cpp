#include<cstdio>

int main(void){
	int r,y,g;
	int n,k,t;
	long long sum = 0;
	long long now_time;
	
	scanf("%d%d%d",&r,&y,&g);
	scanf("%d",&n);
	for(int i = 0; i < n; i++){
		scanf("%d%d",&k,&t);
		now_time = sum%(r+y+g);
		//Ã»Óöµ½µÆ 
		if(k == 0) sum += t;
		//ºìµÆ 
		else if(k == 1){
			//µÆ±äÑÕÉ« 
			if(now_time > t){
				//ÂÌµÆ 
				if(now_time - t <= g){
					sum += 0; 
				} 
				//»ÆµÆ 
				else if(now_time - t - g <= y){
					sum += y-now_time+t+g+r;
				}
				//»¹ÊÇºìµÆ 
				else if(now_time - t - g - y <= r){
					sum += r-now_time+t+g+y;
				}
			}
			else if(now_time <= t){
				sum += t-now_time;
			}	
		}
		//»ÆµÆ 
		else if(k == 2){
			//µÆ±äÑÕÉ« 
			if(now_time > t){
				//ºìµÆ 
				if(now_time - t <= r){
					sum += r-now_time+t;
				}
				//ÂÌµÆ 
				else if(now_time-t-r <= g){
					sum += 0;
				}
				//»ÆµÆ 
				else if(now_time-t-r-g <= y){
					sum += y-now_time+t+r+g+r; 
				}
			}
			//Ã»±äÑÕÉ« 
			else if(now_time <= t){
				sum += t - now_time + r; 
			}
		}
		//ÂÌµÆ 
		else if(k == 3){
			if(now_time > t){
				//»ÆµÆ 
				if(now_time - t <= y){
					sum += y-now_time+t + r;
				}
				else if(now_time-t-y <= r){
					sum += r-now_time+t+y; 
				}
				else if(now_time-t-y-r <= g){
					sum += 0;
				}
			}
			else if(now_time <= t){
				sum += 0;
			}
		}
	}
	printf("%lld\n",sum);
}
