# Corne keyboard

The Corne keyboard is a split keyboard with 3x6 column staggered keys
and 3 thumb keys, based on [Helix](https://github.com/MakotoKurauchi/helix).
Crkbd stands for Corne Keyboard.

![v4](https://github.com/foostan/crkbd/assets/736191/bc32e4e8-f737-4516-b92b-55a7cb93a336)

## EMI FIX (by colinski8189)
- TL;DR: Now a 4 layer board with more components, to mitigate EMI issues (USB and TRS had major issues specifically called out, these have been addressed).

- Remark: Want to shout out footstan & the contributors for the original design, you all put a bunch of work into this project and it shows! :)

- Problems TL;DR:
  - The EMI issues most likely stem from the vast number of antennas on the board, and from the TRS/USB design.

- Problems I noticed:
  - Split ground planes everywhere, makes for effective (TX/RX) antennas.
  - Virtually no GND vias for the return current. (recall that a circuit is a loop- not one direction!) Every signal trace needs to have a matching GND current path for the return. 
  - no ESD/short protection on the TRS connector. (or USB-C)
  - incorrect ESD protection on the USB. (was a series Shockey diode- now a TVS diode to GND)
  - Diode placed feeding 5V (4.4V after diode drop) to LEDs seems incorrect to me.  I have experience with LEDs similar to this, and this 4.4V VDD to the LEDs may have allowed operation from 3.3V (logic high is derived from VDD on these, but they need 5V).  If this was intentional, it is quite clever!  I removed the diode and placed a step-up logic (3.3v/5v) buffer for the data input for a root-cause solution.
  - USB differential pair was not impedance matched AT ALL (I suspect this was a big signal integrity issue, as mentioned in the notes).  This alone is a serious issue, requiring a 4-layer design.  If one absolutly wanted a 2-layer board (with USB), the USB lines on board need to be really short (<3cm).  This means the MCU would need to be next to the USB-C port.  This way (4-layer), the firmware from the original GitHub is still compatable (didn't move most components).
  - Traces routed next to the board edge, especially on the PCB break-away.  This is a bad practice, and leads to fringe fields (e.g. EMI).
  - Improper decoupling capacitor placement.  When a datasheet says "Place near pin 44", I always try to get the capacitor as close as possible to the chip (this has to do with the power demand in short time intervals, and is related to emissions by wavelength and the speed of light in FR4, air and sillicon e.g. shorted traces are better).
  - Via-in-pad.  While not technically a problem, this makes manufacturing more difficult for little gain.
  - Zone fill clearance was, in my opinion, too large (and non-existant on board edge).  E&M Fields will be more isolated when the reference plane is closer.  This means vias carry more current without increasing temperature as much, better signal integrity etc...
  - Solder Mask issues with controllers, and C4.  Not sure why the mask on these pads became enlarged, perhaps when I migrated to KiCad 9?  All I had to do was update footprint from the PCB editor, and this was resolved.
  - No decoupling capacitors on WS2812 LEDs.  I guess this is not a problem? I checked the linked datasheet and found no reference to this, so I did not add them.  (They are required on the WS2812B that another project of mine uses).  This could be a source of emissions.  (I would change this for a product I was designing, but it is probably fine).
  - Parallel line crosstalk.  Most of the traces were routed very close together, and in parallel.  When possible, the lines should be separated to avoid crosstalk (though this isn't the biggest issue).
  - TRS has 500mA current rating.  (maybe okay? Could cause voltage droop, and signal integrety issues on the other board).
  - TRS cable was {T:R:S, 5V:TX:GND}, which would mean that the return path of 5V is TX, or more likely a common mode current on the shield (this would 100% cause emissions).  TRRS would be the best solution with {T:R:R:S, TX:GND:5V:GND} so hence the 1A rated TRRS connector swap.

- What I did:
  - Left everything in their original locations & deleted all VIAs and traces.
  - Routed the board as 4 layer. (Tried 2 layer, but I couldn't get USB 2.0 impedance on a 2 layer board).
  - TRS re-design. Edit: I did make the switch to the TRRS design mentioned above.
  - Ferrite Beads: on USB-C power, and TRRS 5V.  Intended to attenuate on 100MHz (33Ohm).  This alone could be the source of the succeptability (phone needing to be 30cm away).
  -  Added stiching vias everywhere.  To create a strong ground reference (minimal current loop sizes).
  - Dis-connected USB-C recepical from ground. This is admittedly a debated topic, I usually like to keep the shield isolated from signal ground to avoid common mode currents on the shield.  In general, the USB host should have the shield ground attached (and this is a device).

- Comment on 4-Layer stackup
  - {GND-SIG/PWR-GND-SIG} : a common suggestion is two internal ground layers (SIG/PWR-GND-GND-SIG i.e. SIG traces can be reached), but emission tests often fail due to RF that couples to the power lines.  Since this design doesn't require any signals to be accessed on the TOP side, I have made this a ground plane, and buried the power lines (which will have good RF succeptibility performance - e.g. you can have your phone next to it).

- Notes on constraints:
  - It was noted that you couldn't have a phone within 30cm.  This was on account of the numerous antennas created with traces all over the board, the lack of RF filtering on power from USB-C and from the TRS cable.  
  - It was noted that plugging in TRS while powered caused chip damage.  This is not suprising given that there was no ESD protection whatsoever on this component. Now there is short protection (still wouldn't reccomend hot swapping, as it will cause board to lose power most likely.  It should not damage the chips though, which is the intention of this change).

- Don't just take my word for it! (for those interested) [Resources]:
  - The following two resouces were invaluable during my PCB self-education.  I have sinced read 3 of Rick Hartley's top 5 reads (and Fast Circuit Boards 3 times).  All you need to know to route a board is in the video.  If you are more curious/ have a physics background like me, the book is even more valuable than the video .
  - [Video](https://www.youtube.com/watch?v=ySuUZEjARPY&pp=0gcJCdgAo7VqN5tD) Rick Hartley YT: (How to achieve proper grounding LIVE (Altium Seminar))  
  - [Reading](https://www.wiley.com/en-us/Fast+Circuit+Boards%3A+Energy+Management-p-9781119413905) Fast Circuit Boards by Ralph Morrison. (ISBN: 9781119413905)

## Latest versions
- corne-cherry: for Cherry MX compatible switches

  - v4 Hotswappable ([JP](docs/corne-cherry/v4/buildguide_jp.md)/[EN](docs/corne-cherry/v4/buildguide_en.md))
  - v4 Soldering (will be released)
- corne-chocolate: for Kailh choc v1 and v2 switches
  - v4 Hotswappable ([JP](docs/corne-chocolate/v4/buildguide_jp.md)/[EN](docs/corne-chocolate/v4/buildguide_en.md)):
  - v4 Soldering (will be released)

## Old versions

- corne-classic: for Cherry MX compatible switches 
  - v1 Soldering: ([JP](docs/corne-classic/buildguide_jp.md)/[EN](docs/corne-classic/buildguide_en.md))
- corne-cherry: for Cherry MX compatible switches
  - v2 Hotswappable: ([JP](docs/corne-cherry/v2/buildguide_jp.md)/[EN](docs/corne-cherry/v2/buildguide_en.md))
  - v2 Hotswappable tilting version: ([tilting, JP](docs/corne-cherry/v2/buildguide_tilting_tenting_plate_jp.md)/[tilting, EN](docs/corne-cherry/v2/buildguide_tilting_tenting_plate_en.md)):
  - v3 Hotswappable: ([JP](docs/corne-cherry/v3/buildguide_jp.md)/[EN](docs/corne-cherry/v3/buildguide_en.md))
- corne-chocolate: for Kailh choc v1 switches
  - v2 Hotswappable: ([JP](docs/corne-chocolate/v2/buildguide_jp.md)/[EN](docs/corne-chocolate/v2/buildguide_en.md)):
- corne-light: for easy build with a simple PCB
  - v1 Soldering: ([JP](docs/corne-light/v1/buildguide_jp.md)/[EN](docs/corne-light/v1/buildguide_en.md)):
  - v2 Soldering: ([JP](docs/corne-light/v2/buildguide_low_edition_jp.md)/[EN](docs/corne-light/v2/buildguide_low_edition_en.md)):

## Notice
There are currently reports of a bug in v4.* caused by electromagnetic interference. Depending on the environment, one or both of the left and right keyboards may stop working. It is known that this is often caused by EMI emitted by mobile phones. If you experience this kind of problem, reconnect the USB, move the EMI-generating device (probably a mobile phone) more than 30 cm away from the keyboard, and observe the situation.

For more details, please see this issue. We look forward to receiving any new information.
https://github.com/foostan/crkbd/issues/265

## Images

### Cherry
![corne-cherry](https://github.com/foostan/crkbd/assets/736191/f954ba89-a711-4866-a535-bad0bed937d1)
![image](https://github.com/foostan/crkbd/assets/736191/6a6705d2-40fb-4463-8006-6b7ca97dc0ff)
![image](https://github.com/foostan/crkbd/assets/736191/20407f6c-0f2e-41ea-8cd6-17d46d9be0a2)

### Chocolate
![corne-chocolate](https://github.com/foostan/crkbd/assets/736191/fb0e6962-76b3-4bd5-8093-83ccc1a17029)
![image](https://github.com/foostan/crkbd/assets/736191/610f9964-3adf-459b-88ad-9e9f29d5f659)
![image](https://github.com/foostan/crkbd/assets/736191/134db4dd-0c48-4a5f-bf75-97b8e652be22)

### Drawing
![sketche](https://github.com/foostan/crkbd/assets/736191/87ebea53-3c5c-42a1-97b3-f9292e4dacae)
