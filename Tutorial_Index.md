This page shows some code examples you can use to develop your own solutions.

All this examples are released under the [Apache V2 License](http://aircable.googlecode.com/svn/trunk/LICENSE.txt)

# Index #

## Slave Related Code ##
  1. **[Micro Slave](http://code.google.com/p/aircable/wiki/Micro_Slave)**: A simple code that opens the slave port on discoverable mode and accepts all the incoming connections. It will teach you how to open the slave channel, how to make slave connections, and how to use debugging.
  1. **[Little Slave](http://code.google.com/p/aircable/wiki/Little_Slave)**: Like the micro slave, but now it will open the shell if the user press "+" when the connection is firstly started. It will teach you how to handle input characters, how to open shell connections and finally will introduce Leds handling.
  1. **[Industrial XR3 and XR5 ready slave code](http://code.google.com/p/aircable/source/browse/examples/small_slave_XR5/AIRcable.bas?r=672)**
  1. **[Filtered Service Slave](http://code.google.com/p/aircable/wiki/Filtered_Salve)**: A more complex mode, it will open the port in discoverable mode, but will check that those who want to connect to this peer complies with an address pattern. It will teach you how to compare string, and reject incoming connections.
  1. **[Restrictive Slave](http://code.google.com/p/aircable/wiki/Restrictive_Slave)**: This is a piece of code taken from our command line, that will pair to a device, and then will apair invisible to all the other devices. It will teach you how to make an slave device discover and undiscoverable.
  1. **[Improved Slave](http://code.google.com/p/aircable/wiki/ImprovedSlave)**: This is another slave example, it ensures slave profile availability almost 100% of the time.

## Master Related Code ##
  1. **[Mini Master](http://code.google.com/p/aircable/wiki/Mini_Master)**: This code will make inquires, and once it found a device it will try to connect, once the connection is closed it will start the process again. This will teach you how to handle alarms, make inquires, handle inquires results, make master connection, and check master connections.
  1. **[Filtered Service Master](http://code.google.com/p/aircable/wiki/Filtered_Master)**: This code will make inquires, and if the device it discovers matches a given pattern it will make a connection, once the connection is lost it will connect to the first thing it can find. It will teach you how to work with inquires showing how sensitive they are.
  1. **[Listed Master](http://code.google.com/p/aircable/wiki/Listed_Master)**: Those interested on buying AIRcable Mini or SMD can be very interested in this code. This code will have a predefined list of devices (between 0 and 48), will open a connection to each one of this (one at the time), will make some work over the connection, will close the connection and will continue with the next device, all this on an endless working cycle. It will teach you how to use _PRINT_ and close master connections from the master side.
  1. **[Cable Master](http://code.google.com/p/aircable/wiki/Cable_Master)**: This code is like our Cable Master, it will make inquires and will pair with the first device it can find. Once it is paired it will not inquiry any more and will only connect to it's peer. This code will show you a way to handle pairs from the master side.

## Interactive Code ##
  1. **[Interactive Code](http://code.google.com/p/aircable/wiki/Interactive_PIO)**: Sometimes you need an interactive shell on the other side, this code will teach you how to write a simple interactive program that will let the user control a series of leds and will read some analog/digital inputs.
  1. **[Wireless Command Line](http://code.google.com/p/aircable/wiki/CommandLineOverSPP)**: This is a modified version of the command line version 0.5 that uses SPP for the command line instead of the UART.

## Networking ##
  1. **[Relay Mode Code](http://code.google.com/p/aircable/wiki/Relay)**: This code will show you how easy is to create a network of AIRcable devices. For this example you will need at least 3 different bluetooth devices, and one of those 3 must be an AIRcable OS enabled device. In this mode the AIRcable OS device will be connected to two other devices and will make a bridge between them, this way you can make the range of your bluetooth devices much longer.
  1. **[DUN SPP](http://code.google.com/p/aircable/wiki/DUN_SPP)**: This example shows you how to switch between SPP and DUN profiles.

## Hardware Interfacing ##
  1. **[GPS and Data Logging](http://code.google.com/p/aircable/wiki/GPS_Data_Logging)**: In this example we will get connected to a Bluetooth Enabled GPS and will log all the data to a file.
  1. **[vCard Sender](http://code.google.com/p/aircable/wiki/vCard)**: In this brief example we will show you how to create an automatic vCard sender.
  1. **[SMS Sender](http://code.google.com/p/aircable/wiki/smsSender)**: This example will show you how to generate SMS messages on a BT enabled cell phone, and send them.
  1. **[I2C Example](http://code.google.com/p/aircable/wiki/GenericI2Ccode)**: The [AIRcable OS](http://www.aircable.net/products-os.html)  can communicate with any I2C device. This example uses the MCP3421 18bit ADC to read temperatures from a type-K thermocouple.

## Miscellaneous ##
  1. **[Bitwise Operations](http://code.google.com/p/aircable/wiki/BitwiseOperations)**: There are times when you need to do some bitwise operations, for example when you need to calculate a checksum, here we will show some bitwise operations implementations.
  1. **[Publisher](http://www.aircable.net-a.googlepages.com/proximitymarketingstandalonesolution)**: Proximity Marketing with the AIRcable OS
  1. **[Rssi Scanner](http://code.google.com/p/aircable/source/browse/examples/automatic_rssi_scan/AIRcable.bas?spec=svn673&r=671#1)**: A piece of code that will start RSSI inquiry when it gets an SPP connection, printing results in the slave channel.

## Future Examples ##
  1. Advanced Uart: This example read from Uart and writte to SPP, via BASIC program
  1. UART Interrupting: doing reads and writes manually with @UART interrupts
  1. Timing: attach clock, use time functions
  1. Analog Interface: read from analog 1 and 2, a battery monitor that blinks when battery is low
  1. Temperature Sensor: temperature sensor and use @SENSOR
  1. I2C Interface: use the i2c function to talk to an ADC ads1112
  1. Having Some Fun: make some noise with a speaker