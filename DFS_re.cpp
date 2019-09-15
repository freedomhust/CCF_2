#include<cstdio>

void DFS(int index, int sumW, int sumC){
	if(index == n){
		if(sumC > maxvalue){
			maxvalue = sumC;
		}
		return;
	}
	DFS(index+1,sumW,sumC);
	if(sumW+w[index] <= V){
		DFS(index+1,sumW+w[index],sumC+c[index]);
	}
}

void DFS(int index, int NowK, int sum, int sumsqu){
	if(nowK == K && sum == x){
		if(sumsqu > maxsumsqu){
			maxsumsqu = sumsqu;
			ans = temp;
		}
		return;
	}
	if(index == n || nowK > K || sum > x) return;
	
	temp.push_back(A[index]);
	DFS(index+1,NowK+1,sum+A[index],sumsqu+A[index]*A[index]);
	temp.pop_back(A[index]);
	DFS(index+1,nowK,sum,sumsqu);
	
}


