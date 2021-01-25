%option noyywrap

%{
#include<bits/stdc++.h>

using namespace std;

int line_count=1;

int count_error = 0;

FILE *logout;
FILE *tokenout;

string replacePattern(string str, string pattern) 
{ 

	// making an iterator for string str 
	string::iterator it = str.begin(); 
	// run this loop until iterator reaches end of string 
	while (it != str.end()) { 
		// searching the first index in string str where 
		// the first occurrence of string pattern occurs 
		it = search(str.begin(), str.end(), pattern.begin(), pattern.end()); 
		// checking if iterator is not pointing to end of the 
		// string str 
		if (it != str.end()) { 
			// erasing the full pattern string from that iterator 
			// position in string str 
			str.erase(it, it + pattern.size()); 
			// inserting 'X' at that iterator posiion 
			str.insert(it, '\t'); 
		} 
	} 

	// this loop removes consecutive 'X' in string s 
	// Example: GeeksGeeksforGeeks was changed to 'XXforX' 
	// running this loop will change it to 'XforX' 
	for (int i = 0; i < str.size() - 1; i++) { 
		if (str[i] == '\t' && str[i + 1] == '\t') { 
			// removing 'X' at posiion i in string str 
			str.erase(str.begin() + i); 
			i--; // i-- because one character was deleted 
			// so repositioning i 
		} 
	} 
	return str; 
} 

int multiLINECOUNT(string str)
{
    string line = str ;

    int C = 0; 
      
    vector <string> tokens; 
      
    stringstream check1(line); 
      
    string intermediate; 
      
    while(getline(check1, intermediate, ' ')) 
    { 
        tokens.push_back(intermediate);
        C++; 
    } 
    return C;
} 

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
    /* if(flag == 1)
    {
        cout<<"Inserted in ScopeTable # "<<this->getscope_id()<<" at position "<<t<<" , "<<pos<<" !!! "<<endl;
        cout<<"Insertion Successful !!!"<<endl;
    }*/
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
    //cout<<"ScopeTable # "<<this->getscope_id()<<endl;
    fprintf(logout,"ScopeTable # %d\n",this->getscope_id());
    for(int i=0; i<this->getlength() ; i++)
    {
        SymbolInfo* temp=symbol[i];
        //cout<<i<<" --> ";
        fprintf(logout,"%d --> ",i);
        if(temp == NULL)
        {
            //cout<<endl;
            fprintf(logout,"\n");
        }
        else
        {
            while(temp != NULL)
            {
                //cout<<" < "<<temp->getName()<<" : "<<temp->getType()<<" > ";
                //cout<<"yes";
                fprintf(logout,"< %s : %s >",temp->getName().c_str(),temp->getType().c_str());
                temp=temp->next;
            }
            //cout<<endl;
            fprintf(logout,"\n");
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

ScopeTable scopetable(10) ;

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n




%%

{NEWLINE} {line_count++;}

{WHITESPACE} {}

"if"	{
			fprintf(tokenout,"<IF>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE>");
			fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
		}

"for"   {
			fprintf(tokenout,"<FOR>");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
	    }

"while" {
			fprintf(tokenout,"<WHILE>");
			fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		}

"do"	{
			fprintf(tokenout,"<DO>");
			fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);

		}

"break"	{
			fprintf(tokenout,"<BREAK>");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		}

"int"	{
			fprintf(tokenout,"<INT>");
			fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		}

"char"	{
			fprintf(tokenout,"<CHAR>");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		}

"float" {
			fprintf(tokenout,"<FLOAT>");
			fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
		}

"double" {
			fprintf(tokenout,"<DOUBLE>");
			fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		 }

"void"  {
			fprintf(tokenout,"<VOID>");
			fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
		}

"return" {
			fprintf(tokenout,"<RETURN>");
			fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
		 }

"switch" {
			fprintf(tokenout,"<SWITCH>");
			fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		 }

"case" {
            fprintf(tokenout,"<CASE>");
			fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
	   }

"continue" {
            fprintf(tokenout,"<CONTINUE>");
			fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
           }

"default" {
            fprintf(tokenout,"<DEFAULT>");
			fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
          }

"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"ADDOP");
            //scopetable.Print();
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}
		
"*" |
"/" |
"%"  {

            fprintf(tokenout,"<MULOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"MULOP");

        }

"++" |
"--"   {
            fprintf(tokenout,"<INCOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"ADDOP");

        }

"<" | 
"<=" | 
">" | 
">=" | 
"==" | 
"!=" {
            fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"RELOP");

}
"&&" | 
"||" {
            fprintf(tokenout,"<LOGICOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"LOGICOP");

}

"&" | 
"|" |
"^" | 
"<<" |
">>" {
            fprintf(tokenout,"<BITOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"BITOP");

}

"!" {
            fprintf(tokenout,"<NOT,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"NOT");

}
"(" {
            fprintf(tokenout,"<LPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"LPAREN");

}
")" {
            fprintf(tokenout,"<RPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"RPAREN");
}
"{" {
            fprintf(tokenout,"<LCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"LCURL");
}
"}" {
            fprintf(tokenout,"<RCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"RCURL");
}
"[" {
            fprintf(tokenout,"<LTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"LTHIRD");
}
"]" {
            fprintf(tokenout,"<RTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"RTHIRD");
}
"," {
            fprintf(tokenout,"<COMMA,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"COMMA");
}
";" {
            fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
            //scopetable.Insert(string(yytext),"SEMICOLON");
}
{LETTER}+({DIGIT}*("\_")*{LETTER}*)* |
("\_")+(("\_")*{LETTER}*{DIGIT}*)*   {
            fprintf(tokenout,"<ID,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
}

{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
				//insert in symbol table and print symbol table content(only non empty buckets)
				scopetable.Insert(string(yytext),"CONST_INT");
                scopetable.Print();
			}
	
{DIGIT}*"\."{DIGIT}+ |
{DIGIT}*"\."{DIGIT}+"E-"{DIGIT}* |
{DIGIT}+"E-"{DIGIT}* |
{DIGIT}*"\."{DIGIT}+"E"{DIGIT}* |
{DIGIT}+"E"{DIGIT}* {
                fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_FLOAT");
                scopetable.Print();
} 
"\'"[^'\n\r\\]"\'" {
                fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print();
}
"\'""\\n""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\n'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print(); 
}
"\'""\\t""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\t'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print(); 
}
"\'""\\\\""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\\'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print(); 

}
"\'""\'""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\''>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print(); 
}
"\'""\\a""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\a'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print(); 
}
"\'""\\r""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\r'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print(); 
}
"\'""\\f""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\f'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print(); 
}
"\'""\\b""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\b'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print(); 
}
"\'""\\v""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\v'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print();
}
"\'""\\0""\'" {
                fprintf(tokenout,"<CONST_CHAR,'\\0'>");
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                scopetable.Insert(string(yytext),"CONST_CHAR");
                scopetable.Print();
}


"\""([^"\n\r])*"\"" |
"\""(([^"\n\r])*("\\"{NEWLINE})?)*"\"" {
                fprintf(tokenout,"<STRING,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",line_count,yytext);
                line_count += multiLINECOUNT(yytext);
}

"\/\/".* |
("\/\*"([^*]|[\r\n]|("\*"+([^\*\/]|[\r\n])))*"\*"+"\/") | 
"\/\/"(([^\n\r])*("\\"{NEWLINE})?)* {
                fprintf(logout,"Line no %d : TOKEN <COMMENT> Lexeme %s found\n",line_count,yytext);
                line_count += multiLINECOUNT(yytext);
}

{DIGIT}*"\."({DIGIT}*"\."{DIGIT}*)+ {
                fprintf(logout,"Error at Line no %d : Too many Decimal Point %s\n",line_count,yytext);
                count_error++;
}

{DIGIT}+"E"({DIGIT}*"\."{DIGIT}*)+ {
                fprintf(logout,"Error at Line no %d : Ill Performed Number %s\n",line_count,yytext);
                count_error++;
}
{DIGIT}+({DIGIT}*{LETTER}+)+ {
                fprintf(logout,"Error at Line no %d : Invalid Suffix on Numeric Constant or Invalid Prefix on identifier for character %s\n",line_count,yytext);
                count_error++;
}

"\'"[^'\n\r\\][^'\n\r\\]+"\'" {
                fprintf(logout,"Error at Line no %d : Multi Character Constant Error %s\n",line_count,yytext);
                count_error++;
}

"\'"[^'\n\r][^'\n\r]+ |
[^'\n\r][^'\n\r]+"\'" |
"\\" {
                fprintf(logout,"Error at the Line no %d : Unfinished Character %s\n",line_count,yytext);
                count_error++;
}

"\""([^"\n\r])* |
"\""(([^"\n\r])*("\\"{NEWLINE})?)* {
                fprintf(logout,"Error at the Line no %d : Unterminated String %s\n",line_count,yytext);
                count_error++;
}

"\/\*"([^*]|[\r\n]|("\*"+([^\*\/]|[\r\n])))* {
                fprintf(logout,"Error at the Line no %d : Unterminated Comment %s\n",line_count,yytext);
                count_error++;
}


%%



int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	logout= fopen("1605108_log.txt","w");
	tokenout= fopen("1605108_token.txt","w");

	yyin= fin;
	yylex();
    fprintf(logout,"Total Lines : %d\n",line_count);
    fprintf(logout,"Total Errors : %d",count_error);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
