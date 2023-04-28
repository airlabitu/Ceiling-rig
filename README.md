# Ceiling-rig

This is the documentation for the AIR LAB ceiling rig. (current version is 2.0)

### Contents:

1. Ceiling rig interface [Processing]
2. Ceiling rig DMX address map [PDF]
3. Ceiling rig hardware [below]
4. Construction documentation [below]

#### Related Resources from AIR LAB:
1. <a href="https://github.com/airlabitu/Tutorials/tree/master/Orientation_and_position_tracker" target="_blank"> Orientation and position tracking tutorial [Processing]</a>
2.  <a href="https://github.com/airlabitu/Processing-kinect-blob-tracker.git" target="_blank">Blob tracker sketch [Processing]</a>

## Ceiling Rig Hardware

The ceiling rig consists of two seperate sections of trusses, mounted in the ceiling (~6m above the ground). The
rig is controlled via DMX from a work station in the lab - if not otherwise specified below.

### Rig (Towards the atrium)

4 flood lamps [warm/cool]

6 RGB lights

1 floor projector [Remote controlled, HDMI input]

1 Kinect Camera - facing the floor [USB connection, DMX power control]

8 Dimmer blocks


### Rig (Towards the street)

4 flood lamps [warm/cool]

11 RGB lights

8 Dimmer blocks


## Construction Documentation

The rig is controlled via an Arduino Uno with a DMX shield running the SerialToDMX example from the DMXsimple library. DMX cables are run from this to the ceiling rig. The arduino is coupled with the work station via a USB connection - use the yellow USB cable marked 'ceiling rig DMX controller'. 

Make sure that the baudrate of the Arduino matches the processing sketch (115200).

## Exporting a new application
If you need to export a new application there are a few things you need to consider.

1. Don't export it inside the local copy of this gitHub folder, since it is taking up a lot os space, and not wanted as part of this repo next time it is synced.
2. Change the desktop icon<br>
&nbsp;&nbsp;&nbsp;&nbsp;- Locate and copy the icon file called "application.icns" inside the Processing sketch data folder.<br>
&nbsp;&nbsp;&nbsp;&nbsp;- Delete the "source" folder inside the export folder.<br>
&nbsp;&nbsp;&nbsp;&nbsp;- Right click the exported application and choose "Show package contents", to see the files behind.<br>
&nbsp;&nbsp;&nbsp;&nbsp;- Go to "Contents->Resources" and paste (replace) the icon file.<br>

If you need to change the icon you need to do the following.
1. Create a new PNG icon, name it "icon.png", and replace the existing one in the Processing sketch data folder.
2. Use this website [link](https://cloudconvert.com/png-to-icns) to create a .icns file from the new icon, and name it "application.icns"
3. Add the new .icns file to the data foolder, and replace it in the exported application as described above.
  
