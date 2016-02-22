Tutorial 2 - Little Slave Code.

# Introduction #

On this tutorial we will improve the Mini Slave Code by adding leds handling, user interaction and shell connection.

First of all lets see the code.

# Code #
```
@ERASE

@INIT 10
0 REM LED output and on
10 A = pioset 20
11 A = baud 96
0 REM debug
12 Z = 0
14 RETURN

@IDLE 15
0 REM blink LED
15 A = pioset 20;
16 A = pioclr 20
0 REM slave for 5 seconds
17 A = slave 5
18 RETURN


@SLAVE 20
0 REM 5 seconds timeout to start shell with '+' and enter
0 REM when you have a slave connection over air
20 TIMEOUTS 5
21 INPUTS $0
22 IF $0[0] = 43 THEN 26
0 REM LED on
23 B = pioset 20
0 REM connect RS232
24 C = link 1
25 RETURN

0 REM start BASIC shell
26 A = shell
0 REM LED on
27 B = pioset 20
28 RETURN

```

[Download File](http://aircable.googlecode.com/svn/examples/small_slave/AIRcable.bas)

# Explanation #
If you compare this code against the **[Micro Slave](http://code.google.com/p/aircable/wiki/Micro_Slave)** you will see some differences. For example you will see lots of lines that start with **0 REM**, those lines are comments and will not be used by the BASIC processor.


First of all the **@INIT** has changed it adds two new lines:
```
10 A = pioset 20
11 A = baud 96
```
The first line will turn on the LED from the SMD or Mini (change this on other devices), and the second one sets the serial port baud rate to 9600 bps.


Then on the **@IDLE** you have another change:
```
15 A = pioset 20;
16 A = pioclr 20
```
Those lines turns on the LED and then turn it off. Take a look at the ending of the line _15_, this line ends with **;** this ending tells the BASIC process to execute the line that is next to it in a higher priority.

Finally, the most interesting changes are inside of the **@SLAVE** interrupt:
```
@SLAVE 20
0 REM 5 seconds timeout to start shell with '+' and enter
0 REM when you have a slave connection over air
20 TIMEOUTS 5
21 INPUTS $0
22 IF $0[0] = 43 THEN 26
0 REM LED on
23 B = pioset 20
0 REM connect RS232
24 C = link 1
25 RETURN

0 REM start BASIC shell
26 A = shell
0 REM LED on
27 B = pioset 20
28 RETURN
```
Those lines starts by setting a timeout to the Slave Channel, this is important with out this timeout the BASIC parser will hang up until it receives an end of line over the slave channel. Then you have a line that reads from the slave channel and puts that input on the string $0. The next line compares the first character of the input to be equal '+', there is something very important here you can't compare against a character you need to compare against the ASCII value of the character. If the compare is true it goes to line 26 connects the shell to the slave channel and turns on the LED, if the compare is false it will go to the next line link the Slave channel with the UART channel and turn on the led.

This is another version of a Mini slave program. This one switches off the FTP service after 20 seconds.

# Code #
```
@ERASE

@INIT 10
0 REM LED output and on
10 A = pioset 20
11 A = baud 384
0 REM debug
12 Z = 0
13 A = zerocnt
14 $0="CAS "
15 A = getuniq $2
16 PRINTV $2
17 A = name $0
18 G = 0
19 RETURN

@SLAVE 30
0 REM LED on
31 B = pioset 20
0 REM connect RS232
32 C = link 1
33 RETURN


@IDLE 55
0 REM slave for 5 seconds
55 A = slave 5
0 REM blink LED
56 A = pioset 20;
57 A = pioclr 20;
58 A = pioset 20;
59 A = pioclr 20;

60 IF G = 1 THEN 65
61 D = readcnt
62 IF D < 20 THEN 65
63 A = disable 3
64 G = 1
65 RETURN
66


```