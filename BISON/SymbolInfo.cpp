#include"SymbolInfo.h"

SymbolInfo :: SymbolInfo()
{
    this->Name = "";
    this->Type = "";
    this->prev = NULL;
    this->next = NULL;
}
SymbolInfo :: SymbolInfo(string name,string type)
{
    Name=name;
    Type=type;
    prev=NULL;
    next=NULL;
}
SymbolInfo :: SymbolInfo(string name,string type,string declrType)
{
    this->Name = name;
    this->Type = type;
    this->DeclrType = declrType;
    prev = NULL;
    next = NULL;
}
void SymbolInfo :: setName(string Nstr)
{
    Name=Nstr;
}
string SymbolInfo :: getName()
{
    return Name;
}
void SymbolInfo :: setType(string Tstr)
{
    Type=Tstr;
}
string SymbolInfo :: getType()
{
    return Type;
}
void SymbolInfo :: setDecType(string Dstr)
{
    DeclrType = Dstr;
}
string SymbolInfo :: getDecType()
{
    return DeclrType;
}
void SymbolInfo :: setIsFunc()
{
    isFunc = new Function();
}
Function* SymbolInfo :: getIsFunc()
{
    return isFunc;
}
