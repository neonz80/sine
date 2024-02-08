;;;
;;; Parabolic sine table generator for Z80
;;;
;;; - 19 bytes (can vary depending on initial register values)
;;; - Generates a 256 byte sine table with values from -64 to 63
;;; - 1 byte extra to get values from -128 to 127
;;;
;;; The generator works by calculating a parabolic curve using 8.8 fixed point
;;; and inverting every second value.
;;;
;;; Feel free to use this as you like!
;;; - neon/darklite
;;;

	org 0x8000


	;; Set up registers
	;; - bc is the pointer to the page aligned table and must point to the
	;;   first element.
	;; - hl is the initial value. Reasonable values are 0 to 127.
	;;   64 gives a nice curve.
	;; - de must be 0x00fe for the output to be in the range -64 to 63.

	;; bc is the start of the program (0x8000 here) on the ZX Spectrum.
	;; The sine table is written to 0x8100-0x81ff.
	inc	b
	ld	h, c
	ld	l, c
	ld	de, 0x00fe

	;; Generate the table
sine_loop:
	;; Rotate the counter right, setting the carry flag if the counter
	;; was odd.
	rrc	c

	;; Copy the carry flag to all bits of a. The value of a will
	;; alternate between 0x00 and 0xff.
	sbc	a

	;; Set a to the output value, inverting it if the counter was odd.
	xor	h

	;; Insert "add a" here to get values from -128 to 127

	;; Write the value. This will write to index 0, 128, 1, 129 and so on.
	ld	(bc), a

	;; Calculate next value
	add	hl, de

	;; Decrease delta
	dec	de
	dec	de

	;; Rotate the counter back and increment it
	rlc	c
	inc	c

	;; Stop after 256 iterations
	jr	nz, sine_loop

	;; Plot the curve using the plot function in the ZX Spectrum ROM
draw_loop:
	halt
	ld	a, (bc)
	add	64
	push	bc
	ld	b, a
	call	0x22e5
	pop	bc
	inc	c
	jr	draw_loop
