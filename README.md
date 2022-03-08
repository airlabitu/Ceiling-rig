# Ceiling-rig

This is the documentation for the AIR LAB ceiling rig.

Contents:
1. Ceiling rig hardware [below]
2. Ceiling rig interface [Processing]
3. Blob detection [Processing]
4. Orientation and position tracking [Processing]
5. Construction documentation [below]



**<||||||||||||||||| Ceiling Rig Hardware |||||||||||||||||>**

The ceiling rig consists of two seperate sections of trusses, mounted in the ceiling (~6m above the ground). The
rig is controlled via DMX from a work station in the lab - if not otherwise specified below. Furthermore we have a tracking
headset for the rig, consisting of a 'Sennheiser RS 175' wireless headset mounted with IR diodes.

**|| Rig (Towards the atrium) ||**

3 flood lamps [warm/cool]

4 RGB lights

1 floor projector [Remote controlled, HDMI input]

1 Kinect Camera - facing the floor [Serial (USB) connection, DMX power control]

7 Dimmer blocks available


**|| Rig (Towards the street) ||**

4 flood lamps [warm/cool]

4 RGB lights

7 Dimmer blocks available



**<|||||||||||||| Construction Documentation ||||||||||||||>**

The rig is conctrolled via an Arduino Uno running simple DMX with a DMX shield. DMX cables are run from this to the ceiling rig. The arduino is coupled
with the work station via a USB serial connection - the yellow USB cable marked 'ceiling rig DMX controller'. 

The name of the arduino board is hardcoded into the interface under 'CONNECTION TO SERIAL DEVICES', and must be updated if the Arduino is changed (look in the serial monitor for the available serial connections).
