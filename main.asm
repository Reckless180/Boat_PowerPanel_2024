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

; ** Includes **
.include "tn13def.inc"

; ** Definintions **
.def TEMP = r17             ; Scratch Register

.equ BILGE_RLY = PB0
.equ LIGHT_RLY = PB1
.equ PWR_LED   = PB2
.equ BILGE_SW  = PB3
.equ LIGHT_SW  = PB4

; ** Reset vector **
.org 0x0000
    rjmp RESET


; ** Reset Sequence **
RESET:
    ; Init Stack
    ldi r17, low(RAMEND)
    out SPL, r17

    ; Port setup
    ; PB0 = BILGE_RLY
    ; PB1 = LIGHT_RLY
    ; PB2 = PWR_LED
    ; PB3 = BILGE_SW
    ; PB4 = LIGHT_SW
    ; PB5 = ~RESET - Tied to +5V
    
    ldi TEMP, 0b00000111
    out DDRB, TEMP
    clr TEMP
    out PORTB, TEMP




; ** Main loop **
MAIN:
    sbi PORTB, BILGE_RLY
    rcall DEBOUNCE
    rcall DEBOUNCE
    rcall DEBOUNCE
    rcall DEBOUNCE
    rcall DEBOUNCE
    rcall DEBOUNCE
    cbi PORTB, BILGE_RLY
rcall DEBOUNCE
    rcall DEBOUNCE
    rcall DEBOUNCE
    rcall DEBOUNCE
    rcall DEBOUNCE
    rcall DEBOUNCE
    rjmp MAIN


DEBOUNCE:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 6 000 cycles
; 5ms at 1.2 MHz
    ldi  r18, 8
    ldi  r19, 202
L1: dec  r19
    brne L1
    dec  r18
    brne L1
    nop
    RET