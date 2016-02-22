#This example shows how to get the command line over the Bluetooth Channel.

# Introduction #

This example is a modified version of our command line version 0.5. This example will use the Slave channel instead of the UART to show the command line.


# Description #

This gives you a main advantage, you can configure your device any where you are, and you will not need to have a computer to connect to the device. With only a PDA or a Cell Phone that lets you talk to SPP connections you can connect to the AIRcable and configure it.

The main difference between using the UART and the SPP, is that SPP does the echo of each character the user writes, so you don't need to manually echo.

There is only one disadvantage in this case, you will need some sort of switch or something to protect the command line. You need to do this because of two reasons, one reason is that if there is no kind of protection then anyone who can open a connection to your device, can get full control over it. And the other is that you need a way to ensure the command line is on. In our case we used a dip switch connected to a PIO, when the port has a logical "1" the device will get into slave mode and will allow access to the command line (the user will need to input +++ when the connection is opened). If the PIO has a logical "0" then the module will work on normal mode.

If the command line is on accessible mode (meaning the PIO has a logical 1) the user has 5 seconds to write +++. In case you need want a shorter or longer time you have to modify this line: **280 TIMEOUTS 5**, to: **280 TIMEOUTS 2** if you want 2 seconds for example.

# Code #
[Download](http://aircable.googlecode.com/svn/nouart/AIRcable.bas)
```
@ERASE

0 REM this is the base code for all the AIRcable OS products
0 REM we take the AIRcable SMD/Mini as our base device

0 REM let's reserve the first 30 lines for internal stuff

0 REM $1 is the version of the command line
1 0.5

0 REM defaults setting for mode
0 REM uncomment the one you want to use as default
0 REM service slave
2 1110
0 REM service master 3110
0 REM cable slave 1010
0 REM cable master 3010
0 REM idle 0010

0 REM $3 stores the mode configuration
0 REM $3[0] = 0 48 means idle
0 REM $3[0] = 1 49 means pairing as slave
0 REM $3[0] = 2 50 means paired as slave
0 REM $3[0] = 3 51 means pairing as master
0 REM $3[0] = 4 52 means paired as master
0 REM $3[0] = 5 53 means relay pairing
0 REM $3[0] = 6 54 means relay paired
0 REM $3[0] = 7 55 means relay slave connected, master connecting
0 REM $3[0] = 8 56 means relay connected

0 REM $3[1] = 0 48 cable mode
0 REM $3[1] = 1 49 service mode
0 REM $3[1] = 2 50 relay mode

0 REM $3[2] = 0 48 device found / module paired
0 REM $3[2] = 1 49 inquiry needed

0 REM $3[3] = 0 48 means automatic
0 REM $3[3] = 1 49 means manual idle.
0 REM $3[3] = 2 50 manual slave, connecting
0 REM $3[3] = 3 51 manual inq
0 REM $3[3] = 4 52 manual master, connecting
0 REM $3[3] = 5 53 manual slave, connected
0 REM $3[3] = 6 54 manual master, connected
0 REM $3[3] = 7 55 relay pairing

0 REM $3[4] = 1 49 means service relay mode
0 REM $3[4] = 2 50 means cable relay mode

0 REM if var K = 1 then we must do a slave-1

0 REM $3[4] is the amount of time we trigger alarms while on manual
0 REM need service-master mode, does not store pairing information starts 
0 REM with pairing
3 Z

0 REM $4 IS RESERVED FOR PAIRED ADDR
4 0

0 REM $5 stores the name of the devices we only want during inquiry
5 AIRcable

0 REM $6 stores the filter address we filter on during inquiry
6 00A8FFFFFF

0 REM $7 for paired master addresses
7 0

0 REM $8 stores the pio settings
0 REM $8[0] BLUE LED
0 REM $8[1] GREEN LED
0 REM $8[2] BUTTON
0 REM $8[3] RS232 POWER OFF
0 REM $8[4] RS232 POWER ON
0 REM $8[5] DTR
0 REM $8[6] DSR
0 REM $8[7] POWER SWITCH / COMMAND LINE ENABLED
0 REM LINE $12 STORES THE DEFAULT VALUE
0 REM z means unitializated
8 z

0 REM Debug settings
0 REM first char is for Z enabled/disabled
0 REM second char is for shell
0 REM third is for dumping states
0 REM fourth for Obex/ObexFTP
0 REM 0 48 Enabled only on command line
0 REM 1 49 Always enabled
0 REM 2 50 Always Disabled
9 0000

0 REM $10 stores our friendly name
10 AIRcableSMD

0 REM $11 stores our PIN
11 1234

0 REM DEFAULT pio settings IN ORDER
0 REM BLUE LED
0 REM GREEN LED
0 REM BUTTON
0 REM RS232 POWER OFF
0 REM RS232 POWER ON
0 REM DTR
0 REM DSR
0 REM POWER SWITCH / COMMAND LINE ENABLED
12 K0000000
0 REM DEBUG 12 A94B3566

0 REM PIO_IRQ SETTINGS
0 REM 13 only buttons pio, used for starting interrupts when there is
0 REM no connection going on
0 REM DEBUG 13 P000101000000
13 P000000000000
0 REM 14 button + DSR interrupt, interrupts that must be listened while
0 REM there is a connection going on
0 REM DEBUG 14 P000101000000
14 P000000000000

0 REM 15 is the settings for the uart when a connection is made
0 REM 0 means read from dip swithces
0 REM any other number is converted to an int.
15 1152

0 REM 16 this is the time that the Obex/ObexFTP will be available after
0 REM boot up
16 120

0 REM on variable I we store the baud rate setting.
0 REM this variable is initializated by @SENSOR
0 REM and is not setted until a connection is stablished


0 REM $20 is used for relay mode, it stores the master address
20 000000000000

0 REM $21 PIO_IRQ while off mode
0 REM DEBUG 21 P000010100000
21 P000000000000

0 REM $22 Stores the state previous to the Command Line Switch was activated
22 1110

0 REM $23 Stores the mode to which the module will switch once command line
0 REM switch is activated
23 1110

0 REM $39 RESERVED
39 RESERVED

0 REM THIS TURNS A CHAR AT $0[E] into
0 REM and integer in F
40 IF $0[E] > 57 THEN 43
41 F = $0[E] - 48;
42 RETURN
0 REM WE NEED TO ADD 10 BECAUSE "A" IS NOT 0
0 REM IS 10
43 F = $0[E] - 55;
44 RETURN


@INIT 45
45 Z = $9[0] - 48;
46 A = uart 1152
47 IF $9[2] = 48 THEN 49
48 PRINTU "@INIT\n\r";
49 IF $8[0] <> 122 THEN 57
50 $0[0] = 0
51 PRINTV $12
52 FOR E = 0 TO 7
53 GOSUB 40
54 $8[E] = F + 48
55 NEXT E
56 $8[8] = 0

57 $0[0] = 0;
58 PRINTV $10;
59 PRINTV " ";
60 A = getuniq $39;
61 PRINTV $39;
62 A = name $0;

63 H = 1

0 REM button as input
64 A = pioin ($8[2]-48);
0 REM bias pull up to high
65 A = pioset ($8[2]-48);
0 REM green LED output, off
66 A=pioout ($8[1]-48);
67 A=pioclr ($8[1]-48);
0 REM blue LED output, off
68 A=pioout ($8[0]-48)
0 REM RS232_off set, switch on RS232
69 A=pioout ($8[3]-48)
70 A=pioset ($8[3]-48)
0 REM RS232_on power on, switch to automatic later
71 A=pioout ($8[4]-48)
72 A=pioset ($8[4]-48)
0 REM DTR output set -5V
73 A=pioout ($8[5]-48)
74 A=pioset ($8[5]-48)
0 REM DSR input
75 A=pioin ($8[6]-48)
0 REM set DSR to IRQ so that PIO_IRQ is called
0 REM just button interrupts here
76 A=pioirq $13

0 REM start baud rate
77 A = baud 1152
78 A = nextsns 6
0 REM reset for pairing timeout
79 A = zerocnt
80 IF $9[2] = 48 THEN 82
81 PRINTU "Command Line ready

0 REM state initialize
82 IF $3[0] <> 90 THEN 84
0 REM newly updated BASIC program, goto SLAVE mode
83 $3 = $2;

0 REM init button state
84 W = 0

0 REM in idle mode we wait for a command line interface start
0 REM you must type a +++ and enter
0 REM blue LED off
85 A = pioclr ($8[0]-48)
86 J = 0

87 $3[3] = 48;

0 REM should go to mode dump
88 IF $9[2] = 48 THEN 90
89 GOSUB 575

0 REM let's start up, green LED on
90 A = pioset ($8[1]-48)

91 K = 1
0 REM now we go to @IDLE, and then we get into the @ALARM
92 H = 1
0 REM for Command Line Switch.
93 A = pioset $8[7]-48
94 A = pioin $8[7]-48
95 M = 0
96 GOSUB 800
97 IF H = 0 THEN 100
98 RESERVED
99 RETURN

0 REM Obex/ObexFTP timing handler
0 REM this code is also called from the command line on exit
100 B = readcnt
101 C = atoi $16
102 IF B < C THEN 109
103 GOSUB 106
104 H = 0
105 GOTO 150

106 IF $9[3] = 49 THEN 108
107 A = disable 3
108 RETURN

109 ALARM 30
110 GOTO 150

0 REM idle will be called, when the command line ends working
0 REM when the slave connection is closed, and when slave calls
0 REM timeouts, in any of those cases we will let the @ALARM
0 REM handle the slave mode stuff
0 REM idle used for slave connections, pairing or paired
@IDLE 120
120 IF $3[3] <> 48 THEN 128;
121 IF W <> 0 THEN 127;
122 IF K = 1 THEN 125;
123 IF K = 2 THEN 126;
0 REM lets trigger the alarm manually
124 GOTO 144;


125 A = slave-1;
126 K = 0;
127 RETURN

128 $3[3] = 48;
129 ALARM 1
130 RETURN

@PIN_CODE 140
140 IF $9[2] = 48 THEN 142
141 PRINTU "@PIN_CODE"
142 $0=$11;
143 RETURN

0 REM ALARM code, handles modes stuff, LEDs and long button press 
@ALARM 144
144 IF $9[2] = 48 THEN 146
145 PRINTU "@ALARM\n\r";


0 REM handle button press first of all.
146 IF W = 1 THEN 184


0 REM should go to mode dumping
147 IF $9[2] = 48 THEN 149
148 GOSUB 575

149 IF H = 1 THEN 100

150 IF $3[0] > 52 THEN 783

0 REM now the led stuff, and finally we handle the state.
0 REM firstly see if we are connected, then do what you need
151 B = status;
152 IF B < 10000 THEN 154;
153 B = B - 10000;
154 IF B > 0 THEN 156;
155 GOTO 160
0 REM ensure the leds are on
156 A = pioset ($8[0]-48);
157 A = pioset ($8[1]-48);
158 ALARM 5
159 RETURN

160 A = baud 1152
0 REM are we on automatic or manual?
161 IF $3[3] <> 48 THEN 685
0 REM we are on automatic.
0 REM are we on automatic - manual?
162 IF $3[0] = 48 THEN 179

0 REM LED SCHEMA:
0 REM CABLE 	SLAVE 	1 fast blink
0 REM SERVICE 	SLAVE 	2 fast blink
0 REM CABLE	MASTER 	3 fast blink
0 REM SERVICE	MASTER 	4 fast blink
163 A = pioset ($8[1]-48);
164 A = pioset ($8[0]-48)
165 A = pioclr ($8[0]-48);
0 REM are we on master or slave?
166 IF $3[0] > 50 THEN 171
0 REM ok we are on slave
0 REM CABLE 	SLAVE 1 fast BLINK
0 REM SERVICE 	SLAVE 2 fast BLINK

0 REM now are we on cable or service?
167 IF $3[1] = 48 THEN 222
0 REM service slave
168 A = pioset ($8[0]-48)
169 A = pioclr ($8[0]-48);
170 GOTO 211;

0 REM we are on master modes
171 FOR B = 0 TO 2
172 A = pioset ($8[0]-48)
173 A = pioclr ($8[0]-48)
174 NEXT B
175 IF $3[1] = 48 THEN 222;
176 A = pioset ($8[0]-48)
177 A = pioclr ($8[0]-48);
178 GOTO 213;


0 REM manual idle code, this is the only mode that ends here.
179 B = pioset ($8[1]-48);
180 B = pioclr ($8[0]-48);
0 REM little hidden feauture on $3[5], it is somesort of flag
0 REM that tell us if this is the first time that @IDLE is called
0 REM or the second, while we are on automatic-manual
181 A = slave-1;
182 K = 2
183 RETURN

0 REM this is a long button press, we have stuff to do
0 REM if we are connected, then we disconnect and reboot to unpaired
0 REM if we aren't then we must reboot and go to idle mode.
184 GOSUB 690;
185 W = 2
186 IF $39[3] = 49 THEN 198
187 IF $39[4] = 49 THEN 198

0 REM reboot 
188 $3[0] = 48
189 $3[1] = 48
190 IF $9[2] = 48 THEN 192
191 PRINTU"->Reboot\n\r";
192 A = pioclr($8[0]-48);
193 A = pioclr($8[1]-48);
194 W = 3
195 A = reboot
196 WAIT 3;
197 RETURN

0 REM disconnects, disconnect restarts @IDLE
198 ALARM 0
199 IF $9[2] = 48 THEN 201
200 PRINTU "-> Discconnect\n\r"
0 REM if we were paired, then we must unpair.
201 IF $3[0] = 50 THEN 204
202 IF $3[0] = 52 THEN 204
203 GOTO 205;
204 $3[0] = ($3[0] -1)
0 REM 307 A = disconnect 0
0 REM 308 A = disconnect 1
0 REM 309 A = cancel
205 $7 = "0"
206 GOTO 190

0 REM cable mode timeout
207 IF $9[2] = 48 THEN 209
208 PRINTU "Timeout\n\r";
209 ALARM 0;
210 GOTO 179;

0 REM automatic modes code.
0 REM service - slave:
211 A = slave 5;
212 RETURN

0 REM service - master
213 A = strlen $7;
214 IF A > 1 THEN 230
215 A = inquiry 6
216 ALARM 8
217 RETURN

218 A = master $7
0 REM master returns 0 if the connection was succesfull
0 REM or if we are still trying to connect.
219 IF A = 0 THEN 156
220 ALARM 8
221 RETURN

0 REM cable code, if we are not paired check for timeout.
222 IF $3[0] = 50 THEN 228
223 IF $3[0] = 52 THEN 218
224 B = readcnt
225 IF B > 120 THEN 207
226 IF $3[0] = 49 THEN 211
0 REM we are pairing as master,
227 GOTO 215;

228 A = slave -5;
229 RETURN

230 A = master $7
231 $7 = "0"
232 GOTO 219

0 REM this interrupt is launched when there is an incomming
0 REM slave connection
@SLAVE 240
240 A = pioget ($8[7]-48);
241 IF A = 1 THEN 280
242 IF $9[2] = 48 THEN 244;
243 PRINTU "@SLAVE\n\r";
244 IF $3[0] = 54 THEN 820;
0 REM if we are not on slave mode, then we must ignore slave connections :D
245 IF $3[3] = 50 THEN 268;
246 IF $3[0] > 50 THEN 271;
247 IF $3[0] > 48 THEN 249;
248 GOTO 271

249 A = getconn $7
0 REM if we are on service-slave, and the PIN was a success
0 REM then this is our peer.
250 IF $3[1] = 49 THEN 258
0 REM cable-slave-paired, check address
251 IF $3[0] = 50 THEN 255

0 REM set to paired no matter who cames
252 $3[0] = 50
253 $4 = $7
254 GOTO 258

0 REM check address of the connection and allow
255 $0 = $4
256 B = strcmp $7
257 IF B <> 0 THEN 271

0 REM slave connected
0 REM allow DSR interrupts
0 REM green and blue LEDS on
0 REM read sensors
258 A = nextsns 1
259 B = pioset ($8[1]-48)
260 B = pioset ($8[0]-48)
0 REM set RS232 power to on
261 A = pioset ($8[4]-48)
0 REM DTR set on, +5V
262 A = pioclr ($8[5]-48)
0 REM allow DSR interrupts
263 A = pioirq $14
0 REM connect RS232 to slave
264 IF $9[1]= 49 THEN 273
0 REM 376 A = baud I
265 ALARM 0
266 C = link 1
267 RETURN

268 PRINTU"\n\rCONNECTED\n\r
269 $3[3] = 53
270 GOTO 260

0 REM disconnect and exit
271 A = disconnect 0
272 RETURN

273 C = shell
274 RETURN

0 REM if PIO is on the user has 5 seconds to get into the command line
0 REM interface
280 TIMEOUTS 5
281 INPUTS $279
282 IF $279[0] <> 43 THEN 242
283 IF $279[2] <> 43 THEN 242
284 GOTO 452

@MASTER 346
0 REM successful master connection
346 IF $9[2] = 48 THEN 348
347 PRINTU "@MASTER\n\r";
348 IF $3[0] > 52 THEN 795
0 REM if we are on manual master, then we have some requests
349 IF $3[3] <> 52 THEN 354
350 $3[3] = 54
351 A = pioset ($8[1]-48);
352 A = pioset ($8[0]-48);
353 GOTO 362
0 REM if we are not on master modes, then we must avoid this connection.
354 IF $3[0] > 50 THEN 357;
355 IF $3[0] > 48 THEN 383;
356 IF $3[0] = 48 THEN 383;
357 A = pioset ($8[1]-48);
358 A = pioset ($8[0]-48);
0 REM don't switch state in service mode or manual
359 IF $3[3] = 52 THEN 380
360 IF $3[1] = 49 THEN 362
0 REM set state master paired
361 $3[0] = 52

0 REM read sensors
362 A = nextsns 1
363 A = pioset ($8[4]-48);
0 REM DTR set on
364 A = pioclr ($8[5]-48);
0 REM link
365 A = link 2
0 REM look for disconnect
366 ALARM 5
0 REM allow DSR interrupts
367 A = pioirq $14
368 IF $3[1] = 48 THEN 370
0 REM in service master clear buffer
369 $7 = "0";
370 RETURN

380 PRINTU"\n\rCONNECTED\n\r
381 $3[4] = 54
382 GOTO 362

383 A = disconnect 1
384 RETURN

0 REM $399 RESERVED
399 RESERVED
0 REM inquiry code, only in mode pair_as_master
@INQUIRY 400
400 $399 = $0
401 IF $9[2] = 48 THEN 403
402 PRINTU "@INQUIRY\n\r";
403 IF $3[3] <> 51 THEN 408
404 PRINTU"\n\rFound device: "
405 PRINTU $399
406 ALARM 4
407 RETURN

408 $4 = $399;
409 $399 = $0[13];
410 IF $3[0] <> 51 THEN 413;
0 REM inquiry filter active
411 IF $3[2] = 48 THEN 413;
412 IF $3[2] = 49 THEN 414;
413 RETURN

414 IF $9[2] = 48 THEN 417;
415 PRINTU "found "
416 PRINTU $4
0 REM check name of device
417 $0[0]=0;
418 PRINTV $399;
419 B = strcmp $5;
420 IF B <> 0 THEN 427;

0 REM found one, try to connect, inquiry canceled automaticall
0 REM 447 GOSUB 485;
421 B = master $4;
0 REM if master busy keep stored address in $4, get next
422 IF B = 0 THEN 428;
0 REM master accepted, store address, restart alarms, give it 8 seconds to connect
0 REM corrected by mn
423 $7 = $4;
424 ALARM 8;
0 REM all on to indicate we have one
425 A = pioset ($8[1]-48);
426 A = pioset ($8[0]-48);
427 RETURN

0 REM get next result, give the inq result at least 2 sec time
428 GOSUB 430;
429 RETURN

0 REM blink sub-routine pair as master mode, blue-on green-off and reverse
430 IF J = 1 THEN 435;
431 J = 1;
432 A = pioset ($8[0]-48);
433 A = pioclr ($8[1]-48);
434 RETURN
435 A = pioclr ($8[0]-48);
436 A = pioset ($8[0]-48);
437 J = 0;
438 RETURN;

@CONTROL 439
0 REM remote request for DTR pin on the RS232
439 IF $0[0] < 128 THEN 442
440 A = uartcfg$0[0]
441 RETURN
442 IF $0[0] = 49 THEN 444;
443 A=pioset ($8[5]-48);
444 RETURN;
445 A=pioclr ($8[5]-48);
446 RETURN


0 REM read from uart and echo function
0 REM on line 940 we have the other uart echo function.
0 REM result is on $529
0 REM 528, 448 RESERVED FOR TEMP
447 RESERVED
448 RESERVED
449 INPUTS $448;
450 GOTO 451;
451 RETURN

0 REM command line interface
452 ALARM 0
453 A = baud 1152
454 A = pioclr ($8[0]-48);
455 A = pioclr ($8[1]-48);
456 $3[3] = 49
0 REM enable FTP again
457 A = enable 3
458 PRINTS "\r\nAIRcable OS "
459 PRINTS "command line v
460 PRINTS $1
461 PRINTS "\r\nType h to "
462 PRINTS "see the list of "
463 PRINTS "commands";
464 PRINTS "\n\rAIRcable> "
465 GOSUB 677;
466 PRINTS"\n\r

0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM a: mode
0 REM o: obex
0 REM e: exit

0 REM help
467 IF $448[0] = 104 THEN 596;
0 REM info
468 IF $448[0] = 108 THEN 495;
0 REM name
469 IF $448[0] = 110 THEN 607;
0 REM pin
470 IF $448[0] = 112 THEN 617;
0 REM class
471 IF $448[0] = 99 THEN 621;
0 REM uart
472 IF $448[0] = 117 THEN 521;
0 REM date
473 IF $448[0] = 100 THEN 647;
0 REM shell
474 IF $448[0] = 115 THEN 688;
0 REM obex
475 IF $448[0] = 111 THEN 657;
0 REM modes
476 IF $448[0] = 97 THEN 534;
0 REM exit
477 IF $448[0] = 101 THEN 488;
0 REM name filter
478 IF $448[0] = 98 THEN 637;
0 REM addr filter
479 IF $448[0] = 103 THEN 642;
0 REM hidden debug settings
480 IF $448[0] = 122 THEN 484;
0 REM reboot
481 IF $448[0] = 114 THEN 680;
482 PRINTS"Command not found
483 GOTO 464;

484 PRINTS"Input settings: "
485 GOSUB 449
486 $9 = $448
487 GOTO 464

0 REM exit code, we end with slave-1 to ensure
0 REM that @SLAVE starts all again, and that
0 REM we start unvisible
488 PRINTS "Bye!!\n\r
489 GOSUB 106;
490 $3[3] = 48;
491 A = disconnect 0;
492 A = zerocnt
493 A = slave -1
494 RETURN

0 REM ----------------------- Listing Code ------------------------------------
495 PRINTS"Command Line v
496 PRINTS $1
497 PRINTS"\n\rName: ";
498 PRINTS $10;
499 PRINTS"\n\rPin: ";
500 PRINTS$11;
501 A = psget 0;
502 PRINTS"\n\rClass: ";
503 PRINTS $0;
504 PRINTS"\n\rBaud Rate: "
505 GOSUB 528
506 PRINTS"\n\rDate: ";
507 A = date $0;
508 PRINTS $0;
509 A = getaddr;
510 PRINTS"\n\rBT Address:
511 PRINTS $0
512 GOSUB 690;
513 PRINTS"\n\rBT Status:
514 PRINTS $39;
515 PRINTS"\n\rName Filter:
516 PRINTS $5;
517 PRINTS"\n\rAddr Filter:
518 PRINTS $6;
519 GOSUB 575
520 GOTO 464;

521 PRINTS"Enter new Baud Ra
522 PRINTS"te divide by 100,
523 PRINTS"or 0 for switches
524 PRINTS": "
525 GOSUB 449
526 $15 = $448
527 GOTO 464

528 IF $15[0] = 48 THEN 532
529 PRINTS $15
530 PRINTS "00 bps
531 RETURN
532 PRINTS "External
533 RETURN

0 REM -------------------------- Modes chooser --------------------------------
0 REM the user should select between
0 REM 0: Manual
0 REM 1: Service Slave
0 REM 2: Service Master
0 REM 3: Cable Slave
0 REM 4: Cable Master
0 REM Mode:
534 PRINTS"Select new mode\n
535 PRINTS"\r0: Manual\n\r1:
536 PRINTS" Service Slave\n
537 PRINTS"\r2: Service Mast
538 PRINTS"er\n\r3: Cable Sl
539 PRINTS"ave\n\r4: Cable M
540 PRINTS"aster\n\rMode: "
543 GOSUB 677;
544 IF $448[0] = 48 THEN 552;
545 IF $448[0] = 49 THEN 555;
546 IF $448[0] = 50 THEN 559;
547 IF $448[0] = 51 THEN 563;
548 IF $448[0] = 52 THEN 567;
549 IF $448[0] = 53 THEN 571;
550 PRINTS"\n\rInvalid Option
551 GOTO 464;

552 $3[0]=48;
553 $3[3]=49;
554 GOTO 810;
555 $3[0] = 49;
556 $3[1] = 49;
557 $3[3] = 48;
558 GOTO 810;
559 $3[0] = 51;
560 $3[1] = 49;
561 $3[3] = 48;
562 GOTO 810;
563 $3[0] = 49;
564 $3[1] = 48;
565 $3[3] = 48;
566 GOTO 810;
567 $3[0] = 51;
568 $3[2] = 49;
569 $3[3] = 48;
570 GOTO 810;
571 $3[0] = 53;
572 $3[1] = 50;
573 $3[2] = 48;
574 GOTO 810

0 REM -------------------------- Listing code ---------------------------------
575 PRINTS "\n\rMode: "
576 IF $3[0] > 52 THEN 594
577 IF $3[0] = 48 THEN 592
578 IF $3[1] = 48 THEN 581
579 PRINTS"Service - "
580 GOTO 582;
581 PRINTS"Cable - "
582 IF $3[0] >= 51 THEN 585;
583 PRINTS"Slave"
584 GOTO 586;
585 PRINTS"Master"
586 IF $3[0] = 50 THEN 590;
587 IF $3[0] = 52 THEN 590;
588 PRINTS"\n\rUnpaired"
589 RETURN
590 PRINTS"\n\rPaired"
591 RETURN
592 PRINTS"Idle"
593 RETURN
594 PRINTS"Relay Mode Master
595 RETURN

0 REM ----------------------- Help code ---------------------------------------
0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM o: obex, a: mode
0 REM e: exit, r: reboot
596 PRINTS"h: help, l: li
597 PRINTS"st\n\rn: name, p: "
598 PRINTS"pin, b: name filte"
599 PRINTS"r, g: address filt"
600 PRINTS"er\n\rc: class of "
601 PRINTS"device, u: uart, d"
602 PRINTS": date\n\ro: obex, "
603 PRINTS"a: mode, s: shell\n"
604 PRINTS"\re: exit, r: reboo
605 PRINTS"t"
606 GOTO 464;

0 REM Name Function
607 PRINTS"New Name: "
608 GOSUB 449;
609 $10 = $448;
610 $0[0] = 0;
611 PRINTV $10;
612 PRINTV " ";
613 A = getuniq $39;
614 PRINTV $39;
615 A = name $0;
616 GOTO 464

0 REM Pin Function
617 PRINTS"New PIN: ";
618 GOSUB 449;
619 $11 = $448;
620 GOTO 464

621 PRINTS"Type the class of "
622 PRINTS"device as xxxx xxx"
623 PRINTS"x: "
624 GOSUB 449
625 $0[0] = 0;
626 PRINTV"@0000 =
627 PRINTV$448;
628 $448 = $0;
629 A = psget 0;
630 $447 =$0
631 $0[0]=0;
632 PRINTV $448;
633 $448 = $447[17]
634 PRINTV $448;
635 A = psset 3
636 GOTO 464

0 REM friendly name filter code
637 PRINTS"Enter the new name"
638 PRINTS" filter: "
639 GOSUB 449
640 $5 = $448
641 GOTO 464;

0 REM addr filter code
642 PRINTS"Enter the new addr"
643 PRINTS"ess filter: "
644 GOSUB 449
645 $6 = $448
646 GOTO 464

0 REM date changing methods
647 PRINTS"Insert new dat
648 PRINTS"e, check the manua
649 PRINTS"l for formating: "
650 GOSUB 449;
651 A = strlen $448
652 IF A <> 16 THEN 655
653 A = setdate $448
654 GOTO 464
655 PRINTS"\n\rInvalid format
656 GOTO 464

0 REM activate Obex/ObexFTP
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
657 PRINTS"Obex/ObexFTP setti"
658 PRINTS"ngs:\n\r0: Enabled "
659 PRINTS"only on command li"
660 PRINTS"ne\n\r1: Always Ena"
661 PRINTS"bled\n\r2: Always D"
662 PRINTS"isabled\n\rChoose "
663 PRINTS"Option: "
664 GOSUB 677
665 939 $9[3] = $448[0]
666 IF $448[0] = 50 THEN 672
667 $0[0] = 0
668 A = psget 6
669 $0[11] = 48
670 A = psset 3
671 GOTO 464
672 $0[0] = 0
673 A = psget 6
674 $0[11] = 54
675 A = psset 3
676 GOTO 464

0 REM one char read function
677 A = 1
678 INPUTS $448
679 RETURN

0 REM reboot code
680 PRINTS"Rebooting, please "
681 PRINTS"do not disconnect "
682 PRINTS"electric power\n\r
683 $3[3] = 48

684 A = disconnect 0
685 A = reboot
686 WAIT 2
687 RETURN

688 A = shell
689 RETURN

0 REM convert status to a string
0 REM store the result on $44
690 B = status
691 $39[0] = 0;
692 $39 = "00000";
693 IF B < 10000 THEN 696;
694 $39[0] = 49;
695 B = B -10000;
696 IF B < 1000 THEN 699;
697 $39[1] = 49;
698 B = B -1000;
699 IF B < 100 THEN 702;
700 $39[2] = 49;
701 B = B -100;
702 IF B < 10 THEN 705;
703 $39[3] = 49;
704 B = B -10;
705 IF B < 1 THEN 707;
706 $39[4] = 49;
707 $39[5] = 0;
708 RETURN

@PIO_IRQ 800
800 A = pioget ($8[7]-48);

801 IF A = 1 THEN 804

802 $3 = $22
803 GOTO 806

804 $22 = $3
805 $3 = $23

806 A = disconnect 0
807 A = disconnect 1
808 ALARM 1
809 RETURN

0 REM called from command line on mode changing
810 A = pioget ($8[7]-48);
811 IF A = 1 THEN 814
812 GOTO 464
814 $22 = $3
815 $3 = $23
816 GOTO 464


```