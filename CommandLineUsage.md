This document describes the command line implemented in AIRcable SensorSDK.

# Introduction #

Communication between the SensorSDK and the outside world can be done over Bluetooth or the UART port, for automated access a protocol is needed. We created a very simple to use command line, which allows to do some basic functions like:
  * Add entries to history.
  * Exchange files over a string stream protocol.
  * Show text on the screen.
  * Change state of PIO.
  * Listen for button press.

# Downloading Code #
The template can be found in our trunk: [latest version](http://aircable.googlecode.com/svn/sensor_sdk/BASIC.preparser/shell/AIRcable.bas).

# Including Command Line #

Command line is provided as a Cheetah template, you need to define the global variable $stream before including the template, for example if you want to use _slave_ profile then you need this lines:
```
#set global $stream="slave"
....
#include "shell/AIRcable.bas"
```

We recommend adding this _include_ after base code and before mode code (monitor, interactive, etc).

# Code Example #
```
607 IF A = 0 THEN 650;
## s<file>: send file over spp
608 IF $0[0] = 115 THEN 620;
## u: slave and enable for 20 seconds
609 IF $0[0] = 117 THEN 630;
## S[number][content]: sets line number to 
## content, number is 4 digit long always
610 IF $0[0] = 83 THEN 643;
## L[number]: print content from line 
611 IF $0[0] = 76 THEN 646;
## c<clock>: sets current date and time
612 IF $0[0] = 99 THEN 637;
## d<file>: deletes <file>
613 IF $0[0] = 100 THEN 640;
## l<content> put <content> on the screen
614 IF $0[0] = 108 THEN 680;
## P<timeout>: wait until user does a button press
615 IF $0[0] = 80 THEN 685;
## p<STATE><PIO>: sets <PIO> to either 1 or 0 (pioset/pioclr)
616 IF $0[0] = 112 THEN 688;
## e exit
617 IF $0[0] = 101 THEN 650;
```

# Command Line Functions #
In _code example_ section you can see the function dispatcher, there are a few factory functions, but you can modify this to match your needs.

Standard Functions:
  * _s**< file >**_: Send < file > over spp. This will print each line after another, waiting for GO before sending a new line.
  * _u_: Will close the command line, and will enable slave and FTP for a few minutes.
  * _S**< number >< content >**_: Sets line < number > to < content >. < number > needs to be 4 digits long always, otherwise you might loose some content. You can fill with 0s and spaces.
  * _L**< number >**_: Prints line < number > to the shell.
  * _c**< content >**_: Pushes < content > into the device history.
  * _d**< file >**_: Deletes < file > from the file system.
  * _l**< content >**_: Will display < content > into the LCD screen. There's no scroll with this command.
  * _P**< timeout >**_: Will wait until < timeout > for a long or short button press. If there's a timeout then you will get back to the shell.
  * _p**< state >< PIO >**_: Will set < PIO > to < state >, < state > can be either 0 or 1.
  * _e_: Will exit the command line.