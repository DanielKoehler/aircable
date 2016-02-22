Fast pairing guide for a brand new AIRcableSMD

# Introduction #

So you just received your brand new AIRcableSMD, and want to start making some interesting with it right?. Well before you can exploit all the power from the AIRcableSMD there are some steps you will have to follow.

# Details #
First off all let me explain something. The AIRcableSMD is our most flexible product, in the sense that you can connect it to any Digital system you can think off, it does bluetooth (as obvious), SPI, UART, digital interfaces and analog inputs.
Each AIRcableSMD comes from factory with a piece off code by default, this code is called command line, and this code will let you use the device as a replacement for a serial wire. As we can't know what are you are going to connect to the AIRcableSMD, the software has been made in a very universal way.

From factory the device can only work in a slave mode, it will accept any connection from other devices, and will be visible to all off them. This behavior can be changed by the user, but from factory will work this way, unleash you set a PIO (digital line) to '1', then you will have to tell the code which PIO you are going to use for this, I will explain you this later.

So with your device powered on, make an SPP connection to the device, and type '+++' enter in the terminal emulator you are using (check [here for more information](http://docs.google.com/View?docid=dcvjvpkp_56fp3wt6) ). Once in there there are some tasks you have to do before having the device totally set up, there's no need to follow this steps in order except for the last one:

  1. - Set the name of the device with command **n**
  1. - Set the pin of the device with command **p**
  1. - Set name and pin settings with command **k**
  1. - Set the name filter with command **b** (only needed for master devices)
  1. - Set the address filter with command **g** (needed for ALL the devices), this field can't be empty, only those devices whose bluetooth address start with the given patter will be available to access to the device.
  1. - Set up the UART port with command **u**
  1. - Set the automatic mode with command **a**
  1. - Set the PIO list with command **q** (check the format for this string in the docs, it's very important to follow this step carefully, or you will not be able to get the device into an automatic mode)

You can get more information about each command [in the SPP command line documentation ](http://docs.google.com/View?docid=dcvjvpkp_56fp3wt6)

