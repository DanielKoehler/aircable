/*
 *  Node handler.
 *
 *  Copyright (C) 2007 Naranjo,manuel <manuel@aircable.net>
 *  Copyright (C) 2007 Wireless Cables Inc <http://www.aircable.net>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 * 
 */

#include "node.h"

int calcTemp(NODE* node, int val, int calib){
	switch (node->type){
		case 'K':
			node->temperature=(125/2566.4)*(val+calib);
			return OK;
		case 'I':
			node->temperature=val/10;
			return OK;
		default:
			fprintf(stderr,"%c is not a valid type\n", node->type);
			return ERROR;
	}
}

int parseTemp(NODE* node, char * buf){
	float value, calib;
		
	//Message format: !<VAL>:<CAL>#<TYPE>
		
	if ( sscanf(buf, "!%f:%f#%1c", &value, &calib, &node->type) != 3 ){
		fprintf(stderr, "%s Doesn't match pattern\n", buf);
		return ERROR;
	}
	
	return calcTemp(node, value, calib);
}

/**
 * isTagPresent(Node * node, char *tag)
 * Checks in node->document if a tag is present, in case it's present then
 * node->tag will point to that node, and will return TAG_FOUND
 */
int isTagPresent(NODE * node, char *tag){
	int ret = TAG_NOT_PRESENT;

	MXML_ITERATOR iter;	
	MXML_NODE * temp;
	
	if (node->tag != NULL){
		mxml_node_destroy(node->tag);
		node->tag = NULL;
	}
	
	mxml_iterator_setup( &iter, node->lastReply );
	
	temp = mxml_iterator_scan_node( &iter, tag );
		
	if (temp && temp->name){		
		ret = TAG_FOUND;
		node->tag = mxml_node_clone_tree(temp);
	}
		
	return ret;	
}


int workMonitor(NODE *node){
	int ret = OK;
	int flags = 0;
	int min, max;
	

	
	if (isTagPresent(node, TAG_DISPLAY_TEMP)!=TAG_FOUND){
		flags += FDISPLAY_TEMP;
		
		if (isTagPresent(node, TAG_RETURN_TEMP))
			flags += FRETURN_TEMP;
		
		if (isTagPresent(node, TAG_COMP_TEMP)){
			MXML_NODE *mnode;
			flags += FCOMPARE_TEMP;
			
			mnode = node->tag->child;
			
			if (strcmp("min", mnode->name)==0){
				min = atoi(mnode->data);
				max = atoi(mnode->next->data);
			} else {
				max = atoi(mnode->data);
				min = atoi(mnode->next->data);
			}
		}
	}
	
	return ret;
}

char* getReturnVars(NODE *node){
	MXML_NODE *mnode;
	char * options = NULL;
	int t = 0;
	
	if (isTagPresent(node, TAG_RETURN_VARS)!=TAG_FOUND)
		return NULL;
			
	options = calloc (2048, sizeof (char));
	
	mnode = node->tag->child;
	
	while (mnode){
		t += sprintf(options, 
				"%s<%s>%s</%s>\n",  
				options,
				mnode->name,
				mnode->data,
				mnode->name);		
		
		mnode = mnode->next;
				
	}
	options[t]=0;
	
	return options;	
}

char * generateXML(NODE * node) {
	char* out = NULL;	
	int len = 0;
	
	if (!node){
		fprintf(stderr, "Can't generate xml file out of a null node\n");
		return NULL;
	}
	
	char * format;
	char * optional = 0;
	
	format  = 	"<?xml  version='1.0' ?>\n"
				"<content>\n"
				"<function>%s</function>\n"
				"<nodeid>%s</nodeid>\n"
				"<selectedvalue>%s</selectedvalue>\n"
				"<currentTemp>%.2f</currentTemp>\n"
				"%s"
				"</content>\n";

	len = strlen ( format );
	if (node->function)
		len+=strlen(node->function);
	
	if (node->nodeId)
		len+=strlen(node->nodeId);
	
	if (node->value)
		len+=strlen(node->value);
	
	if (node->lastReply){
		optional = getReturnVars(node);
		if (optional)
			len+=strlen(optional);
	}
	
	len+=1;
			
	out  = (char*)calloc(2048, sizeof(char));
	
	len = sprintf(out, 
			format, 
			node->function, 
			node->nodeId, 
			(node->value ? node->value : ""), 
			node->temperature, //temp,
			(optional ? optional : "")
	);
	
	if (optional)
		free(optional);
	
	return out;
}

int sendRequest(NODE* node){
	MXML_DOCUMENT * doc;	
	char * xml;
	char * rep = NULL;
	int ret;
	
	xml = generateXML(node);
	
	if (!xml){
		fprintf(stderr,"Something went wrong when generating xml content\n");
		return ERROR;
	}		
	
	rep = calloc(5048, sizeof(char));
	
	ret = post(xml, rep, 5048);
	
	free(xml);
	
	if (!ret){
		perror("Coulnd't do post\n");
		return ERROR;
	}
	
	doc=mxml_buffer(rep, 0);
	
	free(rep);
	
	if (node->tag) {//we need to clear the last used tag
			mxml_node_destroy(node->tag);
			node->tag = 0;
	}

	if (node->lastReply) {//we need to clear the last status.
		mxml_document_destroy(node->lastReply);
		node->lastReply = 0;
	}
	
	node->lastReply = doc;
	
	return OK;
}


/**
 * Get menu options from last reply
 */
int parseEntries(NODE * node, menu_entry *output){
	menu_entry * out;
	menu_entry * curr;
	int i = 0;
	
	MXML_NODE *menu;
	
	if (isTagPresent(node, TAG_SELECT_MENU)!=TAG_FOUND){
		fprintf(stderr, "Tag <%s/> not present in the xml doc\n", 
				TAG_SELECT_MENU);
		fprintf(stderr, "There's no menu to send\n");
		return ERROR;
	}
	
	out = NULL;
	
	menu = node->tag->child;
	
	while (menu){
    	MXML_NODE *node;
    	
    	curr =menu_entry_new();
    	
    	curr->next = out;
    	node = menu->child;    	
    	
    	if (strcmp(node->name, TAG_TEXT) == 0){
    		curr->text = node->data;
    	}
    	else if (strcmp(node->name, TAG_VALUE) == 0){
    		curr->value = node->data;
    	}
    	curr->index = ++i;
    	
    	node = node->next;
    	
    	if (strcmp(node->name, TAG_TEXT) == 0){
    		curr->text = node->data;
    	}
    	else if (strcmp(node->name, TAG_VALUE) == 0){
    		curr->value = node->data;
    	}
   		
    	menu=menu->next;
    	
    	out = curr;
    }
    
    out = sort(out, i);
    
    if (out){
    	output->index = out->index;
    	output->next  = out->next;
    	output->text  = out->text;
    	output->value = out->value;
    	free(out);
    }     
    
#ifdef DEBUG_UTILS
	curr = out;
	while (curr){
		printf("index: %i,\ttext: %s,\tvalue: %s\n", curr->index, curr->text, curr->value);
		curr = curr->next;
	}
#endif
	
	return OK;
}

/**
 * Get the response function
 */
int getResponseFunction(NODE * node){
	int len; char * data;

	if (isTagPresent(node, TAG_RESP_FUNCTION)!=TAG_FOUND){
		fprintf(stderr, "Tag: <%s/> is not present can't go on\n", 
				TAG_RESP_FUNCTION);
		return ERROR;
	}
	
	data = node->tag->data;
	
	node->function = realloc(node->function, strlen(data)+1);
	
	len = sprintf(node->function, "%s", data);
	node->function[len]=0;
	
		
	return OK;		
}

int getSelected(NODE * node, menu_entry * menu, menu_entry * reply){
	char *buf;	
	unsigned short int rep;	
	float cal, val;
		
	buf = calloc(30, sizeof(char));
	
	if (!buf){
		perror("Couldn't allocate buffer at getSelected()\n");
		return ERROR;
	}
	
	if (!sppReadLine(node->socket, buf, 30)){
		perror("Couldn't read option");
		free(buf);
		return ERROR;
	}
	
	if (strcmp( buf, "\x03") == 0){
		printf("LCD closed connection\n");
		free(buf);
		return CONNECTION_CLOSE;
	}
		
	if ( sscanf(buf, "@%02hX!%f:%f#%s", &rep, &val, &cal, &node->type) != 4 ){
		perror("Wrong content");
		free(buf);
		return WRONG_REPLY;
	}					
	
	free(buf);
	
	while (menu && menu->index != rep)
		menu = menu->next;
						
	if (menu == NULL ){
		fprintf(stderr, "Wrong Option %i\n" , rep);
		return WRONG_REPLY;
	}
		
	printf("Selected: index:%02hX\ttext:%s\tvalue:%s\n", rep, menu->text, menu->value);
	
	reply->index = menu->index;
	reply->next  = NULL;
	
	if (strlen(menu->text)){
		reply->text = realloc(reply->text, strlen(menu->text)+1);
		reply->text[0] = 0;
		strcpy(reply->text, menu->text);
		reply->text[strlen(menu->text)]=0;
	}
	
	if (strlen(menu->value)){		
		reply->value = realloc(reply->value, strlen(menu->value)+1);
		reply->value[0] = 0;
		strcpy(reply->value, menu->value);
		reply->value[strlen(menu->value)]=0;
	}
	
	return OK;
		
}

int sendMenu(sppSocket *socket, menu_entry * menu){
	const static int bufsize=1024;
	char * buf, * rec;
	int j = 0;
	menu_entry * head;
	
	if (!socket->SPPclient) {
		fprintf(stderr,"Not connected, can't go on\n");
		return ERROR;
	}

	buf = calloc(bufsize, sizeof(char));
	rec = calloc(bufsize, sizeof(char));
	
	head = menu;
	
	while (menu){
		j++;
		menu=menu->next;
	}
	
	menu = head;
		
	sprintf(buf, "%%%i\n\r", j);
	
	j = sppWriteLine(socket,buf);

	if (j < 0){
		fprintf(stderr, "failed to send amount of options\n");
		return ERROR;
	}
	
	//by now give time to the lcd to settle up
	while (menu){
		sprintf(buf,"%02hX%s\n\r", menu->index, menu->text);
		j = sppWriteLine(socket, buf);

		if ( j < 0 ){
			fprintf(stderr, "There has been an error while writting "
					"to the socket (while)\n");
			return ERROR;
		}
		
		j = sppReadLine(socket, rec, bufsize);
		if ( j < 0 ) {
			fprintf(stderr, "There has been a problem while "
					"waiting ACK reply (menu)\n");
			return ERROR;
		}			
		
		if (menu->next)
			sprintf(buf,"&%02hX", menu->index);
		else
			sprintf(buf,"$%02hX", menu->index);
		
		if ( strncmp(buf, rec,3) == 0){
			menu = menu->next;
			printf("LCD got menu option\n");
		}
		else {
			fprintf(stderr, "Wrong reply from the LCD\n");
			sleep(5);
		}
	}
	
	printf( "LCD got menu\n");
	
	free(buf);
	free(rec);
	
	return OK;
}

int workMenu(NODE * node){
	menu_entry * entries, *reply;
	int ret, count = 0;
	
	entries = menu_entry_new();
	
	ret = parseEntries(node, entries);
	if (ret != OK){
		fprintf(stderr, "Failed to get options, can't send menu to LCD\n");
		return ret;
	}
	
	ret = sendMenu(node->socket, entries);
	if (ret != OK){
		fprintf(stderr, "Couldn't send menu\n");
		menu_entry_destroy(entries);
		return ret;
	}
	
	reply=menu_entry_new();
	if (!reply){
		perror("Couldn't allocate memory\n");
		menu_entry_destroy(entries);
		return ERROR;
	}
	
	ret = ERROR;
	
	while ( count < 3 ){
		ret = getSelected(node, entries, reply);
		if (ret==OK || ret==CONNECTION_CLOSE)
			break;
		
		count ++;
	}
	
	if (ret == CONNECTION_CLOSE){
		fprintf(stderr, "Node will close connection\n");
		goto free;
	}
	
	if (ret != OK){
		fprintf(stderr, "Didn't got right response from LCD, ret code: %i\n", ret);
		goto free;
	}
	
	
	count = strlen(reply->value);
	
	node->value = realloc(node->value, count+1);	
	memcpy(node->value, reply->value,count);
	node->value[count]=0;

free:
	if (reply->text)
		free(reply->text);
	
	if (reply->value)
		free(reply->value);
	
	menu_entry_destroy(reply);
	
	menu_entry_destroy(entries);
	
	return ret;
}

int doWork(NODE * node){
	int ret;
	while (1){
		if (isTagPresent(node, TAG_MONITOR)!=TAG_FOUND)
			ret = workMenu(node);
		
		else
			ret = workMonitor(node);
		
		
		if (ret != OK)			
			break;
		
		ret = getResponseFunction(node);
		
		if ( ret != OK )
			break;
		
		ret = sendRequest(node);
		
		if (ret != OK)
			break;
		
	}

	fprintf(stderr, "Do work ending, ret value: %i\n", ret);
	return ret;
}

int initConnection(NODE * node){
	int bytes_read = 0;
	int counter = 0;
	char *buf;
	
	if (!node){
		fprintf(stderr, "Node can't be null\n");
		return ERROR;
	}
	
	if (!node->socket){
		fprintf(stderr, "You need to initializate spp side first");
		return ERROR;
	}
		
	
	buf=calloc(1024, sizeof(char));
	
	while (bytes_read <= 0){
		bytes_read = sppReadLine(node->socket, buf, 1024);

		if (bytes_read <= 0 && counter == 3){
			fprintf(stderr, 
				"Connection timeout, device is not sending us the current temp\n");
			return ERROR;
		}
		usleep(100*1000);
		counter++;
	}
	
	if ( parseTemp(node, buf) != OK )
		return ERROR;
	
	free(buf);
	
	return sendRequest(node);
}

void simulate(){
	const char addr[] = "http://www.smart-tms.com/xmlengine/transaction.cfm";	
	
	postSetURL(addr);
	
	NODE * node = node_new();
	
	sppSocket *socket;
	
	socket = (sppSocket*) malloc(sizeof(sppSocket));
	
	dup2((int)stdin, (int)stdout);

	socket->SPPclient = (int)stdin;
	socket->SPPsocket = (int)stdin;
	
	node->socket=socket;
	
	char *t = calloc(500, sizeof(char)); sprintf(t, "1234-1234-1234-1234");
	node->nodeId=t;

	node->function=TAG_AUTHENTICATE;
	
	node->value = NULL;
	
	initConnection(node);
	
	getResponseFunction(node);
	workMenu(node);
		
	postCleanUP();
	
	node_destroy(node);
					
}

int isAccepted(NODE * node){
	int ret = OK;
	
	if (isTagPresent(node, TAG_ACCEPT)!=TAG_FOUND){
		ret = NOT_ACCEPTED;
		printf("Node wasn't authenticated\n");
	} else
		printf("Authentication completed\n");
		
	return ret;	
}

void nodemain(int channel){
	const char addr[] = "http://www.smart-tms.com/xmlengine/transaction.cfm";	
	
	postSetURL(addr);
	
	NODE * node = node_new();
	
	sppSocket *socket;
	
	socket = (sppSocket*) malloc(sizeof(sppSocket));
	
	socket->channel=channel;
	
	sppRegister(socket);
	
	sppListen(socket);
	sppWaitConnection(socket);
	
	node->socket = socket;
	
#define DEBUG
#ifndef DEBUG
#include <bluetooth/bluetooth.h>
	char *t = calloc(18, sizeof(char));	
    ba2str( &socket->SPPpeer, t );
    t[17]=0;
    
#else
	char *t = calloc(21, sizeof(char)); 
	sprintf(t, "1234-1234-1234-1234");
	t[20]=0;
#endif
	node->nodeId=t;
	
	node->function=TAG_AUTHENTICATE;
	
	node->value = NULL;
	
	initConnection(node);
	
	if (isAccepted(node) == OK){
	
		getResponseFunction(node);
		doWork(node);
	}
	
	sppDisconnect(node->socket);
		
	
	
	sppUnregister(node->socket);
	
	
	
	postCleanUP();
	
	node_destroy(node);
}

