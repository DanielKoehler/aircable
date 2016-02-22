AIRcable jEdit's Tools
# Introduction #

We have been working on a series of tools for jEdit. Here you will find information about them.


# Installation #
The installation process is quite easy, first of all if you don't have jEdit installed please install it get into www.jedit.org and follow the steps from there.

Once you have jEdit installed, get into our [Download Section](http://code.google.com/p/aircable/downloads/list) and download the last version of the **jEdit Tools**, when we wrote this text that version was 01 Alpha.

The files that are stored in that archive must be uncompressed inside the user settings, you can get this folder from the jEdit's Menu (_Utilities->Settings Directory_ the first line says the folder path)

You should also add this line to the $HOME\.jedit\modes\catalog:
```
<MODE NAME="AIRcable" FILE="AIRcable.xml" FILE_NAME_GLOB="AIRcable.bas" />
```
This line must be before the _Unknown end tag for &lt;/MODES&gt;_

Once that is done, restart jEdit and you will have all the tool set available (this also includes the highlighting stuff). You will have the tools under _Macros->AIRcable_. You can make key shortcuts to this tools, or add this tools to the contextual menu, check the jEdit docs for this (or mail us for support)

# Tour #

Here you have a tour trough the tools: [Quick Tour - No Audio](http://aircable.googlecode.com/files/jedit_macros.swf)

# Usage #
So far we have 3 macros, all those macros has been made as user friendly as we can, but as always we have no problems with your suggestions.

## Find Calls ##
This script is quite simple. You just select a line or a block of lines and the script will tell you where that line is being called (THEN, GOTO, GOSUB, Interrupts and the line itself). This is useful when you want to manually move a line of code and you are not sure if there is a call to this line.

## Find Empty Lines ##
This script will search all through your source code and will tell you which lines are empty (this mean there is no code in that line).

## Move Lines ##
This is the most useful script we had made so far. It lets you move single lines or blocks or lines (as far as there are no empty lines between them) to where ever you want. You just select the line or block of lines, and start the script. It will automatically check that there are no gaps between the lines, and it will ask you for the place where to move the piece of code. Take into account that the script will not check if you overlap lines (before or after moving lines), a recommendation is to firstly move the code to a line over 2000 and then move the code to it's final place. Once the script has ended it's work it will show you a new window with the new code, and will highlight in Yellow the lines that had changed, then you can store the modifications.

Take into account that this script is in alpha state, it might have some bugs, so we recommend you to check the changes before saving the file.

# Future Tools #
We still have 3 tools that are missing (this comes from our Java tools) those tools are: space removing, file parsing for uploading and a sort of makefile system for our internal use.

If you think there are other missing tools please let us know, also if you write your own tools and want to contribute with them don't worry to contact us.




