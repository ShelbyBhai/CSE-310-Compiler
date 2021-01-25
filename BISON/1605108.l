%{
#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>
#include<math.h>
#include<stdio.h>
#include "SymbolInfo.h"
#include "y.tab.h"
//extern vector<SymbolInfo*>para_list;

using namespace std;
extern YYSTYPE yylval;
//extern SymbolTable *table;
extern FILE *error;
extern string currentid;
extern int line_count;
extern int count_error;


void yyerror(char *);


int newLineAscii=10;
char newLineChar=newLineAscii;
string name,type,sub,newLineStr(1,newLineChar),space=" ";


/*string charToStr(int ascii){
	char character=ascii;
	string str(1,character);
	return str;
}

string newLineConverter(string name){
	sub="\\n";
	size_t pos =name.find(sub,0);
	while(pos!=string::npos){
		name=name.replace(pos,2,newLineStr);
		pos =name.find(sub,pos+1);
	}
	return name;
}

/*string lineCountIncrease(string name){
	sub="\n";
	size_t pos =name.find(sub,0);
	while(pos!=string::npos){
		line_count++;
		pos =name.find(sub,pos+1);
	}
	return name;
}*/

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

/*string multiLineConverter(string name){
	sub="\\";
	size_t pos =name.find(sub,0);
	while(pos!=string::npos){
		name=name.replace(pos,2,"	");
		pos =name.find(sub,pos+1);
	}
	return name;
}*/




%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n



%%

{NEWLINE} {line_count++;}
{WHITESPACE} {}



"if"	{	return IF;	}
		
"else"	{	return ELSE;	}


"for"   {	return FOR;	}

"do"	{	return DO; 	}     

"int"	{	return INT;	}    

"float"	{	return FLOAT;	}  

"void"	{	return VOID;	}   

"switch"	{	return SWITCH;	} 

"default"	{	return DEFAULT;}
			

"while"	{	return WHILE;}

"break" {	return BREAK;}
		
"char"  	{	return CHAR;	} 

"double" 	{	return DOUBLE;	}  

"return" 	{	return RETURN;	} 

"case"  	{	return CASE;	} 

"continue"  {	return CONTINUE;	}


"+"		|
"-"		{
			name=yytext;
			type="ADDOP";
			SymbolInfo *s= new  SymbolInfo(name,type);
			yylval.SymbolInfoValue =s;
			return ADDOP;
		}


"*"     |
"/"     |
"%"     {
			name=yytext;
			type="MULOP";
			SymbolInfo *s= new  SymbolInfo(name,type);
			yylval.SymbolInfoValue =s;
			return MULOP;
		} 

"<"     |
"<="    |    
">"     |
">="    |
"=="    |
"!="    {
			name=yytext;
			type="RELOP";
			SymbolInfo *s= new  SymbolInfo(name,type);
			yylval.SymbolInfoValue =s;
			return RELOP;
		}

"="    {	return	ASSIGNOP;	} 

"&&"    |
"||"    {
			name=yytext;
			type="LOGICOP";
			SymbolInfo *s= new  SymbolInfo(name,type);
			yylval.SymbolInfoValue = s;
			return LOGICOP;
		} 

"&"     |
"|"     |
"~"     |
"^"     |
"<<"    |
">>"    {
			name=yytext;
			type="BITOP";
			SymbolInfo *s= new  SymbolInfo(name,type);
			yylval.SymbolInfoValue = s;
			return BITOP;
		}

"!"		{return NOT;}
";" 	{return SEMICOLON;}
"," 	{return COMMA;}
"(" 	{return LPAREN;}
")" 	{return RPAREN;}
"{" 	{return LCURL;}
"}" 	{return RCURL;}
"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}


{DIGIT}+ {		
		name=yytext;
		type="CONST_INT";
		SymbolInfo *s= new SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_INT;
}

{DIGIT}*"\."{DIGIT}+ |
{DIGIT}*"\."{DIGIT}+"E-"{DIGIT}* |
{DIGIT}+"E-"{DIGIT}* |
{DIGIT}*"\."{DIGIT}+"E"{DIGIT}* |
{DIGIT}+"E"{DIGIT}*     {
		name=yytext;
		type="CONST_FLOAT";
		SymbolInfo *s= new SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_FLOAT;
}

{LETTER}+({DIGIT}*("\_")*{LETTER}*)* |
("\_")+(("\_")*{LETTER}*{DIGIT}*)*	{					
		name=yytext;
		type="ID";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return ID;		
}

"\'"[^'\n\r\\]"\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;		
}

"\'""\\n""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}

"\'""\\t""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}

"\'""\\\\""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}
"\'""\'""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}
"\'""\\a""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}
"\'""\\r""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}
"\'""\\f""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}
"\'""\\b""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}
"\'""\\v""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}
"\'""\\0""\'" {
		name=yytext;
		type="CONST_CHAR";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return CONST_CHAR;
}
"\""([^"\n\r])*"\"" |
"\""(([^"\n\r])*("\\"{NEWLINE})?)*"\"" {
		name=yytext;
		type="STRING";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		line_count += multiLINECOUNT(yytext);
		return STRING;
}
"\/\/".* {
		name=yytext;
		type="COMMENT";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		return COMMENT;
}
("\/\*"([^*]|[\r\n]|("\*"+([^\*\/]|[\r\n])))*"\*"+"\/") | 
"\/\/"(([^\n\r])*("\\"{NEWLINE})?)* {
		name=yytext;
		type="COMMENT";
		SymbolInfo *s= new  SymbolInfo(name,type);
		yylval.SymbolInfoValue = s;
		line_count += multiLINECOUNT(yytext);
		return COMMENT;
}
{DIGIT}*"\."({DIGIT}*"\."{DIGIT}*)+ {
                fprintf(error,"Error at Line no %d : Too many Decimal Point %s\n",line_count,yytext);
                count_error++;
}
{DIGIT}+"E"({DIGIT}*"\."{DIGIT}*)+ {
                fprintf(error,"Error at Line no %d : Ill Performed Number %s\n",line_count,yytext);
                count_error++;
}
{DIGIT}+({DIGIT}*{LETTER}+)+ {
                fprintf(error,"Error at Line no %d : Invalid Suffix on Numeric Constant or Invalid Prefix on identifier for character %s\n",line_count,yytext);
                count_error++;
}

"\'"[^'\n\r\\][^'\n\r\\]+"\'" {
                fprintf(error,"Error at Line no %d : Multi Character Constant Error %s\n",line_count,yytext);
                count_error++;
}

"\'"[^'\n\r][^'\n\r]+ |
[^'\n\r][^'\n\r]+"\'" |
"\\" {
                fprintf(error,"Error at the Line no %d : Unfinished Character %s\n",line_count,yytext);
                count_error++;
}

"\""([^"\n\r])* |
"\""(([^"\n\r])*("\\"{NEWLINE})?)* {
                fprintf(error,"Error at the Line no %d : Unterminated String %s\n",line_count,yytext);
                count_error++;
}

"\/\*"([^*]|[\r\n]|("\*"+([^\*\/]|[\r\n])))* {
                fprintf(error,"Error at the Line no %d : Unterminated Comment %s\n",line_count,yytext);
                count_error++;
}
%%

int yywrap(void)
{
	return 1;
}