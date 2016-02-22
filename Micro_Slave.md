Tutorial 1 - Micro Slave Code.

# Introduction #

On this tutorial we will show you a very simple slave code, which you can use as a base for developing your own solutions or use it as is if you want.

This example is very simple, it is hard to think in a simpler slave code. It will only open the slave channel on discoverable mode, accept every incoming connection and finally link the serial channel to the serial interface.

We will firstly show you the code, and then finally explain it to you.

# Code #
```
@ERASE

@INIT 50
50 Z = 0
51 RETURN

@IDLE 100
100 A = slave 5
101 RETURN

@SLAVE 150
150 A = link 1
151 RETURN

```

# Explanation #
The AIRcable<sup>tm</sup> BASIC processor is controlled by interrupts, interrupts must be written like **@INTERRUPT LINE** where **INTERRUPT** is the name of the interrupt and **LINE** is the line where that piece of code start. There are two interrupts that don't need **LINE** those are @ERASE and @UNLINK, those _interrupts_ have an special meaning, the first one will erase all the basic code before uploading a new one (over ObexFTP) and the second erases the linked device list.

This code is quite simple, firstly we erase the old basic code.

Then you have **@INIT** this interrupt will be run every time the processor boots up. The init code this program will run is quite easy it only makes sure debuggin is disable **Z = 0**. Later in this example we will see the effect of turning on debugging. Notice that the line 51 says **51 RETURN** this is very important, if the basic processor doesn't find a RETURN it will run the next line until it finds a RETURN or it reaches line 1023. So you can reach two different problems: one is running lines of code you didn't want to run, and the other is getting the device into an unsuable state (until reboot) because if line 1023 is reached with out a RETURN it will not get back to line 1.

Then you have another interrupt **@IDLE** this interrupt is called when the **@INIT** ends, or when the slave channel is closed (this can happen in two times, when a slave connection is closed or when the **slave** command time out). This piece of code simply opens the slave channel for 5 seconds and returns. If there is an incomming connection between those 5 seconds **@SLAVE** will be called, or if there hasn't been any connection **@IDLE** will be called again.

Finally you have **@SLAVE** interrupt, this piece of code is quite simple also, it will only link the serial layer with the slave channel.

# Testing #
Copy and paste (or you can also download from [here](http://aircable.googlecode.com/svn/examples/micro_slave/AIRcable.bas) )this piece of code on a text file, name it as **AIRcable.bas** and then upload it to your device (You can follow this [instructions](http://docs.google.com/View?docid=dcvjvpkp_33f2r232) ).

You can now test the code by opening a master connection to the device. You can do this by multiple ways you can use a generic bluetooth dongle or use another AIRcable device, read the instructions of those devices for further information.

# Debugging #
Remember we talked about enabling debbuging, in this piece of code debugging is kind of useless, but on larger projects it will be really necessary.

So how you enable debugging? Simple replace line **50** from **50 Z = 0** to **50 Z = 1** upload again, and you will see the BASIC processor output on the serial interface.

Here is the output for this code:

```
51 RETURN
100 A=slave5
101 RETURN
100 A=slave5
101 RETURN
150 A=link1
.....
100 A=slave5
101 RETURN
```

As you can see you don't see the @INTERRUPT line but you can see how the code is being called. The _...._ is because here you will see all the data that is being transfered from the connected device. Once **link 1** or **link 2** is called you will loose all the debugging on the serial interface.

