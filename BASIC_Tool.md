#This page will is a brief description of the BASIC Code Tools we had made.

# Introduction #

Even though BASIC code is quite easy to write, changing and maintaining a program written in  BASIC might not be so easy. With that in mind we started to wrote a set of tools to make Basic code programming a bit easier. We haven't programming the tools yet, but we want to give our users a snapshot of our tools.

# What you get from this set of tools? #
This set of tools include functions to find calls to a line in a file, find empty lines, move lines around the code, suppress empty lines in a block of line and file parsing for uploading.

As you can see you get some useful tools, specially for two of them lines moving and empty line suppressing.

# Getting the Tools #
You can Download the tools from [Here](http://aircable.googlecode.com/files/aircabletools.jar). In order to use the tools you will require Java 1.6 which you can get from [here](http://www.java.com).

# Usage #
In order to run this tools you will need to open a console on your OS, on Windows you can use CMD (START->EXECUTE cmd), under Linux you can use KConsole, or any other console, and under Mac you can use Terminal.

Future versions of this tools will get integrated with JEdit and you will not need to use the command line any more.

# Commands #

## f find calls in file ##
This command will find where each line is called.

_Usage:_ java -jar aircabletools.jar f <Line Number> 

&lt;File&gt;



## i print full interrupt code ##
This command will print all the code that a given interrupt executes.

_Usage:_ java -jar aircabletools.jar i <Inquiry Name> 

&lt;File&gt;



_**Note**: Not working all right_


## e find empty lines ##
This command will find all the lines that are empty on a file. This is useful when you don't know if you have space or not in a Basic file.

_Usage:_ java -jar aircabletools.jar e 

&lt;File&gt;



## m move lines ##
This command will move a given block of code to a new line.

_Usage:_ java -jar aircabletools.jar m 

&lt;File&gt;

 

&lt;Start&gt;

 

&lt;End&gt;

 <New Line>

_**Note**: This command is not working all right, when you want to move a piece of code, firstly move it to a piece of code that is prohibited (lines over 1025) and then get that piece of code back to the place you wanted to place it._

## s supress spaces ##
This command suppress empty lines in a block of code.

_Usage:_ java -jar aircabletools.jar s 

&lt;File&gt;

 

&lt;Start&gt;

 

&lt;End&gt;



## p parse file for uploading ##
This command will suppress all the spaces and comments in a file so you can upload it to a device more quickly.

_Usage:_ java -jar aircabletools.jar s <In File> <Out File>


## make make binary folder for distribution ##
This command will take a folder and will generate the binary file for each device. It is mean for internal use of the company, it will only work with the folder structure of our [subversion server](http://aircable.googlecode.com/svn/trunk/). The output folder must be outside the input folder.

_Usage:_ java -jar aircabletools.jar make <In Dir> <Out Dir>

# Contact #
In case you have further questions about our tools, specially the ones described here, you can contact by email to the author: manuel\_at\_aircable\_dot\_net. Just replace _at_ for @ and _dot_ for . , or click [here](mailto:manuel@aircable.net)