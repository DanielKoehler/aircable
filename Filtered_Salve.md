Tutorial 3 - Filtered Slave Code.

# Introduction #
This is the third example of the series of tutorials related to slave channel handling. This example will now focus on security. When a device gets an slave request it can ask some information from it's other peer, actually it can ask for the peer Bluetooth address. What this example do is simple, it will check that the address from the peer starts with a defined pattern.

You will also see how to compare two strings, and how to define constant strings.

As always firstly you will see the code

# Code #
```
@ERASE

0 REM Line $1 will store the address filter we are going to target
1 00A8FF

@INIT 10
0 REM LED output and on
10 A = pioset 20
11 A = baud 96
0 REM debug
12 Z = 1
14 RETURN

@IDLE 15
0 REM blink LED
15 A = pioset 20;
16 A = pioclr 20
0 REM slave for 5 seconds
17 A = slave 5
18 RETURN


@SLAVE 20
0 REM If we now call to getconn, we will get the peer addr that wants to connect
0 REM with us on $0
20 A = getconn
21 PRINTU $0
22 A = strcmp $1;
23 IF A <> 0 THEN 33
0 REM 5 seconds timeout to start shell with '+' and enter
0 REM when you have a slave connection over air
24 TIMEOUTS 5
25 INPUTS $0
26 IF $0[0] = 43 THEN 30
0 REM LED on
27 B = pioset 20
0 REM connect RS232
28 C = link 1
29 RETURN

0 REM start BASIC shell
30 A = shell
0 REM LED on
31 B = pioset 20
32 RETURN

33 A = disconnect 0
34 RETURN

```

[Download File](http://aircable.googlecode.com/svn/examples/filtered_service_slave/AIRcable.bas)

# Explanation #
The first thing that you can notice is this line: _1 00A8FF_ this line defines a constant string. If you want to define constant that don't include spaces this is a good way to achieve it.

The other thing that is new is this piece of code:
```
20 A = getconn
21 PRINTU $0
22 A = strcmp $1;
23 IF A <> 0 THEN 33
```
When ever there is an incomming connection on the slave channel you can call getconn to get the device address that wants to connect with this device on $0. Once we have this information we compare it with $1 which is the string we are going to use as filter. If the string comparisson (strcmp) is equal to 0 that means that both string start with the same pattern, which means to us that the peer matches our filter.