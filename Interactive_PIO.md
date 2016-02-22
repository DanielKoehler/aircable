Tutorial 1 - Interactive Code, PIO Handling Introduction.

# Introduction #

Welcome back, in this example we will show you how to write interactive code, and will introduce to you the basis of Digital/Analogic lines handling.

Some times you might need that human users interact with your bluetooth devices. Even thought this task can be hard to achieve, with a series of tips and things to take into account this can be really easy. In this example we will write a piece of code that will give the user a shell interaction (like the old DOS, or BASH from Unix systems), this shell will be available on the Slave channel, and will be accesible to anyone.

The shell is quite basic and request user iteraction to be usefull, once the slave channel is opened the user will see the welcome message and the prompt:
```
Welcome, press h to see the list o f commands
COMMAND >
```

As you can see from the very first moment, the shell is quite intuitive to the human beeing. This shell can be used to change the state of PIOs (turn on/off), read PIOs, read the digital inputs and close the slave connection.

Here you have the code:

# Code #
```
@ERASE

@INIT 50
0 REM debugging information will be dumped to the SERIAL port
50 Z = 0
51 J = 20
52 A = pioset J
53 RETURN

@IDLE 100
100 A = slave 5
101 A = pioset J
102 A = pioclr J
103 RETURN

@SLAVE 150
150 A = pioset J
151 ALARM 1
152 PRINTS"Welcome, press h"
153 PRINTS" to see the list o 
154 PRINTS"f commands\n\r
155 PRINTS"COMMAND > "
156 RETURN

0 REM this function reads a character and stores it on E

@ALARM 200
200 TIMEOUTS 5
201 INPUTS $0
202 A = strlen $0
203 IF A > 0 THEN 210
204 ALARM 1
205 RETURN

207 ALARM 1
208 PRINTS"COMMAND > "
209 RETURN

0 REM this is the command dispatcher
0 REM help
210 IF $0[0] = 104 THEN 250
0 REM turn on a PIO
211 IF $0[0] = 111 THEN 270
0 REM turn off a PIO
212 IF $0[0] = 102 THEN 275
0 REM read a PIO
213 IF $0[0] = 114 THEN 280
0 REM read digital line
214 IF $0[0] = 100 THEN 290
0 REM close connection
215 IF $0[0] = 99 THEN 295
216 PRINTS"Invalid Command\n\r
217 GOTO 207

0 REM This is the help command
0 REM h help
0 REM o turn on a PIO
0 REM f turn off a PIO
0 REM r read a PIO
0 REM d read digital line
0 REM c close connection
250 PRINTS"h help\n\ro turn on
251 PRINTS" a PIO\n\rf turn of
252 PRINTS"f a PIO\n\rr read a
253 PRINTS" PIO\n\rd read digi
254 PRINTS"tal line\n\rc close
255 PRINTS" connection\n\r
256 GOTO 207

0 REM turn on a PIO
260 PRINTS"Enter the PIO "
261 PRINTS"Number: "
262 INPUTS $0
263 A = atoi $0
264 RETURN

270 GOSUB 260
271 B = pioset A
272 GOTO 207

275 GOSUB 260
276 B = pioclr A
277 GOTO 207

280 GOSUB 260
281 B = pioget A
282 PRINTS"VALUE: "
283 PRINTS B
284 PRINTS"\n\r
285 GOTO 207

290 A = nextsns 1
291 RETURN

295 PRINTS"Bye Bye\n\r"
296 A = disconnect 0
297 A = slave 1
298 RETURN

@SENSOR 300
300 PRINTS"\n\rSENSOR"
301 PRINTS" READING: "
302 A = sensor $0
303 PRINTS $0
304 PRINTS "\n\r
305 ALARM 3 
306 GOTO 208
```

[Download File](http://aircable.googlecode.com/svn/examples/interactive_code/AIRcable.bas)

# Explanation #
We will divide the explanations in two parts, on one side we will explain how you can handle PIOs and on the onther hand we will explain the interactive part itself.

## Interactive Stuff ##
Basically an interactive program must have a data output to the user, and the user must be able to input data to the program. To output data we decide to use _PRINTS_ this command sends the string given as argument to the slave channel. Output is not a hard stuff, but Input can be very sensitive, for input we had user _INPUTS_ this command will read from the slave channel and will echo those characters to the slave channel. The input command by itself will wait for an infinite time until the user inputs something, this can be a problem sometimes that's why I added a timeout to the command.

There are some things you have to take into account before writting interactive code, one thing is time outs if you don't define a time out the bluetooth processor will be always "stucked" trying to read from the input. Another thing you have to take into account is processor overloading, take into account that the bluetooth processor is not a Desktop processor so overload will make it not only loose some interrupts but also will waste lots of energy.

## PIOs Introduction ##
We had made some work with PIOs before, we had turn on/off leds, well basically a PIO is a digital line which is connected to the procesor, over which you have control. On the example you can see how to Turn On/Off (_**pioset**_, _**pioclr**_), read (_**pioget**_), and how to handle the analog line. The analog line needs some more work than the digital one, before reading the analog line you need to schedule the reading of it by using **_nextsns_** then you can get the value of it on the _**@SENSOR**_ interrupt.