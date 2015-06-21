#include <cstdio>
#include <iostream>
#include <cmath>
#include <cstring>
#include <algorithm>
#include <ctime>

using namespace std;

int main() {
    srand(time(0));
    freopen("data.txt","w",stdout);
    for (int i = 1;i <=100;i++) {
        //printf("%08x\n",rand()*32768+rand());
        printf("%08x\n", i);
    }
    return 0;
}
