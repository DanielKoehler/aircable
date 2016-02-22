A templating system for making AIRcable BASIC code creation easier.

# Introduction #

Templates are everywhere around, and python programming language is no exception. By using [Cheetah Template Engine](http://www.cheetahtemplate.org/) we have been able to create some little functions that allow to easily create code that can talk to any stream: Slave, Master and UART.

# Installation #
## Installation Prerequisites ##

Before been able to use this template you will need a few prerequisites. You will need to get [Python](http://www.python.org/) 2.6 and [Cheetah](http://www.cheetahtemplate.org/) 2.x installed. If you're running any Unix based OS like MacOS or Linux then it's quite sure you all ready have python installed, Cheetah can be easily installed by using the package manager from your OS.

For MacOS you find instructions here: [Cheetah Darwin Port](http://py25-cheetah.darwinports.com/). You may need py25-hashlib for MD5 function and call python2.5 instead of the installed standard python.

Windows users might have a more difficult time to install this tools, we've found a useful guide at (1)

## Setting up ##
Once you have the prerequisites filled installation is really easy. First you need to [get parser.py](http://aircable.googlecode.com/svn/sensor_sdk/BASIC.preparser/parser.py). And store it somewhere in your path. If you're using a Unix based system then you can mark the file as executable by doing **chmod +x parser.py**, so then you can call it as **parser.py**

# Usage #
Usage of the script is easy, you just call the script and pass as argument your template, for example: **parser.py slave-monitor** where _slave-monitor_ is your template.

# Templating #
First we recommend that you understand how Cheetah templating works, for this you can read (1), this is a nice and easy to follow tutorial.

Besides the functions provided by Cheetah we have implemented a few more:
  * $PRINT(stream): Renders as PRINTU, PRINTM, or PRINTS depending on the argument _stream_. Valid _stream_ values are: **'master'**, **'slave'** and **'uart'**.
  * $INPUT(stream): Renders as INPUTU, INPUTM, INPUTS, similar to $PRINT(stream)
  * $TIMEOUT(stream): Renders as TIMEOUTU, TIMEOUTM, TIMEOUTS
  * $GET(stream): Renders as GETU, GETM, GETS
  * $STTY(stream): Renders as STTYU, STTYM, STTYS
  * $CAPTURE(stream): Renders as CAPTUREU, CAPTUREM, CAPTURES
  * $DISCONNECT(stream): Renders as A = disconnect 0, or A = disconnect 1 depending on stream. Valid streams are **'master'**, **'slave'**
  * $DEF(variable): Checks if variable is defined or not

# Examples #
For a full example on how to use the templating system you can check our [SensorSDK trunk](http://code.google.com/p/aircable/source/browse/sensor_sdk/BASIC.preparser/).

# Links #
(1) http://www.devshed.com/c/a/Python/Templating-with-Cheetah/