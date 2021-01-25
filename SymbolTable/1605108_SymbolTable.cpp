#include<bits/stdc++.h>

using namespace std;

/**************SymbolInfo Class Starts Here********************/

class SymbolInfo
{
    string Name,Type;
    //int position;
public:
    SymbolInfo *prev,*next;
    int position = 0;
    SymbolInfo()
    {
        this->Name = "";
        this->Type = "";
        this->prev = NULL;
        this->next = NULL;
    }
    SymbolInfo(string name,string type)
    {
        Name=name;
        Type=type;
        prev=NULL;
        next=NULL;
    }
    void setName(string Nstr)
    {
        Name=Nstr;
    }
    string getName()
    {
        return Name;
    }
    void setType(string Tstr)
    {
        Type=Tstr;
    }
    string getType()
    {
        return Type;
    }
    /*int getposition()
    {
        return position;
    }*/
} ;

/**************SymbolInfo Class Ends Here********************/

/**************ScopeTable Class Starts Here********************/

class ScopeTable
{
    int scope_id,length;
    //ScopeTable *parentScope;
public:
    ScopeTable *parentScope;
    SymbolInfo** symbol;
    ScopeTable(int n)
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
    void setscope_id(int id)
    {
        scope_id = id;
    }
    int getscope_id()
    {
        return scope_id;
    }
    int getlength()
    {
        return length;
    }
    ~ScopeTable()
    {
        delete[] symbol[length-1];
    }
    int hashFunction(string str);
    bool Insert(string name,string type);
    bool Delete(string name);
    SymbolInfo* Lookup(string name);
    void Print();
};
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
bool ScopeTable :: Insert(string name,string type)
{
    int t = hashFunction(name);
    int flag = 0;
    int pos = 0;
    if(symbol[t] == NULL)
    {
        symbol[t] = new SymbolInfo(name,type);
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
        temp->next=new SymbolInfo(name,type);
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
    // int pos = 0;
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
        temp->position++;
        if(temp==NULL)
        {
            cout<<name<<" is Not Found !!!"<<endl;
            cout<<"LookUp Unsuccessful !!!"<<endl;
            return NULL;
        }
    }
    //temp->position=pos;
    cout<<"Found in ScopeTable # "<<this->getscope_id()<<" at position "<<t<<" , "<<temp->position<<" !!!! "<<endl;
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

/**************SymbolTable Class Starts Here********************/
class SymbolTable
{
    int unique_id,size;
public:
    ScopeTable* hashTable;
    SymbolTable(int n)
    {
        this->size = n;
        this->unique_id = 0;
        this->hashTable = NULL;
    }
    void set_Id(int i)
    {
        unique_id = i;
    }
    int get_Id()
    {
        return unique_id;
    }
    void set_size(int s)
    {
        size = s;
    }
    int get_size()
    {
        return size;
    }
    void EnterScope();
    void ExitScope();
    bool Insert(string name,string type);
    bool Remove(string name);
    SymbolInfo* Lookup(string name);
    void PrintCurrentScopeTable();
    void PrintAllScopeTable();
};
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
bool SymbolTable :: Insert(string name,string type)
{
    if(hashTable->Insert(name,type))
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

int main()
{
    ifstream fin;
    fin.open("input.txt");
    string str1, str2, str3;
    int size;
    fin>>size;
    SymbolTable table(size);
    table.EnterScope();
    while(!fin.eof())
    {
        fin >> str1;
        if(str1 == "I")
        {
            fin>> str2>> str3;
            table.Insert(str2,str3);
        }
        else if(str1 == "P")
        {
            fin>>str2;
            if(str2=="A")
                table.PrintAllScopeTable();
            else if (str2=="C")
                table.PrintCurrentScopeTable();
        }
        else if(str1 == "D")
        {
            fin>> str2;
            table.Remove(str2);
        }
        else if(str1 == "L")
        {
            fin>> str2;
            table.Lookup(str2);
        }
        else if(str1 == "E")
        {
            table.ExitScope();
        }
        else if(str1=="S")
        {
            table.EnterScope();
        }
    }
    fin.close();
}
