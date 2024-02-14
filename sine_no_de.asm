
;;;
;;; Parabolic sine table generator for Z80
;;;
;;; Modified version of the 16 byte version by Baze/3SC.
;;;
;;; Does not modify the de register.
;;;
;;; - 18 bytes (can vary depending on initial register values)
;;; - Generates a 256 byte sine table with values from -64 to 64
;;;

	org 0x8000
sine_table = 0x8100

	;; Set up registers
	;; - bc is the pointer to the page aligned table and must point to the
	;;   first element.
	;; - hl is the initial value. Reasonable values are 0 to 127.
	;;   64 gives a nice curve.
	;; - de must be 0x00fe

	;; bc is initially the start of the program (0x8000) on the ZX
	;; Spectrum
	ld	h, c
	ld	l, c

	;; Generate the table
sine_loop:
	;; Rotate the counter right, setting the carry flag if the counter
	;; was odd.
	rrc	c

	;; Copy the carry flag to all bits of a. For even iterations,
	;; a will be set to 0x00, for odd iterations it will be set to
	;; 0xff
	sbc	a

	;; Set a to the integer part of the output value. Since a is
	;; 0x00 for even iterations and 0xff for odd iterations, this
	;; will invert the output value when writing to the second
	;; half of the sine table.
	xor	h

	;; Write the result to the sine table.
	ld	b, high sine_table
	ld	(bc), a

	;; Restore the value of a and use it as the top byte of the
	;; delta value. This means that the delta value is negative
	;; for odd iterations.
	xor	h
	ld	b, a

	;; Rotate the counter back to the original value
	rlc	c

	;; Add 2*delta to the output value.
	add	hl, bc
	add	hl, bc

	;; Decrement loop counter and loop
	dec	c
	jr	nz, sine_loop

	;; Register values after generating the table:
	;; - a = 0xff
	;; - bc = 0xff00
	;; - hl = 0xff00

	;; Plot the curve using the plot function in the ZX Spectrum ROM
	ld	b, high sine_table
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
