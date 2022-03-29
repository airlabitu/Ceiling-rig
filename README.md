# Ceiling-rig

This is the documentation for the AIR LAB ceiling rig.

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

3 flood lamps [warm/cool]

4 RGB lights

1 floor projector [Remote controlled, HDMI input]

1 Kinect Camera - facing the floor [USB connection, DMX power control]

7 Dimmer blocks available


### Rig (Towards the street)

4 flood lamps [warm/cool]

4 RGB lights

7 Dimmer blocks available


## Construction Documentation

The rig is conctrolled via an Arduino Uno with a DMX shield running the SerialToUsb example from the DMXsimple library. DMX cables are run from this to the ceiling rig. The arduino is coupled with the work station via a USB connection - use the yellow USB cable marked 'ceiling rig DMX controller'. 

The name of the arduino board is hardcoded into the interface under 'CONNECTION TO SERIAL DEVICES', and must be updated if the Arduino is changed (look in the serial monitor for the available serial connections). Furthermore, make sure that the baudrate of the Arduino matches the processing sketch.
