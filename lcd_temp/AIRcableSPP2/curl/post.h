/*
 *  Simple www post application.
 *
 *  Copyright (C) 2007 Naranjo,manuel <manuel@aircable.net>
 *  Copyright (C) 2007 Wireless Cables Inc  <aircable.net>
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

#ifndef POST_H_
#define POST_H_

#include "../errorcodes.h"

#include <stdlib.h>
#include <malloc.h>
#include <string.h>

#include <curl/curl.h>
#include <curl/types.h>
#include <curl/easy.h>


void  postCleanUP();
void  postSetURL(const char* newURL);
int   postGetURL(char * url);

//char* postDoPost(const char * content);
int post(const char * content, char* out, int maxlen);

#endif /*POST_H_*/
