SMS Sender Example

# Introduction #

This example will show you how to use your cell phone with the AIRcable to send
sms messages.

# Code #
```
@ERASE
0 REM $1 is the bt address of your phone
1 AABBCCDDEEFF

0 REM $2 is the dest phone number
2 +111111111111

0 REM $3 Message Header check line 59
3 0

0 REM $4 stores the sensor reading
4 0

@INIT 50
0 REM debug
50 Z = 0
51 A = baud 1152
0 REM we must be invisible
52 A = slave -1
0 REM J stores the pio where the led is attached
53 J = 20
0 REM LED output and on
54 A = pioout J
55 A = pioset J
56 A = enable 2
57 ALARM 1
0 REM E state var,
0 REM E = 0 need to meassure sensors
0 REM E = 1 need to connect 
0 REM E = 2 send message
0 REM E = 3 need to go idle for 10 minutes
58 E = 0
59 $3 = "AIRcable Sensors: "
60 RETURN

@ALARM 100
100 A = pioset J
101 A = pioclr J
102 IF E = 0 THEN 120
103 IF E = 1 THEN 130
104 IF E = 2 THEN 139
105 IF E = 3 THEN 180
106 ALARM 5
107 RETURN

110 ALARM 5
111 RETURN

120 A = nextsns 1
121 ALARM 5
122 E = 1
123 RETURN

130 A = dun $1
131 E = 0
132 ALARM 10
133 RETURN

139 A = pioset J
140 ALARM 0
141 $0="AT\n\r"
142 GOSUB 300
143 PRINTU"\n\r"
144 $0="AT+CMGF=1\n\r"
145 GOSUB 300
146 PRINTU"\n\r"
147 $0="AT+CMGW=\x22"
148 PRINTV $2
149 PRINTV "\x22\n\r"
150 GOSUB 300
151 PRINTU"\n\r"
152 $0[0] = 0 
152 PRINTV $3
153 PRINTV $4
154 GOSUB 300
155 $0 = "\x1A\n\r" 
156 GOSUB 300
157 $0="AT+CMSS="
158 PRINTV $6
159 PRINTV"\n\r"
160 GOSUB 300
161 PRINTU"\n\r"
162 A = disconnect 1
163 E = 3
164 A = zerocnt
165 ALARM 5
166 RETURN

180 B = readcnt
181 IF B < 10 * 60 THEN 183
182 E = 0
183 ALARM 5
184 RETURN

@SENSOR 190
190 C = sensor $0
191 $4 = $0
192 E = 1
193 ALARM 5
194 RETURN

@MASTER 200
200 E = 2
201 ALARM 5
0 REM 202 A = link 2
203 RETURN

@PIN 220
220 $0="1234
221 RETURN

300 PRINTM $0
301 $0[0] = 0
302 TIMEOUTM 1;
303 INPUTM $0;
304 PRINTU $0;
305 A = strcmp "+CMGW:";
306 IF A = 0 THEN 308;
307 $6 = $0[7];
308 A = strcmp "ERROR";
309 IF A = 0 THEN 320;
310 A = strcmp ">";
311 IF A = 0 THEN 314;
312 A = strcmp "OK";
313 IF A <> 0 THEN 302;
314 RETURN

320 A =disconnect 1
321 RETURN
```

[Download AIRcable.bas](http://aircable.googlecode.com/svn/examples/smsSender/AIRcable.bas)

_**Note:** Change line $1 to your Cell Phone Bluetooth Address, and line $2 to a
valid cell phone number_

_**Note 2:** To use this code you will need AIRcable Firmware [R28](https://code.google.com/p/aircable/source/detail?r=28), please contact our
customer support to get it_

# Explanation #
This code is quite simple, firstly it will read the sensors, then it will open
a connection to the DUN profile of your cell phone. Finally it will generate the
sms message using the AT Hayes standard. It will repeat this cycle once each 10
minutes.

The interesting part here, is how to generate and send SMS messages. Here you have
a dump of the sms part:

```
AT
OK
AT+CMGF=1
OK
AT+CMGW="+111111111111"
> AIRcable Sensors: 484 49 31 -1 -1"
+CMGW: 2536
OK
AT+CMSS= 2536
OK
```

The first AT only check if the phone is available to work. Then AT+CMGF=1 sets the sms mode to plain text
this will let us create sms messages without worry about binary formats. Then AT+CMGW creates a message to
the number +111111111111 and will start asking the text for the message, you can end message by writting
CTRL+Z. AT+CMGW will reply with the sms number, this number is needed in order to send the message
with AT+CMSS.