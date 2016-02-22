# Introduction #

The AIRcable OS supports both **DUN Dial-Up Networking** and **SPP Serial Port Profile**
profiles for the slave channel. The first profile is used to share internet connections
specially in cell phones, and the second one is more generic and is used to emulate
wireless serial cables. But as both profiles run over the slave connection the **AIRcable
OS can't do both at the same time**.

Even though those two profiles seems very different, they are actually exactly the same,
furthermore there's no difference in the way they are implemented. So you might ask
why we need DUN if we all ready have SPP. The BlueTooth SIG (the associaton that
defines the BlueTooth standards) decided this just to make a difference, the first
one must assure that you can access to a network for examples you can can access the GPRS
connection of a modem with this profile, while the second is more generic and shouldn't
be used to access networks like intranets or the internet.

The AIRcable OS supports both protocols, so for example, you can attach a serial modem
to the AIRcable, and then show this service to others and allowing them to access. Take
into account that this is not a WiFI replacement or anything like that. You will never
get such a bandwith over BlueTooth. But in some scenarios it's worth to consider this
possibility when needing to give network access to others.

This code is quite simple. It can show either SPP or DUN profiles. The user can choose
to show either one or the other. When ever a new slave connection is stablished
the user has 5 seconds to get into a command line that allows you choose between them.
In order to access to the command line you have to press **+++** if you don't press **+++**
then that string will be sent to the UART, and the code will link the slave to the UART.

Ok that's enough chatter, here's the code:

# Code #
[Download](http://aircable.googlecode.com/svn/examples/dun_spp/AIRcable.bas)
```
@ERASE

0 REM DUN - SPP example
0 REM this example will show you how to work with both 
0 REM SPP to DUN profile

0 REM $1 state
0 REM $1[0] = 48 SPP
0 REM $1[0] = 49 DUN
1 0

0 REM this code fits the SMD, change the PIO if you want

@INIT 19
19 Z = 1
0 REM set uart
20 A = baud 1152
21 J = 20
0 REM LED
22 A = pioout J
23 A = pioclr J
0 REM set name to something different than factory.
24 A = name "AIRcable"
0 REM give time to INIT to end
25 WAIT 3
26 RETURN

@IDLE 50
0 REM switch profile
50 IF $1[0]=49 THEN 60

0 REM slave
51 A = slave 5
52 A = pioset J
53 A = pioclr J
54 RETURN


0 REM DUN profile
60 A = dialup 5
61 A = pioclr J
62 A = pioset J
63 RETURN

@SLAVE 100
0 REM turn on led
100 A = pioset J
0 REM do you want to start command line
101 TIMEOUTS 5
102 INPUTS $0
103 A = strlen $0
104 IF $0[A-3]=43 THEN 110

0 REM the user didn't wanted to start the command line
105 IF A = 0 THEN 107
106 PRINTU $0
107 A = link 1
108 RETURN

0 REM give the user a simple command line
110 PRINTS"Welcome\n\r"
111 PRINTS"Profile:\n\r"
112 PRINTS"1 - SPP\n\r"
113 PRINTS"2 - DUN\n\r"
114 PRINTS"Option: "

0 REM let's check the input
115 INPUTS $0
116 IF $0[0] = 49 THEN 130
117 IF $0[0] = 50 THEN 140
0 REM sorry wrong option
118 PRINTS"\n\rInvalid "
119 PRINTS"Option\n\r
120 GOTO 110

0 REM SPP choosen
130 $1="0"
132 PRINTS"Bye, bye"
133 A = disconnect 0
134 RETURN

0 REM DUN choosen
140 $1="1"
141 GOTO 132
```

As always feel free to contact us if you have any further question.