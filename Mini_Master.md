Tutorial 1 - Mini Master Code.

# Introduction #

Welcome back, in this series of tutorial we will show you how to handle the Master Channel of our Bluetooth _OS Enabled_ devices. Master Channel is a bit more difficult to handle than the Slave Channel but it is not impossible to do. In this first tutorial we will show you the most basic stuff you can do over the Master Channel, you will see the differences between both, and the things they both have in common. By the end of this tutorial you should be able to make a _basic_ cable replacement with two _OS Enabled_ devices (one in Master and the other in Slave)

Basically this code will use _Alarms_ to control the flow of the code. Then you will also see how to make inquires, how to handle them and finally how to make master connections.

So let's put hands on work.

# Code #
```
@ERASE

0 REM Line $1 discovered device buffer
1 0

@INIT 50
0 REM debug
50 Z = 0 
0 REM empty discovered device buffer.
51 $1 = "0"
52 A = slave -1
0 REM J stores the pio where the led is attached
53 J = 20
0 REM LED output an don
54 A = pioset J
55 A = baud 96
0 REM E will be used for state
0 REM E = 0 disconnected
0 REM E = 1 connected
56 E = 0
57 RETURN

@IDLE 60
60 ALARM 1
61 RETURN

@ALARM 100
0 REM we need to start an inquiry
0 REM blink leds
100 IF E = 1 THEN 150
101 A = pioset J;
102 A = pioclr J
103 ALARM 6
104 A = strlen $1
105 IF A > 11 THEN 130
106 A = inquiry 5
107 RETURN

0 REM a device has been discoverd, let's try to connect
130 A = pioset J
131 A = master $1
132 ALARM 6
133 $1 = "0
134 RETURN

0 REM we are connected, lets check we are still connected
150 A = status
151 IF A = 0 THEN 155
152 ALARM 10
153 RETURN

0 REM we were disconencted
155 $1 = "0
156 A = pioclr J
157 ALARM 1
158 E = 0
159 A = unlink 3
160 RETURN

@INQUIRY 200
0 REM when this interrupt gets called we have on $0 an string like this:
0 REM 00112233445566 NAME where the number is the bt address.
200 $1 = $0
201 A = pioset J;
202 A = pioclr J
203 A = pioset J;
204 A = pioclr J
205 ALARM 1
206 RETURN

@MASTER 300
300 E = 1
301 A = pioset J
302 C = link 2
303 RETURN
```

[Download File](http://aircable.googlecode.com/svn/examples/micro_master/AIRcable.bas)

# Explanation #
As you can see this code is much more extend that the _Micro Slave_. This is because master operations are much more complex than slave operations. Let's try to _decode_ the code, firstly there are three things you might notice on the **@INIT** first we have **_slave -1_** this is done because we don't want the master device to be discoverable, second we have _**$1 = "0**_ this is an string assignment what we do here is make sure the $1 has only one char, as you will see next $1 is used to store the last discovered device address. And finally we have **_J = 20 ... pioset J_** what are we doing here? Simple we store the _PIO_ number of the led on a numerical variable and then instead of doing **_pioset 20_** we just do **_pioset J_**, if you are going to target only one kind of _AIRcable OS_ device this is not very usefull, but if you want a code that can be _portable_ between our brand of products this is a good option to take into account, you can check the [command line code](http://aircable.googlecode.com/svn/trunk/AIRcable.bas) for more advanced led handling.

Then you will notice that the **_@IDLE_** only has one line **_60 ALARM 1_** this command schedules the alarm to be triggered in 1 second. We do it this way because **_@IDLE_** will not be called again when the master channel is closed.

Now lets focus on the **_@ALARM_**:
```
@ALARM 100
0 REM we need to start an inquiry
0 REM blink leds
100 IF E = 1 THEN 150
101 A = pioset J;
102 A = pioclr J
103 ALARM 6
104 A = strlen $1
105 IF A > 11 THEN 130
106 A = inquiry 5
107 RETURN

0 REM a device has been discoverd, let's try to connect
130 A = pioset J
131 A = master $1
132 ALARM 6
133 $1 = "0
134 RETURN

0 REM we are connected, lets check we are still connected
150 A = status
151 IF A = 0 THEN 155
152 ALARM 10
153 RETURN

0 REM we were disconencted
155 $1 = "0
156 A = pioclr J
157 ALARM 1
158 E = 0
159 A = unlink 3
160 RETURN
```

As you can see firstly we check if we are connected or not (we are actually checking our _saved_ state not the bluetooth status, so this is not accurate, but is very usefull). If we are not connected we have two posibilities to happen one is that we need to inquiry in which case we do inquiry **_inquiry 5_**, the other posibility is that we had discovered a device and we try to connect to it **_master $1_**. You might ask your self wy do we check if the $1 length is over 11 characters, easy each bluetooth address is 12 characters long, when the _**@INQUIRY**_ interrupt is called it dumps into $0 the Bluetooth Address plus the name of the device, as we don't sepparate the address from the name we need to check the length to be over 11.

If you check the **_@ALARM_** code you will notice that no matter what happens before a _**RETURN**_ there is an **ALARM** schedulling. Why we do this? The cause is quite simple alarms are not triggered automatically, and we need a way to control the flow of the code, well this is the way we use to do it.

The last interesting part in _**@ALARM**_ is **_A = status_** this command is used to get the bluetooth processor status, check the [documentation](http://docs.google.com/View?docid=dcvjvpkp_40c6nw49) for more info on **_status_**. There is a last thing regarding this piece of code and that is _**unlink 3**_ we use this to make sure the Master Channel is _unliked_ from the Serial Port.

Finally you have _**@INQUIRY**_ and _**@MASTER**_, _**@INQUIRY**_ is called once the inquiry process has ended and when there has been devices discovered, take special care with this interrupts because it is very sensistive and can loose results if the processor is busy on the momemnt the _**inquiry**_ command ends.