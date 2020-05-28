This is the source code for TurboPascal's Rview.

Rview is a program to modify the rooms in classic Tomb Raider PC games (TR1 - TR5).

It is the source code for version 5 revision 1 and not the last version released, 5 revision 3, so some features will be missing.

Originally downloaded from author's defunct geocities website. (See http://www.geocities.ws/cyber_delphi/)

Initial commit is original Delphi 7 code which will need updating for modern Delphi IDEs. To get RView to build in Delphi 10.3 I only had to fix two errors. Need to change old global decimalseparator and thousandseparator to new global Formatsettings.decimalseparator and Formatsettings.thousandseparator. The main difference between old Delphi and modern Delphi is that the string type changed to unicode from ansistring so when updating a project you should check all string processing to see if it still behaves as expected.  

Project search paths will also need to be changed to search for units in the opengl, shared and trunit2 directories.
