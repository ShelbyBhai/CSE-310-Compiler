#include<bits/stdc++.h>

using namespace std;

#define NULL_VALUE "-99999"
#define SUCCESS_VALUE "99999"

class ListNode
{
public:
    string item;
    ListNode * next;
};

class LinkedList
{

    ListNode * list;
    int length;

public:
    LinkedList()
    {
        list=0;
        length=0;
    }

    int getLength()
    {
        return length;
    }

    string insertItem(string item)
    {
        ListNode * newNode = new ListNode() ;
        newNode->item = item ;
        newNode->next = list ;
        list = newNode ;
        length++;
        return SUCCESS_VALUE ;
    }

    string deleteItem(string item)
    {
        ListNode *temp, *prev ;
        temp = list ;
        while (temp != 0)
        {
            if (temp->item == item)
                break ;
            prev = temp;
            temp = temp->next ;
        }
        if (temp == 0)
            return NULL_VALUE ;
        if (temp == list)
        {
            list = list->next ;
            length--;
        }
        else
        {
            prev->next = temp->next ;
            length--;
        }
        return SUCCESS_VALUE ;
    }

    ListNode * searchItem(string item)
    {
        ListNode * temp ;
        temp = list ;
        while (temp != 0)
        {
            if (temp->item == item)
                return temp ;
            temp = temp->next ;
        }
        return 0 ;
    }

    void printList()
    {
        if(list==0)
        {
            printf("\n\tThe SinglyList is empty!!!\n");
        }
        ListNode * temp;
        temp = list;
        printf("\n\tThe SinglyList is : \n");
        printf( "----------------------------\n");
        while(temp!=0)
        {
           cout<<temp->item<<"->";
            temp = temp->next;
        }
        printf("NULL\n");
        printf("\nLength: %d\n",length);
    }

    string insertLast(string item)
    {
        if(list==0)
        {
            printf("\n\tNothing inserted in SinglyList!!!!\n");
        }
        else
        {
            ListNode * newNode = new ListNode() ;
            newNode->item=item;
            newNode->next=0;
            ListNode *prev = new ListNode();
            prev=list;
            while (prev->next != NULL)
                prev = prev->next;
            newNode->next=0;
            prev->next=newNode;
            length++;
        }
        return SUCCESS_VALUE;
    }

    string insertAfter(string oldItem, string newItem)
    {
        if(list==0)
        {
            printf("\n\tNothing inserted in SinglyList!!!\n");
        }
        else if (searchItem(oldItem)==0)
        {
            printf("\n\tThis item is not present in the SinglyList\n");
        }
        else
        {
            ListNode * newNode = new ListNode() ;
            newNode->item=newItem;
            newNode->next=0;
            ListNode *prev = new ListNode();
            prev=list;
            while (prev->item != oldItem)
                prev = prev->next;
            newNode->next = prev->next;
            prev->next = newNode;
            length++;
        }
        return SUCCESS_VALUE;
    }

    ListNode * getItemAt(int pos)
    {
        if(pos>=length)
        {
            printf("\n\tInvalid input!!!\n");
            return NULL;
        }
        else
        {
            ListNode *current = new ListNode();
            current=list;
            int counter=0;
            while(counter!=99999)
            {
                if(counter==pos)
                {
                    return current;
                }
                counter++;
                current=current->next;
            }
        }
    }

    string deleteFirst()
    {
        if(list==0)
        {
            printf("\n\tNo item found in the SinglyList!!!\n");
        }
        else
        {
            ListNode *temp=new ListNode();
            temp=list;
            list = list->next ;
            delete temp;
            length--;
        }
        return SUCCESS_VALUE;
    }

    ~LinkedList()
    {
        ListNode * temp ;
        while (list != 0)
        {
            temp=list->next;
            delete list;
            list = temp;
        }
        length=0;
        list=0;
    }
};

class Function
{ 
    LinkedList pList,pType;
    //vector<string>pList;
    //vector<string>pType;
    int number_of_parameter;
    string return_type;
    bool isdefined;
 public:
    inline Function();
    inline void set_return_type(string type);
    inline string get_return_type();
    inline void set_number_of_parameter();
    inline int get_number_of_parameter();
    inline void add_number_of_parameter(string newpara,string type);
    inline vector<string> get_paralist();
    inline vector<string> get_paratype();
    inline void set_isdefined();
    inline bool get_isdefined();
};

Function :: Function()
{
    number_of_parameter = 0;
    isdefined = false;
    return_type = "";
}
void Function :: set_return_type(string type)
{
    this->return_type=type;
}
string Function :: get_return_type()
{
    return return_type;
}
void Function :: set_number_of_parameter()
{
    //number_of_parameter = pList.getLength();
    number_of_parameter = pList.getLength();
}
int Function :: get_number_of_parameter()
{
    return number_of_parameter;
}
void Function :: add_number_of_parameter(string newpara,string type)
{
    if(pList.getLength() == 0)
    {    
        pList.insertItem(newpara);
        pType.insertItem(type);
    }
    else
    {
        pList.insertLast(newpara);
        pType.insertLast(type);
    }
       // pList.push_back(newpara);
       // pList.push_back(type);
        set_number_of_parameter();
}
vector<string> Function :: get_paralist()
{
    vector<string>parameter_list;
    for(int i = 0; i<pList.getLength(); i++)
    {
        parameter_list.push_back(pList.getItemAt(i)->item);
    }
    return parameter_list;
    //return pList;
}
vector<string> Function :: get_paratype()
{
     vector<string>parameter_type;
    for(int i = 0; i<pType.getLength();i++)
    {
        parameter_type.push_back(pType.getItemAt(i)->item);
    }
    return parameter_type;
    //return pType;
}
void Function :: set_isdefined()
{
    this->isdefined = true;
}
bool Function :: get_isdefined()
{
    return isdefined;
}