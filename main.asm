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
.def DEBOUNCE_COUNT = r18   ; Debounce count accumulator

; ** Constants **
.equ BILGE_RLY = PB0        ; Bilge Pump Relay (OUTPUT)
.equ LIGHT_RLY = PB1        ; Light Relay (OUTPUT)
.equ PWR_LED   = PB2        ; Power LED (OUTPUT)
.equ BILGE_SW  = PINB3      ; Bilge Pump Switch (INPUT)
.equ LIGHT_SW  = PINB4      ; Light Switch (INPUT)
.equ TRUE      = 1          ; Constant for True
.equ FALSE     = 0          ; Constant for False
.equ DEBOUNCE_DELAY = 10    ; Debounce count init

; ** SRAM Allocation **
.DSEG
BILGE_STATUS: .byte 1       ; Bilge Pump Relay Status (BOOLEAN)
LIGHT_STATUS: .byte 1       ; Light Relay Status (BOOLEAN)
PORT_STATUS:  .byte 1       ; PORTB Status
.CSEG

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
    
    ldi TEMP, $07
    out DDRB, TEMP
    clr TEMP
    out PORTB, TEMP

    ; Init variables
    ldi TEMP, FALSE
    sts BILGE_STATUS, TEMP
    sts LIGHT_STATUS, TEMP
    in TEMP, PORTB
    sts PORT_STATUS, TEMP
    ldi DEBOUNCE_COUNT, DEBOUNCE_DELAY


; ** Main loop **
MAIN:
    ; Check Bilge Switch
    sbis PINB, BILGE_SW
    rcall BILGE_SW_HANDLER
    ; Check Light Switch
    sbis PINB, LIGHT_SW
    rcall LIGHT_SW_HANDLER
    rjmp MAIN

BILGE_SW_HANDLER:
    ; Program branches here if bilge switch active
    ret

LIGHT_SW_HANDLER:
    ; Program branches here if light switch active
    ; Soft Debounce
    LIGHT_DEBOUNCE:
        push DEBOUNCE_COUNT         ; r18 used in delay loop, save current value
        rcall DEBOUNCE              ; Wait 5mS
        pop DEBOUNCE_COUNT          ; Restore r18
        dec DEBOUNCE_COUNT          ; Continue until debounce delay expired
        brne LIGHT_DEBOUNCE
        ldi DEBOUNCE_COUNT, DEBOUNCE_DELAY  ; Re-init counter value
    lds TEMP, LIGHT_STATUS
    dec TEMP
    brlt TURN_LIGHT_ON              ; If lights currently OFF - Turn light ON
    TURN_LIGHT_OFF:                 ; Otherwise turn lights OFF
    cbi PORTB, LIGHT_RLY
    ldi TEMP, FALSE
    sts LIGHT_STATUS, TEMP
    rjmp LIGHT_FINAL

    TURN_LIGHT_ON:
    sbi PORTB, LIGHT_RLY
    ldi TEMP, TRUE
    sts LIGHT_STATUS, TEMP

    LIGHT_FINAL:
    sbis PINB, LIGHT_SW            ; Wait for switch release
    rjmp LIGHT_FINAL

    ret


DEBOUNCE:
; ** Software Switch Debounce Delay **
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