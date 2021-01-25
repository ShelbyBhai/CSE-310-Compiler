#include<bits/stdc++.h>

#include"SymbolInfo.h"

using namespace std;
/**************ScopeTable Class Starts Here********************/

class ScopeTable
{
    int scope_id,length;
    //ScopeTable *parentScope;
public:
    ScopeTable *parentScope;
    SymbolInfo** symbol;
    ScopeTable(int n);
    void setscope_id(int id);
    int getscope_id();
    int getlength();
    int hashFunction(string str);
    bool Insert(string name,string type);
    bool Insert(string name,string type,string dectype);
    bool Delete(string name);
    SymbolInfo* Lookup(string name);
    void Print();
};
ScopeTable :: ScopeTable(int n)
{
    length = n;
    scope_id = 1;
    symbol = new SymbolInfo* [n];
    for(int i=0; i<n; i++)
    {
        symbol[i] = NULL;
    }
    parentScope = NULL;
}

void ScopeTable :: setscope_id(int id)
{
    scope_id = id;
}
int ScopeTable :: getscope_id()
{
    return scope_id;
}
int ScopeTable :: getlength()
{
    return length;
}
int ScopeTable :: hashFunction(string str)
{
    int hash_key=0;
    for(int i=0; i<str.length(); i++)
    {
        hash_key+=str[0];
    }
    hash_key=hash_key%length;
    return hash_key;
}
bool ScopeTable :: Insert(string name,string type,string dectype="")
{
    int t = hashFunction(name);
    int flag = 0;
    int pos = 0;
    if(symbol[t] == NULL)
    {
        symbol[t] = new SymbolInfo(name,type,dectype);
        flag = 1;
    }
    else
    {
        SymbolInfo *temp = symbol[t];
        if(temp->getName().compare(name) == 0)
        {
            cout<<"<"<<temp->getName()<<" , "<<temp->getType()<<">"<<" already exists in Current ScopeTable !!!"<<endl;
            cout<<"Insertion Failed!!!"<<endl;
            flag = 0;
            return false;
        }
        while(temp->next!=NULL)
        {
            if(temp->getName().compare(name) == 0)
            {
                cout<<"<"<<temp->getName()<<" , "<<temp->getType()<<">"<<" already exists in Current ScopeTable !!!"<<endl;
                cout<<"Insertion Failed !!!"<<endl;
                flag = 0;
                return false;
            }
            else
            {
                temp = temp->next;
                temp->position++;
            }
        }
        temp->position++;
        pos = temp->position;
        temp->next=new SymbolInfo(name,type,dectype);
        temp->next->prev=temp;
        flag = 1;
    }
    if(flag == 1)
    {
        cout<<"Inserted in ScopeTable # "<<this->getscope_id()<<" at position "<<t<<" , "<<pos<<" !!! "<<endl;
        cout<<"Insertion Successful !!!"<<endl;
    }
}
SymbolInfo* ScopeTable :: Lookup(string name)
{
    int t = hashFunction(name);
    int pos = 0;
    SymbolInfo *temp = symbol[t];
    if(temp == NULL)
    {
        cout<<name<<" is Not Found !!!"<<endl;
        cout<<"LookUp Unsuccessful !!!"<<endl;
        return NULL;
    }
    while(temp->getName().compare(name) != 0)
    {
        temp=temp->next;
        pos++;
        if(temp==NULL)
        {
            cout<<name<<" is Not Found !!!"<<endl;
            cout<<"LookUp Unsuccessful !!!"<<endl;
            return NULL;
        }
    }
    //temp->position=pos;
    cout<<"Found in ScopeTable # "<<this->getscope_id()<<" at position "<<t<<" , "<<pos<<" !!!! "<<endl;
    return temp;
}
bool ScopeTable :: Delete(string name)
{
    SymbolInfo* current;
    current = Lookup(name);
    if(current == NULL)
    {
        cout<<"Deletion Unsuccessful!!!"<<endl;
        return false;
    }
    if(current->prev != NULL)
    {
        current->prev->next = current->next;
    }
    if( current->next != NULL)
    {
        current->next->prev = current->prev;
    }
    if(current->prev == NULL && current->next == NULL)
    {
        symbol[hashFunction(name)] = NULL ;
    }
    if( current->prev == NULL && current->next != NULL)
    {
        symbol[hashFunction(name)] = current->next ;
    }
    cout<<"Deleted entry at "<<hashFunction(name)<<" , "<<current->position<<" from current ScopeTable"<<endl;
    cout<<"Deletion Successful!!!"<<endl;
}
void ScopeTable :: Print()
{
    cout<<"ScopeTable # "<<this->getscope_id()<<endl;
    for(int i=0; i<this->getlength() ; i++)
    {
        SymbolInfo* temp=symbol[i];
        cout<<i<<" --> ";
        if(temp == NULL)
        {
            cout<<endl;
        }
        else
        {
            while(temp != NULL)
            {
                cout<<" < "<<temp->getName()<<" : "<<temp->getType()<<" > ";
                temp=temp->next;
            }
            cout<<endl;
        }
        delete temp;
    }
}
/**************ScopeTable Class Ends Here********************/

