# -*- coding: utf-8 -*-
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

# agent plugin
# defines new clases for db integration

from plugins.sensorsdk import models
from django.utils.translation import ugettext as _
from django.db import models as mod
from re import compile
from datetime import datetime
import math

class SolarDevice(models.SensorSDKRemoteDevice):
    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-solar"

    @staticmethod
    def getChartVariables():
	return ['solar', 'pool', 'tank', 'flow', 'wattm', 'power']
	
    @staticmethod
    def getRecordClass():
        return SolarRecord

    @staticmethod
    def ntc_to_temperature(ntc):
	return 105.1-ntc*0.06957

    @staticmethod
    def flow(mv):
	return mv*11.0/15.0/100.0;

    @staticmethod
    def gpm2lpm(gpm):
	return gpm * 3.785;

    @staticmethod
    def power(flow, hot, cold):
	dt = ( hot - cold ) / 9.0 - 2
	power = flow * 90.0 * dt * 5.0 / 17.0
	return power

READING=compile(r'SOL\|(?P<solar>\d+)\|(?P<pool>\d+)\|(?P<tank>\d+)\|(?P<flow>\d+)\|(?P<wattm>\d+)\|(?P<day>\d).*$')
class SolarRecord(models.SensorSDKRecord):
    
    # ntc sensor
    solar  = mod.FloatField(help_text=_('solar temperature in Celcius'))
    solar_v = mod.IntegerField(help_text=_('solar millivolts'))
    
    # ntc sensor
    pool = mod.FloatField(help_text=_('pool temperature in Celcius'))
    pool_v = mod.IntegerField(help_text=_('pool millivolts'))
    
    # ntc sensor
    tank = mod.FloatField(help_text=_('tank temperature in Celcius'))
    tank_v = mod.IntegerField(help_text=_('tank millivolts'))
    
    # flow sensor
    flow = mod.FloatField(help_text=_('flow sensor in LPM'))
    flow_v = mod.IntegerField(help_text=_('flow millivolts'))
    
    # minutes accumulating power
    wattm = mod.IntegerField(help_text=_('amount of minutes accumulating power'))
    
    watt_in = mod.FloatField(help_text=_('ammount of watts getting in'))
    watt_out = mod.FloatField(help_text=_('ammount of watts going out'))
    watt_delta = mod.FloatField(help_text=_('ammount of watts accumulated'))
    
    day = mod.BooleanField(help_text=_('day sensor'))
    
    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-solar"
    
    @staticmethod
    def parsereading(device=None, seconds=None, battery=None, reading=None, dongle=None):
	'''This method expects to get a valid reading, generating a record out of it'''
	
	#extract parameters from reading string
	vals=READING.match(reading).groupdict()
	
	#find ambient device, or create if there's none yet created
	device,createdSolarDevice.objects.get_or_create( address=device,
	    defaults={
		'name': _('Auto Discovered Solar Sensor'),
		'sensor': _('Solar'),
		'mode': _('Monitor'),
	    })
	
	temp=device.getTemperature(float(temp))
	temp['day'] = int(temp['day']) == 1
	
	record = SolarRecord()
	record.remote=device
	record.dongle=dongle
	for i in vals.keys():
	    if i in ['solar', 'pool', 'tank']:
		setattr(record, '%s_v' % i, vals[i])
		setattr(record, i, SolarDevice.ntc_to_temperature(vals[i]))
	    if i in ['flow',]:
		setattr(record, '%s_v' % i, vals[i])
	    if i not in ['wattm', 'day']:
		setattr(record, '%s_v' % i, vals[i])
		record.flow=SolarDevice.gpm2lpm(flow)
		flow=SolarDevice.flow(vals[i])
	    elif i in ['wattm',]:
		record.wattm = vals[i]
	    elif i in ['day',]:
		record.day = vals['day'][0] == '1'

	record.watt_in = SolarDevice.power(flow, record.solar, record.pool)
	record.watt_out = SolarDevice.power(flow, record.tank, record.pool)
	record.watt_delta = record.watt_out - record.watt_in

	record.time=datetime.fromtimestamp(seconds)
	record.battery=battery
	record.save()
