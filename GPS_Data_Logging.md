GPS and Data Logging Example.

# Introduction #

In this example you will be shown how to use your AIRcable OS enabled device as a data logger for your GPS device. Even though we are going to cover Data Logging using a GPS this example can be easily extended to what ever you need to log.

# Code #
```
@ERASE

0 REM Line $1 BT address of the GPS
0 REM Set this line to your GPS device, this code will not do
0 REM inquires
1 000A8401D6C2

0 REM PIN Code, set this to your GPS PIN Code
2 1234

@INIT 50
0 REM debug
50 Z = 1
51 A = baud 1152
52 A = slave -1
0 REM J stores the pio where the led is attached
53 J = 3
0 REM LED output an don
54 A = pioout J
55 A = pioset J
0 REM E will be used for state
0 REM E = 0 disconnected
0 REM E = 1 connected
56 E = 0
57 RETURN

@IDLE 60
60 ALARM 1
61 RETURN

@PIN_CODE 70
70 $0 = $2
71 RETURN

@ALARM 100
0 REM we need to start an inquiry
0 REM blink leds
100 IF E = 1 THEN 150
101 A = pioset J;
102 A = pioclr J
103 A = master $1
104 ALARM 6
105 RETURN

0 REM we are connected, lets check we are still connected
150 A = status
151 IF A > 0 THEN 160
152 A = pioclr J
153 ALARM 1
154 E = 0
155 RETURN

0 REM valid input:
0 REM $GPRMC,204427.427,A,3659.5833,N,12158.5155,W,12.16,252.97,230906,,*29

160 TIMEOUTM 10;
161 INPUTM $0;
162 IF $0[0] = 0 THEN 212
163 B = strcmp "$GPRMC"
164 IF B <> 0 THEN 212
0 REM check for valid RMC string
165 IF $0[18] <> 65 THEN 212
0 REM store long/latitude
166 $0[64] = 0
0 REM store long/latitude in $3
0 REM as the valid string is over 32 chars, we need to store a part
0 REM in another variable
167 $4 = $0[18]
168 $5 = $0[18+32]

0 REM check if file exits
170 A = exist "gps.log"
171 IF A <> 0 THEN  174
0 REM it doesn't so let's create it
172 L = open "gps.log"
173 GOTO 175
0 REM if the file is all ready on the system, then we append data to it
174 L = append "gps.log"

0 REM the log will look like:
0 REM date0 place0
0 REM date1 place1
0 REM ...
0 REM dateN placeN
0 REM ...

0 REM ask for date
175 A = date $0
0 REM add a space before the string end
176 PRINTV " ";
177 B = strlen $0
0 REM we need to tell the command write how many chars we are writting
178 L = write B
179 $0 = $4
180 PRINTV $5
181 PRINTV "\n"
182 B = strlen$0
183 L = write B
0 REM we must make sure the file is not full, we will take 1000 bytes as the 
0 REM maximum size
184 Q = size
185 IF Q > 1000 THEN 192
0 REM if there's space on the file then we close it, and trigger the alarm again
186 L = close
187 GOTO 202

0 REM if the file is full,
0 REM we disconnect
192 A = disconnect 1
0 REM turn off the led
193 A = pioclr J
0 REM and close the file
194 L = close
195 ALARM 0
196 RETURN

202 ALARM 2
0 REM we tell the user we had record some data by blinking the LED
203 A = pioclr J;
204 A = pioset J
205 RETURN

0 REM if we didn't read valid data then we don't do anything except for 
0 REM triggering the alarm
212 ALARM 2
213 RETURN

0 REM Connection established, trigger alarm, and start the fun
@MASTER 220
221 E = 1
222 A = pioset J
223 ALARM 2
224 RETURN

```

[Download File](http://aircable.googlecode.com/svn/examples/gps_example/AIRcable.bas)

_**Note**: You need to change lines $1 and $2 to match your device Bluetooth Address and PIN respectively_

## Explanation ##
There are two things we think are important to make you notice here.

One is:
```
166 $0[64] = 0
0 REM store long/latitude in $3
0 REM as the valid string is over 32 chars, we need to store a part
0 REM in another variable
167 $4 = $0[18]
168 $5 = $0[18+32]
```
Firstly we remove some ending stuff from the GPS response. Then we store that result into two different variables, this is very important because you can't use more than 32 chars on string variables except for $0 that can be used for up to 80.


Then you have the data logging part:
```
170 A = exist "gps.log"
171 IF A <> 0 THEN  174
172 L = open "gps.log"
173 GOTO 175
174 L = append "gps.log"

175 A = date $0
176 PRINTV " ";
177 B = strlen $0
178 L = write B

179 $0 = $4
180 PRINTV $5
181 PRINTV "\n"
182 B = strlen$0
183 L = write B

184 Q = size
185 IF Q > 1000 THEN 192
186 L = close
187 GOTO 202
```

_**Note:** We remove the comments and empty lines to have all the source into one block_

We will divide it into parts:

### File Opening ###
```
170 A = exist "gps.log"
171 IF A <> 0 THEN  174
172 L = open "gps.log"
173 GOTO 175
174 L = append "gps.log"
```
Here we check if the log file exits. If it doesn't then we create it and open it, if it does exit then we open it in append mode.

### Data Writting ###
```
175 A = date $0
176 PRINTV " ";
177 B = strlen $0
178 L = write B
```
This part reads the system clock time into $0, and then write it to the open file. Take into account that the write command need as parameter the amount of bytes it must write to the file, and it does return the amount of bytes it could write we are not using it, but it's a good way to know if a file is full or not.

### Size Checking and Closing File ###
{{{184 Q = size
185 IF Q > 1000 THEN 192
186 L = close
187 GOTO 202175 A = date $0
176 PRINTV " ";
177 B = strlen $0
178 L = write B
}}}
In this last part we check the size of the file, we want to make sure the file don't get too big, so we check it's size is below 1000 bytes, this size has not been chosen by anything in special, it is just an example. 

If the file is not over 1000 we just close the file and do the rest of the stuff as normal, if the file is big enough then we end with the @ALARM cycles and we stop logging, someone will have to get connected to the device and delete or empty the log before we can go on.```