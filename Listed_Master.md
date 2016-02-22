Tutorial 3 - Listed Master Code.

# Introduction #

Welcome back, in this example we will do a totally new thing. On this example we will see how to create an automated data distpatcher, that will connect to a predefined list of devices. You will also learn how to write data to the Master and UART port.

Here take a look at the code:

# Code #
```
@ERASE

0 REM Lines between 1 and 48 are used for peer address
0 REM simply write on those lines the address you want to get connected
0 REM on future examples we will add a menu to make this more interactive
0 REM the last line must end with ZZ
1 112233445566
2 AABBCCDDEEFF
3 123456789ABC
4 AEC123546879
5 0015E9F5BAFE
6 000A8400035D
7 ZZ


0 REM DO NOT MODIFY LINE 49
49 ZZ
@INIT 50
0 REM debug
50 Z = 0
0 REM E will be our address pointer, so let's make it target the first device
51 E = 1
52 A = slave -1
0 REM J stores the pio where the led is attached
53 J = 20
0 REM LED output and on
54 A = pioclr J
55 A = baud 96
56 RETURN

@IDLE 60
60 ALARM 1
61 RETURN

@ALARM 90
90 A = readcnt
91 IF A > 30 THEN 100
92 A = pioset J;
93 A = pioclr J
94 ALARM 5
95 RETURN

100 $0 = $E
101 A = strcmp $49
102 IF A <> 0 THEN 110
103 E = 1
104 ALARM 1
105 RETURN

0 REM in case we are still connected
110 A = disconnect 1
111 A = unpair $E
112 A = master $E
113 PRINTU "CONNECTING: "
114 PRINTU $E
115 PRINTU "\n\r
116 E = E + 1
0 REM let's give time enough to work
117 ALARM 5
118 A = zerocnt
119 RETURN

0 REM let's do something simple, we send it's own bt address to each device
0 REM we get connected
@MASTER 300
300 A = pioset J;
301 PRINTU "CONNECTED TO: "
302 PRINTU $(E-1)
303 PRINTU "\n\r
304 PRINTM "HELLO 
305 PRINTM $(E-1)
306 PRINTM "\n\r
307 PRINTM "I AM "
308 A = getaddr
309 PRINTM $0
310 A = disconnect 1
311 A = pioclr J;
312 ALARM 2
313 RETURN

```

[Download File](http://aircable.googlecode.com/svn/examples/listed_master/AIRcable.bas)

# Explanation #
As you can see this example is a mixture of all what we had seen before, it only adds a couple of commands. The first new command you will see is **_unpair_**, unpair is used to erase the link key from the bluetooth processor, we do this because we have a limit of 8 paired devices at the time.

The next new thing you will notice is **_PRINTU_** and **_PRINTM_** those commands print the string given as argument to the **UART** and **MASTER** channel respectively.

_**NOTE:** This code will take 30 seconds to start, but once it has started it will connect to each device until the unit is turned off, the connection cycle is 30 seconds per device._