#include <cstdio>
#include <iostream>
#include <cmath>
#include <cstring>
#include <algorithm>

using namespace std;

int main() {
    int sum = 0, x;
    freopen("data.txt", "r", stdin);
    freopen("data.ans", "w", stdout);
    for (int i = 1; i <=100;i++) {
        scanf("%x", &x);
        sum += x;
    }
    printf("%x", sum);
    return 0;
}
