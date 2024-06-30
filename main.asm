; ****
; *     Boat_PowerPanel_2024
; ***
; *
; *  A simple power controller for use on a tin boat.
; *  The ATTINY13 monitors momentary contact inputs for two switches
; *  one for the lights and one for the bilge pump.
; * 
; *  When the bilge switch is selected for less than 5 seconds,
; *  the bilge pump will run then shut off. If the switch is held
; *  for greater than 5 seconds then released, the pump remains running until
; *  the bilge switch is selected again which turns the pump off.
; *
; *  The light switch contact toggles the lighting relay on and off each
; *  time the switch is momentarily selected.
; * 
; *  Written by: Matthew Higginson - Higginson Electronics
; *  Date: June 29, 2024
; *  Micro: ATTINY13A - 9.6MHz (CLK/8 Fuse enabled = 1.2MHz) 
; *  Rev: 1.0a
; *  
; ***

; Includes
.include "tn13def.inc"

; Reset vector
.org 0x0000
    rjmp RESET


; Reset Sequence
RESET:
    ; Init Stack
    ldi r17, low(RAMEND)
    out SPL, r17

; Main loop
MAIN:
    nop
    rjmp MAIN


