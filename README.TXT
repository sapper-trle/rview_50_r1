             ****  RVIEW 5.0 Revision 0 ****
           September-2002, Tegucigalpa, Honduras.
          By Turbo Pascal, cyber_pascal@yahoo.com


Overview:
==========
Rview is a program that let you open Tomb Raider levels and show you each
room full textured on in and you can import/export the rooms to a DXF file
format so you can edit them in a CAD program.

Also with Rview you can do some editing in the room:

- Put different textures to each face in the floor,walls,ceiling.
- Rotate the faces in the room.
- Put white Lights intensities for TR1/TR2/TR3/TR4/TRC and colored lights for
  TR3,TR4 and TRC levels to the floor/walls/ceilings
- Cut faces in the room.
- Zone editor that can be used for custom levels.
- Change Ambient room Light that will afect Lara and Objects in the room,
  white ambient light for TR1/TR2/TR3/TR4/TRC and colored ambient light for
  TR4 and TRC levels.
- You can edit room's flags for TR1-TRc including TRc weather flag.
- Source Lights managger included, Tr1-TRc levels version supported.


This program belong to the unoficials level editor tools:

- TReditor3d: For build all rooms from scratch.
- Trtexture : A texture manager for export/import textures set in the level.
- Rview     : For make a great Modeling & texture & lights work to the rooms.
- TRviewer  : For import/export Items from others levels.
- Some others tools for different task.



HOW TO USE THE PROGRAM.
=========================

Keys Guide:
------------
In the render window.

- RIGHT MOUSE BUTTON               =     Rotate the rooms.
- RIGHT MOUSE BUTTON  + CTRL       =     Zoom  In/Out the rooms.
- RIGHT MOUSE BUTTON  + SHIFT      =     Pan the rooms.

- CLICK                            =     Put Primary texture or Light or Zone value.
- SHIFT + CLICK                    =     Put Secoundary texture.
- CTRL + CLICK                     =     Pick Texture or Light from face.
- ALT + CLICK                      =     Rotate Texture.

- SHIFT + CTRL + CLICK             =     Cut Face.
- CTRL + U                         =     Undo.
- CTRl + R                         =     Redo.

- CTRL + F12                       =     Switch to/from full screen render window.



The Texture Panel 1
--------------------
Select from the menu the option "Textures", "Panel 1", to bring a panel with the
most comun textures to be used in the level.
The textures are grouped in the 4 comun sizes: 64x64, 64x48, 64x32, 64x16.
Use 64x64 for texture complete tile, 64x48 for 3/4 tiles, 64x32 for 1/2 tile
64x16 for 1/4 tile.

- Click left mouse button over a texture to select it to the primary texture.
- Click right mouse button over a texture to select it to the secoundary
  texture.


The Texture Panel 2
--------------------
Select from the menu the option "Textures", "Panel 2", to bring a panel with the
whole textures availible in the level.

- Click left mouse button over a texture to select it to the primary texture.
- Click right mouse button over a texture to select it to the secoundary
  texture.


The Animated texture Panel
---------------------------
Select from the menu the option "Textures", "Animated Textures", to bring a panel with the
Animated texture list avaible in the level.
Select from the list the animated texture set, Rview will show you a real
time animated sample.

- Click left mouse button over the animated texture picture for select it to
  the primary texture.
- Click right mouse button over the animated texture picture for select it
  to the secoundary texture.


Controls Dialog
****************
There are 5 folders in the Control dialog: Main Control, Light Intensity,
Colored Light, Room Flags and Source Lights.

Main control
-------------
In the Main Control you choose what room to show and edit, you can show 2 rooms
at the same time, but only one can be edited (the current).

When you open a level the Room #1 and Room #2 are selected and room #1 is the
current, the camera is focused in the room #1, this mean that the center point
for the ROTATE function is the center for the current room.

Each time that you select a room from the combo box it will be drawn at his position,
but the camera still focused in the previous position, this way you can focus
a room and see drawn the others rooms relative to the current room.

Press <center camera> for focus the camera at the current room.
If you put check to the option <Current only> then only one room will be draw,
(the current one) and the camera will be center automaticly each time that you
select other room.

You can see the rooms in wireframe, solid or textured mode; the wireframe
mode is the fast mode when you zoom/move/rotate a room.
When you are in render textured and the option <Enable lights> is unchecked, you can
put/pick textures for the faces (texture mode). If you check the option <Enable lights> then
the rooms are shown with lights/color intensities and you can put/pick white or colored
lights to/from the faces (light mode).

Light intensity
------------------
In the light intensity folder, you select what kind of light you will put
each time that you click a face: "White light" or "Colored light." colored
light only will work if you are editing a TR3/TR4/TRC files.
The intensity bar will let you to adjust the white light from Clear to dark;
you can select dark intensity for put shadows in the room.
There are 4 check controls, one for each corner of the face, when you put a
white light to a face rview will apply the light only to the corners that are
selected.


Colored Light (for Tr3/Tr4/trc)
---------------
When In colored light mode, you can select the light color to use, press
<pick color> button to bring the color picker window. Select the color that
you want to use.
There are 4 check controls for the faces's corners to be used for colored
lights.


Room Flags:
-----------
Here you can edit the room flags for the current room, including TRc weather flags.


Source Lights:
--------------
Here is the source light manager included with Rview, this option is intended to manage source
light from scract for levels built with treditor3d, but maybe i can show a problem if used in
source lights built with the oficial level editor.


Ambient Room Light.
-------------------

In the "white Light" dialog you found a <Lara's white light> control, each
time that you change this value rview automaticaly will update the ambient
room light that only will affect to Lara and objects in the room. This
control work for TR1/tr2/tr3 levels.

In the "Colored Light" dialog you found a <Lara's colored light> control, each
time that you change all <Red, Green , Blue> values Rview will update the
colored ambient light for TR4 and TRC levels only. You can also press the
<pick color> button for select a color from color dialog picker.


The REPLICATE control:
----------------------
Each time that you click over a face to put a texture or light, the function
will be repeated the amount times selected in the <replicate> control.
You must note the direction that Rview replicate the function, for the
floor and ceilings alway from back to front, and for the walls from down
to up. (for Rooms built with Treditor3d).



How to use source lights manager.
=================================
- Press the <enable> button to enable/disable the source light mode.
- When in source light mode, use single CLICK for add a new source light to the
  room, the new source light will have the properties current charged on controls.
- Use SHIFT+CLICK for move the current source light to another location.
- Make current a source light selecting them from the source light boxlist. When you select
  a source light then the properties on controls will be charged from the source light.
- Use the <Pick Color> for select the color propertie. (tr3-trc only).
- Use the <High> control for define the source light high over the sector in 1/4 blocks unit.
- Use <intensity> for define the source light's white color intensity from 0-31. (tr1-tr2 only).
- Use <falloff> control for define the amount sectors to cover with this source light in sector units.
- Use the <Replace> button for overwrite the source light properties by current
  charged properties on controls. if you dit any value in control you need to click the <apply> button.
- Use <Delete> button for erase last source light added to the room.
- Use <Apply> button for make rview to light the sectors affected by current source light selected and
  based in the source lights properties. The <falloff> propertie has to be at least value "2".


* You don't need to use the <apply> button if you don't want, you can just add the source light
  and light the sectors manually as usual.

* You can use ctrl+U (Undo) after using the <Apply> button if you are not happy with
  the result, changing the properties and trying again.




How to use the zone editor.
***************************.

In all TR series, the enemies can be restringed to determined areas in a
room, these areas are called zones.

A enemy only can walk in the zone where he is when was activated.
For default treditor assign all tiles in the room to the zone #0, this mean
that the enemies can go anywhere in the room. With rview you can now assign
to each tile different zone values so the enemies will be restringed to some
areas in the room.

The enemies only will try to get Lara when she walk in tiles with zone # same that
they are.
When Lara walk on tiles with zone #1 only the enemies that are in zone #1 will try to
get her, when she walk to the zone #2 then enemies in the zone #1 will not bother
with her, but the enemies in zone #2 will try to get her now.


To assign a zone value to the sector do this:

- Select the <Zone editor> render mode.
- Put the value zone number in the <zone value> field.
- Click the sector that will have this zone value.

In Rview there are only 6 different zone values availibles with one different
color for each, these mean that for each room you can only have 6 different zones.
For Originals levels from the CD the sectors with zones higer that 6 will be
showed with grey color.


There are 3  clase zones for TR1/TUB:

- Ground Zone1
- Ground Zone2
- Fly Zone.

Seems that some kind enemies will use the ground zone1, other kind enemies will
use the ground zone2 and other kind enemies will use the fly zone.
The animals that run in the ground (wolfs, bears, lions etc) use the
ground zone1; the animals that fly or swim (Bats, birds, cocodriles, fishs etc) use
the Fly zone.
I don't know what enemies use the ground zone2, or for what is used.

For TR2/TR3/TR4/TRC there are 5 clases zones: Ground zone1, Ground zone2, Ground zone3,
Ground zone4 and fly zone. (i am not sure if in that order)
I don't know what enemies use the ground zone 2/3/4 or for what they are used


MSH file format.
****************
The MSH is a custom file format created for RView and TReditor.
It only contains the data for the vertex table, rectangles, triangles, textures, lights
and zones for all rooms in the level. Note that for textures it only contains
the textures ID for each polygon but not the actual texture data in
the level.
With the MSH file you save your work made with RVIEW and be restored later if
the level was recreated again with Treditor, or for send your work to another
person for be applied to a original level from the CD.

NOTE: seems that i have a bug with MSHs and DXFs, sometimes the info for
room #1 is corrupted in the MSH after importing the room from DXF in
the same sesion; so if happen to you then import the room from the DXF,
save the Level in TR format, then re-start Rview and build the MSH.


DXF file format import/export.
*******************************
The DXF is a ASCCI file format created for AUTODESK, some popular CAD
program support it.
The DXF file only include the polygon data and texture numbers, so
lights and zones are not stored in DXFs. When you import from a DXF
the current lights and Zone info are preserved.
When you open a DXF created with RVIEW in your CAD program, all faces
are asigned to a Layers named Texture_x  where "x" is the texture number
for that face. example: Texture_150, Texture_200, Texture_10 etc.
You can draw/edit all faces and assing them to the layer with the texture
name that you want the face will use.
Only 3d faces (rectangles or triangles) can be imported from a DXF file,
so don't expect to import circles, lines, text or other 2d figure from
your CAD program.

NOTE: In DXFs there are 2 ways to store the polygon data:
- Using VERTEX list, where all faces are stored using a continuos
  list for all polygon's corners. (i guess draw using Triangles)
- Using a 3dFACE list, where each 4 corner is defined independiently,
  (draw using rectangles), and if a triangle is defined then the
  corner 4 is the same that the corner 3.

Some CAD program build the DXF using VERTEX entities, others use 3dFACE
entities, RVIEW can only import from 3DFACES entities, so make sure to use
that option when you build a DXF in your CAD program.

I don't have 3d Studio MAX but seem that it only export DXF using VERTEX list.
I use AUTOCAD 13, also Rhinoceros 3d work fine, and seems that 3d Caligiari
true space also work.


Finding a Sector:
-----------------
Rview work exclusive with the room mesh data, but i also include a option
for find the sector belong to the faces.
When you get a texture from a face using <click + Ctrl>, Rview will try to
find at which sector this face belong and will show the "Column & row" info
at the status bar.

This info is useful when you use scripting files for put items/triggers in
levels built with RETURN2 & REMAP tools.

Note: If you get a invalid column & room number (like 223455668 value) just
try again.


Undo & Redo
-----------
Just press <Ctrl+U> for undo what you did in the last click.
Press <Ctrl+R> for Redo the last undo.
You have a max of 10 undo/redo levels back.
This feature is not availible for the zone editor work.


THE OPENGL PROBLEM
------------------
Rview use OPENGL APIs for draw the rooms, i tested this program with
the software version OPENGL32.DLL from Microsoft also with the version
from SGI, with both, Rview run fine.
The people say that the DLL from SGI run fastest that Microsoft's DLL,
but in Rview in did't note difference.

Also Rview use the Opengl utility library GLU32.DLL from Microsoft, the
version from SGI make Rview Crash, so don't use it.

Some Video Cards come with his own Opengl hardware accelerated drivers
included, so i suggest you to try Rview with these drivers first,
RView run Fast in a simple Pentium 150 mzh with not hardware accelerated
video card, but seems that Opengl is not 100% compatible and does not work
the same in all hardware accelerated videocards.

If Rview get bad perfomance in your especific video card, then try to
do the following things:


- Update your Opengl drivers for your especifiq video card.

- Switch to different resolutions and color depth.
  I get reports from people telling that they resolve the problem
  switching from 16 bits to 32 bits color, or switchig from 800x600
  to another uncomun screen resolution.

- Disable all hardware accelerated features in your video card setup
  program.

- Use gldirect program from scitech software for run opengl programs using
  your Direct3d drivers.

If you still having problem runing Rview after that, PLEASE, DON'T EMAILME
ASKING ME TO DO SOMETHING, there is nothing that i can do in Rview for making
it run in your especifiq/problematic/Rview-uncompatible video card, sorry.

There is not plan to migrate to Direct3d, i hate direct3d, my head want to
blow out when i try to learn direct3d, sorry about that.


TR4/TRC support and the time loading a level.
------------------------------------------
Yes, Rview can open Tr4/TRC levels, however severals data are not full tested
in tr4/TRC levels, some data could be interpreted different in Tr4/TRC vice
tr1-tr3. For the moment i only found that there are some TRiangular texture
infor problems for TR4/TRC, mean that some textures availibles in the texture
panel may work incorrect when they are used in the room.

If you found stranges thing in your Tr4/TRc levels after saving it with rview,
please let me know.

Loading a Tr4/TRC level realy take some time, due that Tr4/TRC levels are in compressed mode,
so it take some time to desscompres it; also tr4/TRc files are biger because
they include WAV sound files on in.

In TRC file format levels, the room section data is stored in different format
so i have to made a extra work converting the room section to the same format
used in Tr1/tr2/tr3/TR4 levels.


My load_level rutine is a litle complex because it deal with all tr file format,
there are severals "if..then" instructions, also for making my life ease,
each time that a level is loaded severals calcs/conversions are perfomed,
Also rview load all textures to opengl memory buffer, and build bitmaps table
that are used for panels textures and animated panels textures.


Multiresolution.
-----------------
The main problem for a programmer is to built a program that look the same
in another user windows screen resolution.
Rview was coded in 800x600 and normal font, so the first time that you run Rview the window
maybe are not in good position.

Rview now "remember" all the windows size and position that you choose.
So after running Rview, resize the main windows, tools and move the textures panels
in any position that you want, Rview will keep this size & position next time that
you run the program.

Rview has 3 predefined screen layout for 640x480, 800x600 and 1024x7068 screen size, if
you get any problem where main windows is out of screen then you can press CTRL+F1, CTRL+F2 or
CTRL+F3 for select one of these predefined layout.


TRC AND LAYERS.
---------------
Warning: In TRC levels, all rooms for the originals levels are built normaly
in 4 pieces (called "Layers"), i guess that this way the TRc engine render the
room faster, however Rview (and all my tools that save TRC files) save back the
rooms using just one layer, so i suggest not use these tools with your originals
levels from CD if you are runing them from hard disk.


----------------.--------------.----------------.-----------.--------.----


Good luck,


             Turbo Pascal, September-2002



