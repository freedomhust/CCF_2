#include<cstdio>
#include<queue>
using namespace std;

struct node{
	int t1,t2;
}Node;

int main(void){
	queue<node> A,B;
	int n;
	int sum = 0;
	scanf("%d",&n);
	for(int i = 0; i < n; i++){
		scanf("%d%d",&Node.t1,&Node.t2);
		A.push(Node);
	}
	for(int i = 0; i < n; i++){
		scanf("%d%d",&Node.t1,&Node.t2);
		B.push(Node);
	}
	while(!A.empty() && !B.empty()){
		node topA = A.front();
		node topB = B.front();
		if(topB.t1 <= topA.t1){
			if(topB.t2 <= topA.t1){
				sum += 0;
				B.pop();
			}
			else if(topB.t2 > topA.t1 && topB.t2 <= topA.t2){
				sum += topB.t2-topA.t1;
				B.pop();
			}
			else if(topB.t2 > topA.t2){
				sum+= topA.t2-topA.t1;
				A.pop();
			}
		}
		else if(topB.t1 > topA.t1 && topB.t1 <= topA.t2){
			if(topB.t2 <= topA.t2){
				sum += topB.t2 - topB.t1;
				B.pop();
			}
			else if(topB.t2 > topA.t2){
				sum += topA.t2 - topB.t1;
				A.pop();
			}
		}
		else if(topB.t1 > topA.t2){
			sum += 0;
			A.pop();
		}
	}
	printf("%d\n",sum);
}
