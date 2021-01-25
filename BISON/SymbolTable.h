#include<bits/stdc++.h>

#include"ScopeTable.h"

using namespace std;

/**************SymbolTable Class Starts Here********************/
class SymbolTable
{
    int unique_id,size;
public:
    ScopeTable* hashTable;
    SymbolTable(int n);
    void set_Id(int i);
    int get_Id();
    void set_size(int s);
    int get_size();
    void EnterScope();
    void ExitScope();
    //bool Insert(string name,string type);
    bool Insert(string name,string type,string dectype);
    bool Remove(string name);
    SymbolInfo* Lookup(string name);
    SymbolInfo* LookupInCurrent(string name);
    void PrintCurrentScopeTable();
    void PrintAllScopeTable();
};


SymbolTable :: SymbolTable(int n)
{
    this->size = n;
    this->unique_id = 0;
    this->hashTable = NULL;
}
void SymbolTable :: set_Id(int i)
{
    unique_id = i;
}
int SymbolTable :: get_Id()
{
    return unique_id;
}
void SymbolTable :: set_size(int s)
{
    size = s;
}
int  SymbolTable :: get_size()
{
    return size;
}
void SymbolTable :: EnterScope()
{
    ScopeTable* current;
    current = new ScopeTable(size);
    current->parentScope = hashTable;
    hashTable = current;
    unique_id++;
    current->setscope_id(unique_id);
    cout<<"New ScopeTable with id "<<unique_id<<" created !!!"<<endl;
}
void SymbolTable :: ExitScope()
{
    ScopeTable* temp;
    temp = hashTable;
    hashTable = hashTable->parentScope;
    cout<<"ScopeTable with id "<<temp->getscope_id()<<" removed !!!"<<endl;
    delete temp;
}
/* bool SymbolTable :: Insert(string name,string type)
{
    if(hashTable->Insert(name,type))
        return true;
    else
        return false;
}*/
bool SymbolTable :: Insert(string name,string type,string dectype="")
{
    if(hashTable->Insert(name,type,dectype))
        return true;
    else
        return false;
}
bool SymbolTable :: Remove(string name)
{
    if(hashTable->Delete(name))
        return true;
    else
        return false;
}
SymbolInfo* SymbolTable :: Lookup(string name)
{
    SymbolInfo* symbol;
    ScopeTable* temp;
    temp = hashTable;
    while(temp != NULL)
    {
        symbol = temp->Lookup(name);
        if(symbol != NULL)
            return symbol;
        else
            temp = temp->parentScope;
    }
    return NULL;
}
SymbolInfo* SymbolTable :: LookupInCurrent(string name)
{
    if(hashTable)
    {
        return hashTable->Lookup(name);
    }
    return 0; 
}
void SymbolTable :: PrintCurrentScopeTable()
{
    if(hashTable != NULL)
        hashTable->Print();
}
void SymbolTable :: PrintAllScopeTable()
{
    ScopeTable *temp_for_print;
    temp_for_print = hashTable;
    while(temp_for_print != NULL)
    {
        temp_for_print->Print();
        temp_for_print = temp_for_print->parentScope;
    }
}
/**************SymbolTable Class Ends Here********************/


