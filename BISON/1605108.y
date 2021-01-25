%{
#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "SymbolTable.h"


using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp;
FILE *error=fopen("error.txt","w");
FILE *logout= fopen("logout.txt","w");
int line_count=1;
int count_error=0;


SymbolTable *table = new SymbolTable(6);

vector<SymbolInfo*>decList;
vector<SymbolInfo*>para_list;
vector<SymbolInfo*>arg_list;


void yyerror(char *s)
{
	fprintf(stderr,"Line no %d : %s\n",line_count,s);
}


%}


%token IF BITOP ELSE FOR WHILE DO SWITCH DEFAULT BREAK CHAR DOUBLE CASE CONTINUE ADDOP ASSIGNOP COMMA CONST_FLOAT CONST_INT CONST_CHAR STRING COMMENT DECOP FLOAT ID VOID INT INCOP LPAREN RPAREN LCURL RCURL RELOP RETURN LOGICOP LTHIRD RTHIRD MULOP NOT SEMICOLON PRINTLN
%left RELOP LOGICOP BITOP 
%left ADDOP 
%left MULOP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%union
{
        SymbolInfo* SymbolInfoValue;
		vector<string>*s;
}
%type <s>start



%%

start : program { }
	  ;

program : program unit  { 	$<SymbolInfoValue>$=new SymbolInfo(); 
							$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+$<SymbolInfoValue>2->getName());
							fprintf(logout,"Line at %d : program : program unit\n",line_count);
							fprintf(logout,"%s %s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str()); 
						}
				| unit  { 	$<SymbolInfoValue>$=new SymbolInfo();
							$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName());
							fprintf(logout,"Line at %d : program : unit\n",line_count);
							fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
						}
		;
	
unit   : var_declaration  {	$<SymbolInfoValue>$=new SymbolInfo();
							$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"\n");
							fprintf(logout,"Line at %d : unit : var_declaration\n",line_count);
							fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str()); 
						}
       |func_declaration {
		  				    $<SymbolInfoValue>$=new SymbolInfo(); 
						    $<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"\n");
						    fprintf(logout,"Line at %d : unit->func_declaration\n",line_count);
	 					    fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str()); 
	  					}
	   |func_definition { 
		  				    $<SymbolInfoValue>$ = new SymbolInfo();
						    $<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"\n");		
							fprintf(logout,"Line at %d : unit->func_definition\n",line_count);
	 					    fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
	  				   }
    
       ;

func_declaration : type_specifier ID  LPAREN  parameter_list RPAREN SEMICOLON {

			$<SymbolInfoValue>$=new SymbolInfo(); 
			fprintf(logout,"Line at %d : func_declaration->type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n",line_count);
			fprintf(logout,"%s %s(%s);\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str(),$<SymbolInfoValue>4->getName().c_str());
			SymbolInfo *s=table->Lookup($<SymbolInfoValue>2->getName());
			if(s==0)
			{
				table->Insert($<SymbolInfoValue>2->getName(),"ID","Function");
				s=table->Lookup($<SymbolInfoValue>2->getName());
				s->setIsFunc();
				for(int i=0;i<para_list.size();i++)
				{
					s->getIsFunc()->add_number_of_parameter(para_list[i]->getName(),para_list[i]->getDecType());
				}
					para_list.clear();
					s->getIsFunc()->set_return_type($<SymbolInfoValue>1->getName());
			} 
			else
			{
				int num=s->getIsFunc()->get_number_of_parameter();
				if(num == para_list.size())
				{
					vector<string>para_type=s->getIsFunc()->get_paratype();
					for(int i=0;i<para_list.size();i++)
					{
						if(para_list[i]->getDecType()!=para_type[i])
						{
							count_error++;
							fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
							break;
						}	
					}
					if(s->getIsFunc()->get_return_type()!=$<SymbolInfoValue>1->getName())
					{
						count_error++;
						fprintf(error,"Error at Line No.%d : Return Type Mismatch \n",line_count);
					}
					para_list.clear();
					
				} 
				else
				{
					count_error++;
					fprintf(error,"Error at Line No. %d : Invalid number of parameters \n",line_count);
				}
			}
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+" "+$<SymbolInfoValue>2->getName()+"("+$<SymbolInfoValue>4->getName()+");");
}
		|type_specifier ID LPAREN RPAREN SEMICOLON {

		$<SymbolInfoValue>$=new SymbolInfo(); 
		fprintf(logout,"Line at %d : func_declaration->type_specifier ID LPAREN RPAREN SEMICOLON\n",line_count);
		fprintf(logout,"%s %s();\n\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str());
		SymbolInfo *s=table->Lookup($<SymbolInfoValue>2->getName());
		if(s!=0)
		{
			if(s->getIsFunc()->get_number_of_parameter()!=0)
			{
				count_error++;
				fprintf(error,"Error at Line No.% :  Invalid number of parameters \n",line_count);
			}
			else if(s->getIsFunc()->get_return_type()!=$<SymbolInfoValue>1->getName())
			{
				count_error++;
				fprintf(error,"Error at Line No.%d : Return Type Mismatch \n",line_count);
			}
		}
		else
		{
			table->Insert($<SymbolInfoValue>2->getName(),"ID","Function");
			s=table->Lookup($<SymbolInfoValue>2->getName());
			s->setIsFunc();
			s->getIsFunc()->set_return_type($<SymbolInfoValue>1->getName());
		}
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+" "+$<SymbolInfoValue>2->getName()+"();");
}
		;

func_definition : type_specifier ID  LPAREN  parameter_list RPAREN {
		$<SymbolInfoValue>$=new SymbolInfo(); 
		SymbolInfo *s=table->Lookup($<SymbolInfoValue>2->getName()); 
		if(s!=0)
		{ 
			if(s->getIsFunc()->get_isdefined()!=0)
			{
				count_error++;
				fprintf(error,"Error at Line No.%d :  Multiple defination of function %s\n",line_count,$<SymbolInfoValue>2->getName().c_str());						
			}
			else
			{
				int num=s->getIsFunc()->get_number_of_parameter();
				if(num==para_list.size())
				{
					vector<string>para_type=s->getIsFunc()->get_paratype();
					for(int i=0;i<para_list.size();i++)
					{
						if(para_list[i]->getDecType()!=para_type[i])
						{
							count_error++;
							fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
							break;
						}
					}
					if(s->getIsFunc()->get_return_type()!=$<SymbolInfoValue>1->getName())
					{
						count_error++;
						fprintf(error,"Error at Line No.%d : Return Type Mismatch1 \n",line_count);
					}	
				} 
				else
				{	
					count_error++;
					fprintf(error,"Error at Line No.%d : Invalid number of parameters \n",line_count);
				}
				s->getIsFunc()->set_isdefined();		
			}
		}
		else
		{ 
			table->Insert($<SymbolInfoValue>2->getName(),"ID","Function");
			s=table->Lookup($<SymbolInfoValue>2->getName());
			s->setIsFunc();
			s->getIsFunc()->set_isdefined();
			for(int i=0;i<para_list.size();i++)
			{
				s->getIsFunc()->add_number_of_parameter(para_list[i]->getName(),para_list[i]->getDecType());
			}
			s->getIsFunc()->set_return_type($<SymbolInfoValue>1->getName());
		}

} compound_statement 
  {
	fprintf(logout,"Line at %d : func_definition->type_specifier ID LPAREN parameter_list RPAREN compound_statement \n",line_count);
	fprintf(logout,"%s %s(%s) %s \n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str(),$<SymbolInfoValue>4->getName().c_str(),$<SymbolInfoValue>7->getName().c_str());
	$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+" "+$<SymbolInfoValue>2->getName()+"("+$<SymbolInfoValue>4->getName()+")"+$<SymbolInfoValue>7->getName());
  }
		| type_specifier ID LPAREN RPAREN { 

		$<SymbolInfoValue>$=new SymbolInfo();
		SymbolInfo *s=table->Lookup($<SymbolInfoValue>2->getName());
		if(s==0)
		{
			table->Insert($<SymbolInfoValue>2->getName(),"ID","Function");
			s=table->Lookup($<SymbolInfoValue>2->getName());
			s->setIsFunc();
			s->getIsFunc()->set_isdefined();
			s->getIsFunc()->set_return_type($<SymbolInfoValue>1->getName());
		}
		else if(s->getIsFunc()->get_isdefined()==0)
		{
			if(s->getIsFunc()->get_return_type()!=$<SymbolInfoValue>1->getName())
			{
				count_error++;
				fprintf(error,"Error at Line No.%d : Return Type Mismatch \n",line_count);
			}
			if(s->getIsFunc()->get_number_of_parameter()!=0)
			{
				count_error++;
				fprintf(error,"Error at Line No.%d : Invalid number of parameters \n",line_count);
			}
			s->getIsFunc()->set_isdefined();
		}
		else
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Multiple defination of function %s\n",line_count,$<SymbolInfoValue>2->getName().c_str());
		}									
		$<SymbolInfoValue>1->setName($<SymbolInfoValue>1->getName()+" "+$<SymbolInfoValue>2->getName()+"()");
} compound_statement 
  {
		fprintf(logout,"Line at %d : func_definition->type_specifier ID LPAREN RPAREN compound_statement\n",line_count);
		fprintf(logout,"%s %s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>6->getName().c_str());
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+$<SymbolInfoValue>6->getName());
  }
 		;
parameter_list  : parameter_list COMMA type_specifier ID {
	$<SymbolInfoValue>$=new SymbolInfo(); 
	fprintf(logout,"Line at %d : parameter_list->parameter_list COMMA type_specifier ID\n",line_count);
	fprintf(logout,"%s,%s %s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str(),$<SymbolInfoValue>4->getName().c_str());
	para_list.push_back(new SymbolInfo($<SymbolInfoValue>4->getName(),"ID",$<SymbolInfoValue>3->getName()));
	$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+","+$<SymbolInfoValue>3->getName()+" "+$<SymbolInfoValue>4->getName());
}
		| parameter_list COMMA type_specifier {
			$<SymbolInfoValue>$=new SymbolInfo(); 
			fprintf(logout,"Line at %d : parameter_list->parameter_list COMMA type_specifier\n",line_count);
			fprintf(logout,"%s,%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
			para_list.push_back(new SymbolInfo("","ID",$<SymbolInfoValue>3->getName()));
			$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+","+$<SymbolInfoValue>3->getName());
}
 		| type_specifier ID {
			$<SymbolInfoValue>$=new SymbolInfo(); 
			fprintf(logout,"Line at %d : parameter_list->type_specifier ID\n",line_count);
		 	fprintf(logout,"%s %s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str());
			para_list.push_back(new SymbolInfo($<SymbolInfoValue>2->getName(),"ID",$<SymbolInfoValue>1->getName()));
		 	$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+" "+$<SymbolInfoValue>2->getName());
}
		| type_specifier {
			$<SymbolInfoValue>$=new SymbolInfo(); 
			fprintf(logout,"Line at %d : parameter_list->type_specifier\n",line_count);
			fprintf(logout,"%s \n",$<SymbolInfoValue>1->getName().c_str());
			para_list.push_back(new SymbolInfo("","ID",$<SymbolInfoValue>1->getName()));
			$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+" ");
}
 		;

compound_statement : LCURL {
			table->EnterScope();
			for(int i=0;i<para_list.size();i++)
			{
				table->Insert(para_list[i]->getName(),"ID",para_list[i]->getDecType());
			}
			para_list.clear();
	} statements RCURL {
		$<SymbolInfoValue>$=new SymbolInfo(); 
		$<SymbolInfoValue>$->setName("{\n"+$<SymbolInfoValue>3->getName()+"\n}");
		fprintf(logout,"Line at %d : compound_statement->LCURL statements RCURL\n",line_count);
		fprintf(logout,"{%s}\n",$<SymbolInfoValue>3->getName().c_str());
		table->PrintAllScopeTable();
		table->ExitScope();
	}
 		| LCURL RCURL {
		table->EnterScope();
		for(int i=0;i<para_list.size();i++)
		table->Insert(para_list[i]->getName(),"ID",para_list[i]->getDecType());
		para_list.clear();
		$<SymbolInfoValue>$=new SymbolInfo(); 
		$<SymbolInfoValue>$->setName("{}");
		fprintf(logout,"Line at %d : compound_statement->LCURL RCURL\n",line_count);
		fprintf(logout,"{}\n");
		table->PrintAllScopeTable();
		table->ExitScope();
}
 		;

var_declaration : type_specifier declaration_list SEMICOLON { 
						$<SymbolInfoValue>$ = new SymbolInfo(); 
						fprintf(logout,"Line at %d : var_declaration->type_specifier declaration_list SEMICOLON\n",line_count);
						fprintf(logout,"%s %s;\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str());
						if($<SymbolInfoValue>1->getName() == "void ")
						{
							count_error++;
							fprintf(error,"Error at Line No. %d : Type specifier can not be void \n",line_count);		
						}
						else
						{
							for(int i=0;i<decList.size();i++)
							{
								if(table->LookupInCurrent(decList[i]->getName()))
								{
									count_error++;
									fprintf(error,"Error at Line No. %d : Multiple Declaration of %s \n",line_count,decList[i]->getName().c_str());
									continue;
								}
								else if(decList[i]->getType() == "mat")
								{
									decList[i]->setType(decList[i]->getType().substr(0,decList[i]->getType().size()));
									table->Insert(decList[i]->getName(),decList[i]->getType(),$<SymbolInfoValue>1->getName()+"array");
								}
								else if(decList[i]->getType() == "ID")
								{	
									table->Insert(decList[i]->getName(),decList[i]->getType(),$<SymbolInfoValue>1->getName());
								}
							}
							decList.clear();
							$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+" "+$<SymbolInfoValue>2->getName()+";");
   						}
}
 		;

type_specifier	: INT   {
						$<SymbolInfoValue>$=new SymbolInfo(); 
						$<SymbolInfoValue>$->setName("int ");
						fprintf(logout,"\nAt Line no %d \nint\n",line_count); 
 						}
 				| FLOAT { 
						$<SymbolInfoValue>$=new SymbolInfo();
						$<SymbolInfoValue>$->setName("float "); 
						fprintf(logout,"\nAt Line no %d \nint\n",line_count); 
						}
 				| VOID  { 
						$<SymbolInfoValue>$=new SymbolInfo(); 
						$<SymbolInfoValue>$->setName("void "); 
						fprintf(logout,"\nAt Line no %d \nint\n",line_count); 
						}
 		;
 		
declaration_list : declaration_list COMMA ID    { 
				$<SymbolInfoValue>$=new SymbolInfo(); 
				fprintf(logout,"Line at %d : declaration_list->declaration_list COMMA ID\n",line_count);
				fprintf(logout,"%s,%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
				decList.push_back(new SymbolInfo($<SymbolInfoValue>3->getName(),"ID"));
				$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+","+$<SymbolInfoValue>3->getName());
}
 	   | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD   { 
			    $<SymbolInfoValue>$=new SymbolInfo(); 
				$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+","+$<SymbolInfoValue>3->getName()+"["+$<SymbolInfoValue>5->getName()+"]");
				fprintf(logout,"Line at %d : declaration_list->declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n",line_count);
		   		fprintf(logout,"%s,%s[%s]\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str(),$<SymbolInfoValue>5->getName().c_str());
				decList.push_back(new SymbolInfo($<SymbolInfoValue>3->getName(),"mat"));
}
 	   | ID  { 
			$<SymbolInfoValue>$=new SymbolInfo();
			$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName());
			fprintf(logout,"Line at %d : declaration_list->ID\n",line_count);
		    fprintf(logout,"%s\n\n",$<SymbolInfoValue>1->getName().c_str());
		   	decList.push_back(new SymbolInfo($<SymbolInfoValue>1->getName(),"ID"));
}
 	   | ID LTHIRD CONST_INT RTHIRD  { 
		 	$<SymbolInfoValue>$=new SymbolInfo();
			fprintf(logout,"Line at %d : declaration_list->ID LTHIRD CONST_INT RTHIRD\n",line_count);
		    fprintf(logout,"%s[%s]\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
		   	decList.push_back(new SymbolInfo($<SymbolInfoValue>1->getName(),"mat"));
			$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"["+$<SymbolInfoValue>3->getName()+"]");
}
 	   ;

statements : statement {
		$<SymbolInfoValue>$=new SymbolInfo(); 
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName());
		fprintf(logout,"Line at %d : statements->statement\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str()); 
}
	   | statements statement {
		 $<SymbolInfoValue>$=new SymbolInfo(); 
		 $<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"\n"+$<SymbolInfoValue>2->getName()); 
		 fprintf(logout,"Line at %d : statements->statements statement\n",line_count);
	   	 fprintf(logout,"%s %s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str()); 
}
	   ;

statement : var_declaration { 
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		fprintf(logout,"Line at %d : statement->var_declaration\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
}
	   | expression_statement {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		fprintf(logout,"Line at %d : statement->expression_statement\n",line_count);
	  	fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str()); 
}
	   | compound_statement {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		fprintf(logout,"Line at %d : statement->compound_statement\n",line_count);
	  	fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str()); 
}
	   | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : statement->FOR LPAREN expression_statement expression_statement expression RPAREN statement\n",line_count);
	  	fprintf(logout,"for(%s %s %s)\n%s \n",$<SymbolInfoValue>3->getName().c_str(),$<SymbolInfoValue>4->getName().c_str(),$<SymbolInfoValue>5->getName().c_str(),$<SymbolInfoValue>7->getName().c_str());
		if($<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
		}	
		$<SymbolInfoValue>$->setName("for("+$<SymbolInfoValue>3->getName()+$<SymbolInfoValue>4->getName()+$<SymbolInfoValue>5->getName()+")\n"+$<SymbolInfoValue>5->getName()); 
}
		| WHILE LPAREN expression RPAREN statement {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : statement->WHILE LPAREN expression RPAREN statement\n",line_count);
	  	fprintf(logout,"while(%s)\n%s\n",$<SymbolInfoValue>3->getName().c_str(),$<SymbolInfoValue>5->getName().c_str());
		if($<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
		}
		$<SymbolInfoValue>$->setName("while("+$<SymbolInfoValue>3->getName()+")\n"+$<SymbolInfoValue>5->getName()); 
}
	    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : statement->IF LPAREN expression RPAREN statement\n\n",line_count);
	  	fprintf(logout,"if(%s)\n%s\n",$<SymbolInfoValue>3->getName().c_str(),$<SymbolInfoValue>5->getName().c_str());
		if($<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
		}
		$<SymbolInfoValue>$->setName("if("+$<SymbolInfoValue>3->getName()+")\n"+$<SymbolInfoValue>5->getName()); 
}
	   | IF LPAREN expression RPAREN statement ELSE statement {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : statement->IF LPAREN expression RPAREN statement ELSE statement\n",line_count);
	  	fprintf(logout,"if(%s)\n%s\n else \n %s\n",$<SymbolInfoValue>3->getName().c_str(),$<SymbolInfoValue>5->getName().c_str(),$<SymbolInfoValue>7->getName().c_str());
		if($<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
		}	
		$<SymbolInfoValue>$->setName("if("+$<SymbolInfoValue>3->getName()+")\n"+$<SymbolInfoValue>5->getName()+" else \n"+$<SymbolInfoValue>7->getName()); 
}
	   | PRINTLN LPAREN ID RPAREN SEMICOLON {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName("\n("+$<SymbolInfoValue>3->getName()+")"); 
		fprintf(logout,"Line at %d : statement->PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);
	  	fprintf(logout,"\n (%s);\n\n",$<SymbolInfoValue>3->getName().c_str());
}
	   | RETURN expression SEMICOLON {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : statement->RETURN expression SEMICOLON\n",line_count);
	  	fprintf(logout,"return %s;\n",$<SymbolInfoValue>2->getName().c_str());
		if($<SymbolInfoValue>2->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d :  Type Mismatch \n",line_count);
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		$<SymbolInfoValue>$->setName("return "+$<SymbolInfoValue>2->getName()+";"); 
}
	   ;

expression_statement 	: SEMICOLON	{
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName(";"); 
		fprintf(logout,"Line at %d : expression_statement->SEMICOLON\n",line_count);
		fprintf(logout,";\n"); 
}
		| expression SEMICOLON {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+";");
		fprintf(logout,"Line at %d : expression_statement->expression SEMICOLON\n",line_count);
		fprintf(logout,"%s;\n",$<SymbolInfoValue>1->getName().c_str());
}
	  ;

variable : ID 	{
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : variable->ID\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
		if(table->Lookup($<SymbolInfoValue>1->getName())!=0)
		{
			$<SymbolInfoValue>$->setDecType(table->Lookup($<SymbolInfoValue>1->getName())->getDecType());
			
		}
		else if(table->Lookup($<SymbolInfoValue>1->getName())==0)
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Undeclared Variable : %s \n",line_count,$<SymbolInfoValue>1->getName().c_str());
		}
		else if(table->Lookup($<SymbolInfoValue>1->getName())->getDecType()=="int array")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Not array : %s \n",line_count,$<SymbolInfoValue>1->getName().c_str());
		} 
		else if(table->Lookup($<SymbolInfoValue>1->getName())->getDecType()=="float array")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Not array : %s \n",line_count,$<SymbolInfoValue>1->getName().c_str());
		}
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 	
}
	   | ID LTHIRD expression RTHIRD  {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : variable->ID LTHIRD expression RTHIRD\n",line_count);
	 	fprintf(logout,"%s[%s]\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
		if(table->Lookup($<SymbolInfoValue>1->getName())!=0)
		{
			if(table->Lookup($<SymbolInfoValue>1->getName())->getDecType()=="float array")
			{
				$<SymbolInfoValue>1->setDecType("float ");
			}
			else if(table->Lookup($<SymbolInfoValue>1->getName())->getDecType()=="int array")
			{
				$<SymbolInfoValue>1->setDecType("int ");
				
			}
			else if(table->Lookup($<SymbolInfoValue>1->getName())->getDecType()!="int array" && table->Lookup($<SymbolInfoValue>1->getName())->getDecType()!="float array")
			{
				count_error++;
				
				fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);	
			}		
			$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType()); 	
		}
		if($<SymbolInfoValue>3->getDecType()=="float ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Non-integer Array Index \n",line_count);
		}
		if($<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Non-integer Array Index \n",line_count);
		}
		if(table->Lookup($<SymbolInfoValue>1->getName())==0)
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Undeclared Variable : %s \n",line_count,$<SymbolInfoValue>1->getName().c_str());
		}
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"["+$<SymbolInfoValue>3->getName()+"]");  
}
	  ;

expression : logic_expression	{
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType()); 
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		fprintf(logout,"Line at %d : expression->logic_expression\n",line_count);
 		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
}
	   | variable ASSIGNOP logic_expression {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : expression->variable ASSIGNOP logic_expression\n",line_count);
		
	   	fprintf(logout,"%s=%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
		   
		if($<SymbolInfoValue>3->getDecType()=="void ")
		{
			$<SymbolInfoValue>$->setDecType("int "); 
			count_error++;
			
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
		}
		else if(table->Lookup($<SymbolInfoValue>1->getName())!=0) 
		{
			//fprintf(error,"%s %s",table->Lookup($<SymbolInfoValue>1->getName())->getDecType().c_str(),$<SymbolInfoValue>3->getDecType().c_str());
			
			if(table->Lookup($<SymbolInfoValue>1->getName())->getDecType()!=$<SymbolInfoValue>3->getDecType())
			{
				//fprintf(error,"%s %s",table->Lookup($<SymbolInfoValue>1->getName())->getDecType().c_str(),$<SymbolInfoValue>3->getDecType().c_str());
				count_error++;
				fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
			}
		}
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"="+$<SymbolInfoValue>3->getName());
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType()); 
}
	   ;

logic_expression : rel_expression 	{
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType()); 
		
		fprintf(logout,"Line at %d : logic_expression->rel_expression\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
}
		| rel_expression LOGICOP rel_expression {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : logic_expression->rel_expression LOGICOP rel_expression\n",line_count);
		fprintf(logout,"%s%s%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
		if($<SymbolInfoValue>1->getDecType()=="void ")
		{
			$<SymbolInfoValue>$->setDecType("int "); 
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
		}
		if($<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
			$<SymbolInfoValue>$->setDecType("int ");
		}
		$<SymbolInfoValue>$->setDecType("int "); 
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+$<SymbolInfoValue>2->getName()+$<SymbolInfoValue>3->getName());  
}
		 ;

rel_expression	: simple_expression {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType());  
		fprintf(logout,"Line at %d : rel_expression->simple_expression\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
}
		| simple_expression RELOP simple_expression	 {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : rel_expression->simple_expression RELOP simple_expression\n",line_count);
		fprintf(logout,"%s%s%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
		if($<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		if($<SymbolInfoValue>1->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		$<SymbolInfoValue>$->setDecType("int "); 	
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+$<SymbolInfoValue>2->getName()+$<SymbolInfoValue>3->getName());  
}
		;

simple_expression : term {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName());  
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType());
		fprintf(logout,"Line at %d : simple_expression->term\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
}
		| simple_expression ADDOP term {
		$<SymbolInfoValue>$=new SymbolInfo(); 
		fprintf(logout,"Line at %d : simple_expression->simple_expression ADDOP term\n",line_count);
		fprintf(logout,"%s%s%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
		if($<SymbolInfoValue>1->getDecType()=="int " ||$<SymbolInfoValue>3->getDecType()=="int ")
		{	
			$<SymbolInfoValue>$->setDecType("int ");
			
		}
		if($<SymbolInfoValue>1->getDecType()=="float " ||$<SymbolInfoValue>3->getDecType()=="float ")
		{	
			$<SymbolInfoValue>$->setDecType("float ");
		}
		if($<SymbolInfoValue>1->getDecType()=="void "||$<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
			
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+$<SymbolInfoValue>2->getName()+$<SymbolInfoValue>3->getName());  
}
		;

term :	unary_expression  {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName());
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType()); 	
		fprintf(logout,"Line at %d : term->unary_expression\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());  
}
     	|  term MULOP unary_expression {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : term->term MULOP unary_expression\n",line_count);
	 	fprintf(logout,"%s%s%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
		if($<SymbolInfoValue>1->getDecType()=="void "||$<SymbolInfoValue>3->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		else if($<SymbolInfoValue>2->getName()=="/")
		{
			if($<SymbolInfoValue>1->getDecType()=="int " && $<SymbolInfoValue>3->getDecType()=="int ")
			{
				$<SymbolInfoValue>$->setDecType("int "); 						
			}
			else if($<SymbolInfoValue>1->getDecType()=="float " && $<SymbolInfoValue>3->getDecType()=="float ")
			{
				$<SymbolInfoValue>$->setDecType("float ");
			} 
			else if($<SymbolInfoValue>1->getDecType()=="void "||$<SymbolInfoValue>3->getDecType()=="void ")
			{
				count_error++;
				fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
				$<SymbolInfoValue>$->setDecType("int "); 
			}
			else
			{
				if($<SymbolInfoValue>1->getDecType()=="void "||$<SymbolInfoValue>3->getDecType()=="void ")
				{
					count_error++;
					fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
					$<SymbolInfoValue>$->setDecType("int "); 
				} 
				else if($<SymbolInfoValue>1->getDecType()=="int " || $<SymbolInfoValue>3->getDecType()=="int ")
				{	
					$<SymbolInfoValue>$->setDecType("int "); 
				}
				else if($<SymbolInfoValue>1->getDecType()=="float " || $<SymbolInfoValue>3->getDecType()=="float ")
				{
					$<SymbolInfoValue>$->setDecType("float ");
				}
			}
		}
		else if($<SymbolInfoValue>2->getName()=="%")
		{
			if($<SymbolInfoValue>1->getDecType()!="int " ||$<SymbolInfoValue>3->getDecType()!="int ")
			{
				count_error++;
				fprintf(error,"Error at Line No.%d : Integer operand on modulus operator\n",line_count);
			} 
			$<SymbolInfoValue>$->setDecType("int "); 	
		}
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+$<SymbolInfoValue>2->getName()+$<SymbolInfoValue>3->getName());	
}
     ;

unary_expression : ADDOP unary_expression  {
		$<SymbolInfoValue>$=new SymbolInfo(); 
		fprintf(logout,"Line at %d : unary_expression->ADDOP unary_expression\n",line_count);
		fprintf(logout,"%s%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>2->getName().c_str());
		if($<SymbolInfoValue>2->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		else if($<SymbolInfoValue>2->getDecType()=="int ") 
		{	
			$<SymbolInfoValue>$->setDecType("int ");
		}
		else if($<SymbolInfoValue>2->getDecType()=="float ") 
		{	
			$<SymbolInfoValue>$->setDecType("float ");
		}	
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+$<SymbolInfoValue>2->getName()); 										
}
		| NOT unary_expression {
		$<SymbolInfoValue>$=new SymbolInfo();
		fprintf(logout,"Line at %d : unary_expression->NOT unary_expression\n",line_count);
		fprintf(logout,"!%s\n",$<SymbolInfoValue>2->getName().c_str()); 
		if($<SymbolInfoValue>2->getDecType()=="void ")
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		else 
		{		
			$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>2->getDecType()); 
		} 
		$<SymbolInfoValue>$->setName("!"+$<SymbolInfoValue>2->getName()); 
}
		| factor {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType()); 
		fprintf(logout,"Line at %d : unary_expression->factor\n",line_count);
		
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str()); 		
}
		 ;

factor	: variable { 
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType()); 
		fprintf(logout,"Line at %d : factor->variable\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
}
		| LPAREN expression RPAREN {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName("("+$<SymbolInfoValue>2->getName()+")");
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>2->getDecType()); 
		fprintf(logout,"Line at %d : factor->LPAREN expression RPAREN\n",line_count);
		fprintf(logout,"(%s)\n",$<SymbolInfoValue>2->getName().c_str());  
}
		| ID LPAREN argument_list RPAREN {
		$<SymbolInfoValue>$=new SymbolInfo(); 
		fprintf(logout,"Line at %d : factor->ID LPAREN argument_list RPAREN\n",line_count);
		fprintf(logout,"%s(%s)\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
		SymbolInfo* s=table->Lookup($<SymbolInfoValue>1->getName());
		if(s->getIsFunc()==0)
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Not A Function \n",line_count);
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		else if(s==0)
		{
			count_error++;
			fprintf(error,"Error at Line No.%d : Undefined Function \n",line_count);
			$<SymbolInfoValue>$->setDecType("int "); 
		}
		else 
		{
			int num=s->getIsFunc()->get_number_of_parameter();
			$<SymbolInfoValue>$->setDecType(s->getIsFunc()->get_return_type());
			if(num!=arg_list.size())
			{
				count_error++;
				fprintf(error,"Error at Line No.%d : Invalid number of arguments \n",line_count);
			}
			else if(s->getIsFunc()->get_isdefined()==0)
			{
				count_error++;
				fprintf(error,"Error at Line No.%d : Undeclared Function \n",line_count);
			}
			else
			{	
				vector<string>para_list=s->getIsFunc()->get_paralist();
				vector<string>para_type=s->getIsFunc()->get_paratype();
				for(int i=0;i<arg_list.size();i++)
				{
					if(arg_list[i]->getDecType()!=para_type[i])
					{
						count_error++;
						fprintf(error,"Error at Line No.%d : Type Mismatch \n",line_count);
						break;
					}
				}
			}
		}
		arg_list.clear();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"("+$<SymbolInfoValue>3->getName()+")"); 
}
		| variable INCOP {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"++"); 
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType());
		fprintf(logout,"Line at %d : factor->variable INCOP\n",line_count);
		fprintf(logout,"%s++\n",$<SymbolInfoValue>1->getName().c_str()); 	 
}
		| variable DECOP {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setDecType($<SymbolInfoValue>1->getDecType()); 
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+"--"); 
		fprintf(logout,"Line at %d : factor->variable DECOP\n",line_count);
		fprintf(logout,"%s--\n",$<SymbolInfoValue>1->getName().c_str());
}
		| CONST_INT { 
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		$<SymbolInfoValue>$->setDecType("int ");
		

		fprintf(logout,"Line at %d : factor->CONST_INT\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
}
		| CONST_FLOAT {
		$<SymbolInfoValue>$=new SymbolInfo();
		$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()); 
		$<SymbolInfoValue>$->setDecType("float "); 	
		fprintf(logout,"Line at %d : factor->CONST_FLOAT\n",line_count);
		fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str()); 
}
	;

argument_list   : arguments  {
			    $<SymbolInfoValue>$=new SymbolInfo(); 
				$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName());
				fprintf(logout,"Line at %d : argument_list->arguments\n",line_count);
				fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str());
}
				| 		%empty	{ $<SymbolInfoValue>$=new SymbolInfo(); 
				fprintf(logout,"Line at %d : argument_list-> \n",line_count);$<SymbolInfoValue>$->setName("");
				}
			  ;

arguments : arguments COMMA logic_expression {
			$<SymbolInfoValue>$=new SymbolInfo();
			$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName()+","+$<SymbolInfoValue>3->getName());
			fprintf(logout,"Line at %d : arguments->arguments COMMA logic_expression \n",line_count);
			fprintf(logout,"%s,%s\n",$<SymbolInfoValue>1->getName().c_str(),$<SymbolInfoValue>3->getName().c_str());
			arg_list.push_back($<SymbolInfoValue>3);
}
	      | logic_expression {
			$<SymbolInfoValue>$=new SymbolInfo();
			$<SymbolInfoValue>$->setName($<SymbolInfoValue>1->getName());		
		  	fprintf(logout,"Line at %d : arguments->logic_expression\n",line_count);
		  	fprintf(logout,"%s\n",$<SymbolInfoValue>1->getName().c_str()); 
			arg_list.push_back(new SymbolInfo($<SymbolInfoValue>1->getName(),$<SymbolInfoValue>1->getType(),$<SymbolInfoValue>1->getDecType()));
}
	      ;
%%

int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
	}
	yyin=fp;
	table->EnterScope();
	yyparse();
	fprintf(logout," Symbol Table : \n");
	table->PrintAllScopeTable();
	fprintf(logout,"Total Lines : %d \n",line_count);
	fprintf(logout,"Total Errors : %d \n",count_error);
	fprintf(error,"Total Errors : %d \n",count_error);
	fclose(fp);
	fclose(logout);
	fclose(error);
}
