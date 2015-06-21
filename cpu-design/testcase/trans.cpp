#include <cstdio>
#include <iostream>
#include <cmath>
#include <cstring>
#include <algorithm>
#include <map>
#include <string>

using namespace std;

map<string, int> m;

char s[10],s1[10],s2[10],s3[10];
string sline;

string sToInt(char* s,int len, int width) {
    int num = 0;
    for (int i = 0;i < len; i++) {
        num = num *10 + (s[i]-'0');
    }
    string ss = "";
    while (num) {
        ss = char(num%2+'0')+ss;
        num /= 2;
    }
    while (ss.length() < width) {
        ss = '0'+ss;
    }

    return ss;
}

string getreg(char* a) {
    string s = "";

    if (a[1]=='a') {
        int i = a[2]-'0';
        i = i+4;
        while (i) {
            s = char(i%2+'0')+s;
            i = i / 2;
        }
        while (s.length()<5) {
            s='0'+s;
        }
    }

    if (a[1]=='t') {
        int i = a[2]-'0';
        i = i+8;
        while (i) {
            s = char(i%2+'0')+s;
            i = i / 2;
        }
        while (s.length()<5) {
            s='0'+s;
        }
    }
    
    if (a[1] >= '0' && a[1] <= '9')
    {
             int i = a[1] - '0';
             while (i)
             {
                   s = char(i % 2 + '0') + s;
                   i /= 2;
             }
             while (s.length() < 5)
             {
                   s = '0' + s;
             }
    }

    return s;
}

string intToS(int num, int width) {
    string s = "";
    while (num) {
        s = char(num%2+'0')+s;
        num /= 2;
    }
    while (s.length()<width) {
        s = '0'+s;
    }
    return s;
}

int main() {
    freopen("mips.s","r",stdin);
    freopen("instruction.txt","w",stdout);
    int pc = -1;
    while (~scanf("%s", s)) {
        //cout << s << endl;
        if (strcmp(s,"label")==0) {
            m["label"] = pc+1;
            getchar();
        } else if (strcmp(s,"add")==0) {
            scanf("%s", s1);getchar();
            scanf("%s", s2);getchar();
            scanf("%s", s3);getchar();
            sline = "";

            sline = "000000"+getreg(s2)+getreg(s3)+getreg(s1)+"00000"+"100000";
        } else if (strcmp(s,"addi")==0) {
            scanf("%s", s1);getchar();
            scanf("%s", s2);getchar();
            scanf("%s", s3);getchar();
            sline = "001000"+getreg(s1)+getreg(s2)+sToInt(s3,strlen(s3),16);
        } else if (strcmp(s,"lw")==0) {
            scanf("%s", s1);getchar();
            int i=0;
            char c;
            while (true) {
                c = getchar();
                if (!('0'<=c && c <= '9')) break;
                s2[i++] = c;
            }
            scanf("%s", s3);getchar();
            sline = "100011"+getreg(s1)+getreg(s3)+sToInt(s2,i,16);
        } else if (strcmp(s,"sw")==0) {
            scanf("%s", s1);getchar();
            int i=0;
            char c;
            while (true) {
                c = getchar();
                if (!('0'<=c && c <= '9')) break;
                s2[i++] = c;
            }
            scanf("%s", s3);getchar();
            sline = "101011"+getreg(s1)+getreg(s3)+sToInt(s2,i,16);
        } else if (strcmp(s,"bne")==0) {
            scanf("%s", s1);getchar();
            scanf("%s", s2);getchar();
            scanf("%s", s3);getchar();

            /*cout << s1 << endl;
            cout << s2 << endl;
            cout << s3 << endl;*/

            string s = "";
            int len = strlen(s3);
            for (int i = 0; i < len; i++) {
                s = s+s3[i];
            }

            sline = "000101"+getreg(s1)+getreg(s2)+intToS(m[s],16);
        } else if (strcmp(s,"sub")==0) {
            scanf("%s", s1);getchar();
            scanf("%s", s2);getchar();
            scanf("%s", s3);getchar();
            sline = "";

            sline = "000000"+getreg(s2)+getreg(s3)+getreg(s1)+"00000"+"100010";
        } else if (strcmp(s,"sll")==0) {
            scanf("%s", s1);getchar();
            scanf("%s", s2);getchar();
            scanf("%s", s3);getchar();
            sline = "";

            sline = "000000"+getreg(s2)+getreg(s3)+getreg(s1)+"00000"+"000000";
        } else if (strcmp(s,"srl")==0) {
            scanf("%s", s1);getchar();
            scanf("%s", s2);getchar();
            scanf("%s", s3);getchar();
            sline = "";

            sline = "000000"+getreg(s2)+getreg(s3)+getreg(s1)+"00000"+"000010";
        } else if (strcmp(s,"mul")==0) {
            scanf("%s", s1);getchar();
            scanf("%s", s2);getchar();
            scanf("%s", s3);getchar();
            sline = "";

            sline = "011100"+getreg(s2)+getreg(s3)+getreg(s1)+"00000"+"000010";
        }

        if (strcmp(s,"label")==0) {
            pc = pc;
        } else {
            pc = pc+1;
            cout << sline << endl;
        }
    }

    for (int i = 0; i < 32; i++) {
        printf("1");
    }
    printf("\n");
}
