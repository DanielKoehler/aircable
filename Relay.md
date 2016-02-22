Tutorial 1 - Relay Code

# Introduction #

In this short tutorial we will show you how easy is to make one of your AIRcable OS devices relay data from one device to another, making a network of bluetooth devices.

Basically what we will do in this example is linking the slave channel to the master channel so that our device is only a bridge between them, giving them longer ranges.

Like before, here is the code:

# Code #
```
@ERASE

0 REM Line $1 stores the slave peer address.
1 0015E9F5BAFE

0 REM E is the state variable
0 REM E = 0 means slave disconnected
0 REM E = 1 slave connected - master connecting
0 REM E = 2 slave connected - master connected

@INIT 50
50 Z = 1
51 E = 0
52 J = 10
53 RETURN

@IDLE 100
100 GOTO 200

@SLAVE 150
150 E = 1
151 ALARM 1
152 RETURN

@MASTER 160
160 A = link 3
161 E = 2
162 ALARM 10
163 A = pioset J
164 RETURN

@ALARM 200
200 IF E = 0 THEN 210
201 IF E = 1 THEN 220
202 IF E = 2 THEN 230
203 RETURN

210 A = pioset J
211 A = pioclr J
212 A = slave 5
213 RETURN

220 A = pioset J;
221 A = pioclr J
222 A = master $1
223 ALARM 6
224 RETURN

230 A = status
231 IF A < 10000 THEN 233
232 A = A - 10000
233 IF A < 1000 THEN 235
234 A = A - 1000
235 IF A < 100 THEN 237
236 A = A - 100
237 IF A <> 11 THEN 280
238 ALARM 10
239 RETURN

280 A = disconnect 0
281 A = disconnect 1
282 E = 0
283 ALARM 1
284 RETURN

```

[Download File](http://aircable.googlecode.com/svn/examples/relay_code/AIRcable.bas)

# Explanation #
Basically we only introduce one thing here **_link 3_** which links the slave channel to the master channel. What we do here is quite easy, we open the slave channel wait for a connection, and once someone connected to us on the slave channel we start a master connection to the stored address in $1.

Once the master connection is stablished we link both channels. Then we simply check the connection status, if any of the channels gets closed we close the other and start the process again.

Off course this example can be extended to a more usefull code, for example you can add a command line to set the stored address, or you can make the slave channel unvisible to make relay networks more secure.