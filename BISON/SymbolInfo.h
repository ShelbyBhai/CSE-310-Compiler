#include<bits/stdc++.h>
#include"FunctionOpt.h"
#ifndef SYMBOLINFO
#define SYMBOLINFO
using namespace std;
class SymbolInfo
{
    string Name,Type,DeclrType;
    //int position;
    Function* isFunc;
public:
    SymbolInfo *prev,*next;
    int position = 0;
    SymbolInfo();
    SymbolInfo(string name,string type);
    SymbolInfo(string name,string type,string declrType);
    void setName(string Nstr);
    string getName();
    void setType(string Tstr);
    string getType();
    void setDecType(string Dstr);
    string getDecType();
    void setIsFunc();
    Function* getIsFunc();
};
#endif //SYMBOLINFO



    /*int getposition()
    {
        return position;
    }*/

/**************SymbolInfo Class Ends Here********************/
