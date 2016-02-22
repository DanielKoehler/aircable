This document explains how to customize SensorSDK code to work with your hardware via the PIO lines.

# Introduction #

The AIRcable SensorSDK board comes with 3 buttons attached to PIO lines, 3 LEDs and you still have 3 more PIOs you can use by just creating your custom Sensor board, leading to 9 possible IO lines.

SensorSDK code is ready to work with this PIO in a very easy and extensible way. No matter if you're going to use the buttons and standard leds or a fancy sensor like a close/open door sensor, or a binary water level sensor, SensorSDK code can help you achieve your task.

This document will mainly describe some [\*base code\*](http://aircable.googlecode.com/svn/sensor_sdk/BASIC.preparser/base/AIRcable.bas) functions

# PIO assignation #

PIO used by the code are stored in $1, for $1 we use a very basic alphabet from @ to Z where @ is 0, A is 1, B is 2, C is 3, etc.

Each character in $1 represents a certain source:
  * $1`[0]` is left button, defaults to D=4
  * $1`[1]` is middle button, defaults to L=12
  * $1`[2]` is right button, defaults to C=3
  * $1`[3]` is green led, defaults to I=9
  * $1`[4]` is blue led, defaults to T=20
  * $1`[5]` is deep sleep PIO, defaults to @=0, meaning it's disconnected.

Example:
```
1 DLCIT@
```

# PIO handling #

## Button Press ##
PIO handling is done in @PIO\_IRQ, SensorSDK code is ready to handle short and long button press recognition, we consider a long button press as a button that keeps been pressed after 3 seconds. In case you want to handle this simple events then you just need to provide a handler for it. As on every SensorSDK application this can be done easily by just overlapping code (adding your code at the end).

Extension points for button presses are defined as:
```
## left long button press
34 RETURN
## middle long button press
35 RETURN
## right long button press
36 RETURN
## left short button press
37 RETURN
## middle short button press 
38 RETURN
## right short button press
39 RETURN
```

So if for example you want to handle middle short button press, and you're handler starts in line _800_, then you would add a line of code at the end that says:
```
38 GOTO 800
```

## Custom Inputs ##

### Easy way, up to 3 PIOs ###
In case you want to use your own custom inputs then you have different ways to achieve this, the simple one is by modifying $1 and simulating with your input button behavior. For this is very important that you know that **left** and **right** buttons are **normal high** while **middle** is **normal low**.

If you go this way then you don't have to worry about modifying any more code.

### Hard Way, up to 6 PIOs ###
If you need to use more than 3 PIOs, meaning you need to use the 3 buttons and other inputs then you will have to modify a few more lines.

First you need to extend @INIT so you add your pios to the _pioirq_ call. Extension point is 20. Supposing you attach your sensor to PIO0, then your code would start looking like:
```
20 GOTO 800;

800 $6[1]= 48 
0 REM add '1' to pio irq at character 1, now $6 looks like P1001....
801 A = pioclr 1 
0 REM supposing your sensor is going to be normal low
802 A = pioin 1
803 RETURN
```

Then you need to modify @PIO\_IRQ call, original code looks like:
```
## PIO interrupts
@PIO_IRQ 170
170 $169=$0;
## check for long button press flag
171 IF T = 1 THEN 178;
## button press while in settings menu?
172 IF Q > 100 THEN 260;
## 173 and 174 are free, you code can hack here.
## button press starts long button recognition
175 IF$169[$1[0]-64]=48THEN180;
176 IF$169[$1[1]-64]=49THEN180;
177 IF$169[$1[2]-64]=48THEN180;
## was it a release for a short press?
178 IF W <> 0 THEN 185;
179 RETURN

## this was a new press
180 $14 = $169;
181 W = 1;
182 ALARM 3;
183 RETURN


## button released for a short press
185 W = 0;
186 ALARM 0
## hack point lines 187, 188
## left button
189 IF$14[$1[0]-64]=48THEN37;
## middle button
190 IF$14[$1[1]-64]=49THEN38;
## right button
191 IF$14[$1[2]-64]=48THEN39;
192 RETURN

## long button press, called by @ALARM
200 W = 0;
## hack point line 201,202
## long left
203 IF$14[$1[0]-64]=48THEN34;
## long middle
204 IF$14[$1[1]-64]=49THEN35;
## long right
205 IF$14[$1[2]-64]=48THEN36;
## shouldn't get here
206 ALARM 5
207 RETURN
```

First you need to tell line 173 to use your PIO, in our case it would look like:
```
173 IF$169[1]=49THEN180;
```

If your sensor will give a short pulse, between 1 and 3 seconds, then you can extend on line 192, don't forget to add **RETURN**. Supposing your handler is at line 810 then your code would look like:
```
192 IF $14[1]=49THEN810;
193 RETURN

810 you do something here
....
819 RETURN
```

If your sensor is going to give pulses of over 3 seconds then you can extend at line 206 as:
```
206 IF $14[1]=49 THEN 820;
207 ALARM 5
208 RETURN

820 do something here....
829 RETURN
```