Tutorial 4 - Restrictive Slave Code.

# Introduction #
This is the fourth example of the series of tutorials related to slave channel handling. This example will improve the third example, by adding pairing with other devices and making slave channel invisible. You will also learn how to use the internal clock for measuring time.

# Code #
```
@ERASE

0 REM Line $1 will store the address filter we are going to target
1 000A

0 REM Line $2 will store the peer address
2 0

@INIT 10
0 REM LED output and on
10 A = pioset 20
11 A = baud 96
0 REM debug
12 Z =  0
0 REM We need to intializate the state
0 REM if $2 lenght is not 12 then we don't have been paired before
0 REM E shows our state
0 REM E = 0 means upaired
0 REM E = 1 means paired
0 REM E = 2 means unpaired time out
13 A = strlen $2
14 IF A = 12 THEN 18
15 E = 0
16 A = zerocnt
17 RETURN
18 E = 1
19 RETURN


@IDLE 30
0 REM blink LED
30 A = pioset 20;
31 A = pioclr 20
32 IF E = 0 THEN 40
33 IF E = 1 THEN 50
34 IF E = 2 THEN 60
35 RETURN


0 REM unpaired
0 REM check time
40 B = readcnt
41 IF B > 120 THEN 45
0 REM no timeout
42 A = slave 5
43 RETURN

0 REM timeout, here we can do some stuff
0 REM we end with slave-1 to make the device undiscoverable
45 E = 2
46 A = slave-1
47 RETURN

0 REM we are paired, let's tell the user we are paired by blinking the leds
50 A = pioset 20;
51 A = pioclr 20
0 REM slave undiscoverable for 5 seconds
52 A = slave -5
53 RETURN

0 REM unpaired timeout we can end here.
60 RETURN


@SLAVE 100
0 REM firstly we need to choose where do we go
100 A = getconn 
101 IF E = 0 THEN 105
102 IF E = 1 THEN 150
103 IF E = 2 THEN 140
104 RETURN

0 REM we are not paired check filter

105 A = strcmp $1;
106 IF A <> 0 THEN 140

0 REM this device has passed the filter so we need to mark we are paired
107 $2 = $0
108 E = 1
0 REM 5 seconds timeout to start shell with '+' and enter
0 REM when you have a slave connection over air
109 TIMEOUTS 5
110 INPUTS $0
111 IF $0[0] = 43 THEN 120
0 REM LED on
112 B = pioset 20
0 REM connect RS232
113 C = link 1
114 RETURN

0 REM start BASIC shell
120 A = shell
0 REM LED on
121 B = pioset 20
122 RETURN

140 A = disconnect 0
141 RETURN

150 A = strcmp $2
151 IF A <> 0 THEN 140
152 GOTO 109

```

[Download File](http://aircable.googlecode.com/svn/examples/restrictive_slave/AIRcable.bas)

# Explanation #
If you take a deep look at the code, you will notice that it is not much different from the Filtered Service Slave. In fact it is not more than an upgrade of that code that adds some new functionalities like: State handling, Undiscoverable mode for Slave Channel, Code Jumps (_GOTO_) and Time Handling.

We have three different states (maybe more, but we just need to have control over three only) those states are: device is not paired and there is no timeout, device is not paired and there has been a timeout, device is paired. Each one of those states make the device behave on a different form, this states are coded on the numerical variable **E**.

So if **E = 0** that means that the device has not been paired yet and there has been no timeouts, in this state we need to open the slave channel in discoverable mode **_slave 5_** and check the counter (**_readcnt_**) for timeouts. **_zerocnt_** on the **_@INIT_** help us to be sure that the counter is on **0** when the process starts, this counter will be incremented on one, once each second.

Then if **E = 1** than means we are paired, we blink the leds again, and open the slave channel but on undiscoverable mode **_slave -5_**, this feauture is really usefull. Suppose you want a network of data loggers in a supermarket, you don't want that every costumer can _see_ your network, only _you_ need to get access to it, well this is a way to achieve that goal.

Finally if **E = 2** then the device is unpaired and had reached the time. In this state we simply open the slave channel for 1 seconds in undiscoverable mode _**slave -1**_. For security reasons it is very important to always run _**slave -1**_ when you want your devices to be no longer discoverable.

_**NOTE:** Making your device undiscoverable means that none device will be able see it anymore, this doesn't mean that you will not be able to connect to it, you will just not be able to see the device, this means that if you want to upload new programs to the device you will need to know the bluetooth address of it. A suggestion on this cases is opening an slave connection to the device and press **+** when the connection is opened, to get into the shell, once inside there do **slave 15** so you can see the device again. Another way to solve this problem is doing a BASIC code erase, depending on your device you will be able or not, check your documentation for further information_

The last thing I want to mention is the use of **_GOTO_** on the last line. **_GOTO_** is a reserved word that will make the BASIC procesor jump from the actual line to the _target_ line.