;;;
;;; Parabolic sine table generator for Z80
;;;
;;; Alternative version of the 16 byte generator by Baze/3SC.
;;;
;;; - 16 bytes (can vary depending on initial register values)
;;; - Is upside down compared to the others
;;; - Generates a 256 byte sine table with values from -64 to +64
;;;

	org 0x8000
sine_table = 0x8100

	;; hl is the output value as 8.8 fixed point
	;; de is the pointer to the sine table
	;; c is the loop counter
	;; Set up registers
	;; - de is the pointer to the sine table (e is set in the loop)
	;; - hl is the initial 8.8 fixed point value. Low positive
	;;   values results in slightly different curves.
	;; - c is the loop counter and must be zero

	;; bc is initially the start of the program (0x8000) on the ZX
	;; Spectrum
	ld	d, high sine_table
	ld	h, c
	ld	l, c
sine_loop:
	;; Set e to the loop counter and rotate it right. e will be
	;; used as the sine table index and will alternate between the
	;; first and second half for each iteration.
	ld	e, c
	rrc	e

	;; Copy the carry flag to all bits of a. For even iterations, a
	;; will be set to 0x00, for odd iterations it will be set to
	;; 0xff
	sbc	a

	;; Use this as the top byte of the delta value. This means that
	;; the delta value is negative for odd iterations.
	ld	b, a

	;; Set a to the integer part of the output value. Since a is
	;; 0x00 for even iterations and 0xff for odd iterations, this
	;; will invert the output value when writing to the second
	;; half of the sine table.
	xor	h

	;; Write the result to the sine table.
	ld	(de), a

	;; Add 2*delta to the output value.
	add	hl, bc
	add	hl, bc

	;; Increment loop counter and loop
	inc	c
	jr	nz, sine_loop

	;; Register values after generating the table:
	;; - a = 0x00
	;; - bc = 0xff00
	;; - de = sine_table + 0xff
	;; - hl = 0xff00

	;; Plot the curve using the plot function in the ZX Spectrum ROM
	ld	bc, sine_table
draw_loop:
	halt
	ld	a, (bc)
	add	96
	push	bc
	ld	b, a
	call	0x22e5
	pop	bc
	inc	c
	jr	draw_loop
