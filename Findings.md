# Corsair Bragi Protocol Version ??

Based on [this](https://github.com/ckb-next/ckb-next/wiki/Corsair-Protocol), and some Wireshark captures from M55 RGB PRO.

## Guidance

If bytes are omitted from the response, it means that we don't think they matter.

If we aren't sure what a command does, we'll put the dubious command in *italics*.

## What we know so far

All packets have a 64 byte payload, padded with zeroes.

<s>The first four bytes of the command are echoed in the response packet.</s>
<s>The protocol is poll based - the mouse may reply to an `0e` command with an arbitrary amount of `01` events terminated with an `03` event before replying.</s>(TODO check if this holds true here)

The protocol uses USB URB interrupts - URB control packets work on only tested device (M55 RGB PRO).

All responses from the device starts with 00 and echoes back 2nd byte of the request, so all packets with responses longer than 2 should be for reading back data from mouse? If I forgot about response assume it's just these two bytes and nothing more

* 00
 * 02 XX device -> host, pressed buttons
 * 
* 08 host -> device
    * 01 -set
    * 02 - get
    * 06
        * 00 06 00 00 00 ff- logo color
        * 00 - send payload, first packet, possibly only in firmware mode
    * 07 - send payload all pakcets except 1st one
    * 

## Host to device

## `08` fields

### `08` - Everything?
Almost all commands sent to the device starts with 08, except one used when flashing firmware

### *`08 01` - Control/set mouse settings*
## `08 01 01 00 XX` - polling rate
* 1 - 125Hz
* 2 - 250Hz
* 3 - 400Hz
* 4 - 1000Hz

## `08 01 02 00 XX XX` - mouse brightness
* 0
* 330, little endian
* 660 - 66%
* 1000 - 100%
## `08 01 52 00 xx` - handeness
* 01 - left hand
* 00 - right hand

### `08 01 03 00 XX` - Set mode
* 01 - hardware mode
    * This is the only command iCUE sends when it closes, changing control from software to hardware
* 02 - software mode
* 03 - firmware update mode?

## *`08 02` - get*
### `08 02 01` - ?
### `08 02 03` - mode
* response `00 02 XX`
    * 1 - hardware mode
    * 2 - software mode
    * 3 - *firmware update mode?*
### `08 02 11` - vendor id
### `08 02 12` - product id
### `08 02 13` - firmware version
Returned as `00 02 00 Major minor patch`

For v.4.6.22 it's `00 02 00 04 06 16`

### `08 02 14` - bootloader version
### `08 02 52` - ?
### `08 02 5f` - ?

## 08 - lights, DPI
### *`08 18` - `08 2f` - DPI*

When changing DPI values iCUE always sends 13 packets, 1 at the start, 2*5modes (DPI and color) and 2 at the end.

This mouse has 5 DPI modes, but iCUE also defines "sniper" mode with yellow light and stiff, I haven't seen packets for that yet.

DPI is Litte indian, probably 2 bytes (could be 3), color is BGR, 1 byte per color

```
08 01 20 00 20 03 - Set default DPI

08 01 18 00 20 03 (1st mode)
08 01 2f 00 00 00 ff (RED)

08 01 19 00 40 06 (2nd mode dpi)
08 01 30 00 ff ff ff (white)

08 01 1a 00 b8 0b (3rd mode, 300dpi)
08 01 31 00 00 ff 00 (GREEN)

08 01 1b 00 70 17 (4th mode dpi)
08 01 32 00 80 00 80 (ugly pink)

08 01 1c 00 28 23 (5th mode, 9000)
08 01 33 00 ff bf 00(color, light blue)

08 01 1f 00 1f 00 00 80 00 00 - enabled modes
                     ^^
    1000 0000 - 0x80 - all (5?) modes active
    0000 1111 - 0x0f - 5th disabled
    0001 1101 - 0x1d- 2nd disabled

08 01 1e 00 00 00 00  ??
```

`08 01 18` - `08 01 ??` - DPI value for each mode (max 20 but it seems to have special meaning?)

`08 01 2f` - `08 01 ??` - color settings for each DPI mode (max 33??)

1st mode uses `08 01 18` to set value and `08 01 2f` to set color, 2nd uses `19` and `30` etc.


### `08 06 00 06 00 00 00 RD RL GD GL BD BL OL` - Change color

This command changes logo color, RL GL BL is 8bit color value, OL is opacity 00-FF

DPI color is RD, GD, BD

## Device to host
### `00 02 XX` - buttons pressed down, padded with 00 to 64
XX bits from MSB:

* DPI
* right side top
* right side bottom
* left side top
* left side bottom
* scroll button
* left
* right

So 82 would be DPI + left mouse buttons held down

these are sned as stander HID messages, nevermind then

* <s> `00 00 00 00 00 00 00 00 ff`- Scroll up</s>
* <s> `00 00 00 00 00 00 00 00 01`- Scroll down</s>

## Software
Thisgs that seems to be handled completely insoftwarte (no USB packets with that data):

* sniper mode (although after change it sends all DPI data for modes 1-5 anyway, might be GUI thing)
* enable all side buttons

## WHen iCUE kicks in
* send, many (all?) packets can be in different order, iCUE also rearranges them or doesn't send some of them if they are set correctly already (polling rate?)
    * R returned by mouse
* `08 02 03` - **get mode**
    * R `00 02 00 01` - hardware mode
* `08 01 03 00 02` - **set software mode**
    * R `00 01`
* `08 02 03` - **get mode**
    * R `00 02 00 02` - software
* `08 02 5f` (37)
    * R `00 02 05`
* `08 02 01`
    * R `00 02 00 01`
* `08 02 03`- **get mode**
    * R `00 02 00 02`
* `08 02 11` - **product id**
    * R `00 02 00 1c 1b` - 1b1c  - Corsair
* `08 02 12` - **product id**
    * R `00 02 00 70 1b` 1b70 - M55
* `08 02 13` - **get firmware version**
    * R `00 02 00 04 06 16` - 4.6.22
* `08 02 14` - **get bootloader version**
    * R `00 02 00 04 05 0d` 4.5.13
* `08 01 03 00 02` - **set software mode**
    * R `00 01`
* `08 01 02 00 e8 03` - **brightness** 100.0%
    * R `00 01`
* `08 02 52`
    * R `00 02`
* `08 01 52 00 01` - this was sent just once over  all 15 tries, never again, weird...
    * R `00 01`
* `08 0d 00 02 `
    * R `00 0d`
* `08 06 00 08 00 00 00 01 01 01 00 00 01 01`
    * R `00 06`
* `08 05 01`
    * R `00 05`
* `08 01 20 00 dc 05` **default DPI, 9000**
    * R `00 01`
* `08 0d 00 01`
    * R `00 0d`
* `08 06 00 06 00 00 00 ff 00 ff 03 ff ff` - **DPI and logo colors**
    * R `00 06`
* `08 0d 01 02`
    * R `00 0d`
* `08 06 01 08 00 00 00 01 01 01`
    * R `00 06`
* `08 05 01 01 00 04`
    * R `00 05`

Sidenote
* `08 06 00 06 00 00 00 RD RL GD GL BD BL OL`
    * RD, GD, BD - DPI colors
    * RL, GL, BL - logo colors
    * OL - logo opcaity
### Firmware update
See firmware.pcapng

* `08 01 03 00 01` **set hardware mode**
    * gets decriptor after that, including BP00 and serial number
* `08 02 03` - **get mode**
    * R`00 02 00 01` - firmware?? mode
* `00 01 03 00 03` *set firmware update mode?*
    * then it reboots, probably in firmware update mode
* mouse sends over:
    * 128 `00 00 00 00 00 00 00 00 00 ca a4 03 00 f8 ff ff 00 00 00 00 00 00 00 00 20 4b 00 00 00 00 00 00 5f 4b 00 00 00 00 00 00 07 00 00 00 00 00 00 84`
        * over endpoint 3?? All CUE packets so long travelled over endpoint 4
    * 130 `00 02 00 01`
    * 132 `00 01`
    * 134 `00 00 00 00 00 00 00 00 00 ca a4 03 00 f8 ff ff 00 00 00 00 00 00 00 00 10 4f 00 00 00 00 00 00 4f 4f 00 00 00 00 00 00 03 00 00 00 00 00 00 84`
        * over endpoint 3?? All CUE packets so long travelled over endpoint 4
    * 140 `00 02 00 01`
    * 142 `00 01`
    * then it reboots, possibly in firmware update mode

---
AFTER REBOOT OR WHATEVER:

* 181 `08 0d 00 03` ??
    * R `00 0d`
* 185 `08 06 00 XX XX 00 00 PL ... PL` - first package of the payload
    * XX is size, little endian, then 57 bytes of payload
* `08 07 00 PL ... PL` - 61 bytes of payload
    * last payload is padded with 00
* `08 05 01` ??
* `00 10` ??
    * strangest OUTGOING packet, first one that doesn't start with 08
    * then mouse returns just `40 00` (64 in dec, no 00 at the start!) and reboots
* 
