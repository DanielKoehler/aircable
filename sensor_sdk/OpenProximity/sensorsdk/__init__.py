#    OpenProximity2.0 is a proximity marketing OpenSource system.
#    Copyright (C) 2009,2008 Naranjo Manuel Francisco <manuel@aircable.net>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation version 2 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# SensorSDK handler

#from rpc import handle
from serverxr import SensorManager

def post_environ():
    from rpc import handle, register, device_found
    provides['rpc'] = handle		# provide rpc handle
    provides['rpc_register'] = register # sensorsdk generic client will register with us
    provides['found_action'] = device_found

def reset_stats(connection):
    from django.db import models
    from django.core.management.color import no_style
    from django.core.management import sql
    tables = [ 
	#'sensorsdk_',
	#'agent_agentrecord'
    ]
    
    for table in tables:
	connection.cursor().execute("drop table %s" % table)

provides = { 
    'name': 'SensorSDK plugin', 	# friendly name
    
    'enabled': True,			# disable me please
    
    'django': True,			# expose me as a django enabled plugin
    
    'post_environ': True,		# we want to handle some RPC events, 
					# but we want to register after environ
					# is setup, this way we can access
					# models from rpc

    'TEMPLATE_DIRS': 'templates',	# static media I give to django
    'LOCALE_PATHS': 'locale',
    'django_app': True,			# we provide an application so we can
					# define models
   

    'statistics_reset':	reset_stats, 
    'urls': ( 'sensorsdk', 'urls' ),	# urls I give to django
    
    'serverxr':	True,			# we have our own rpc client
    'serverxr_type': 'sensorsdk',
    'serverxr_manager':	SensorManager,
}
