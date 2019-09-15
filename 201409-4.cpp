#include <bits/stdc++.h>
#define ll long long
#define INF 0x3f3f3f3f
using namespace std;
const int maxn = 1e3+10;
struct node
{
    int x, y, t;
    node(int X, int Y, int T): x(X), y(Y), t(T) {}
};
int n, m, k, d, K;
int g[maxn][maxn], vis[maxn][maxn];
int dir[4][2] = {1, 0, -1, 0, 0, 1, 0, -1};
ll ans = 0; //会爆int，应该使用long long
queue <node> q;
 
void read()
{
    cin >> n >> m >> k >> d;
    for(int i = 0; i < m; ++i)
    {
        int x, y;
        cin >> x >> y;
        vis[x][y] = 1;
        q.push(node(x, y, 0)); //把每个分店都预先放进队列中
                               //这样bfs的时候，它们可以共用一个vis数组
                               //可以节省大量时间，就避免了超时
    }
    for(int i = 0; i < k; ++i)
    {
        int x, y, c;
        cin >> x >> y >> c;
        if(g[x][y])
            g[x][y] += c;
        else
        {
            g[x][y] = c;
            K++;
        }
    }
    for(int i = 0; i < d; ++i)
    {
        int x, y;
        cin >> x >> y;
        vis[x][y] = 1;
    }
}

bool isLegal(int X, int Y, int i)
{
    int x = X+dir[i][0], y = Y+dir[i][1];
    if(x < 1 || x > n || y < 1 || y > n)
        return false;
    if(vis[x][y])
        return false;
    return true;
}

void bfs()
{
    while(!q.empty())
    {
        node cur = q.front();
        q.pop();
        if(g[cur.x][cur.y])
        {
            ans += cur.t*g[cur.x][cur.y];
            if(!(--K)) //所有订单配送完毕
                return;
        }
 
        for(int i = 0; i < 4; ++i)
            if(isLegal(cur.x, cur.y, i))
            {
                q.push(node(cur.x+dir[i][0], cur.y+dir[i][1], cur.t+1));
                vis[cur.x+dir[i][0]][cur.y+dir[i][1]] = 1;
            }
    }
}
 
void solve()
{
    bfs();
    cout << ans;
}
 
int main()
{
    read();
    solve();
    return 0;
}
 
