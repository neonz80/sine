# Small parabolic sine table generator for Z80

![](/images/curve_and_circle.png)

Here is a collection of small parabolic sine table generators for the Z80. The original 19 byte version was released by neon/darklite at the Lovebyte 2024 party. Baze/3SC then made a smaller version with slightly different properties.

The sine table is generated using a very simple parabolic curve and may not be suitable for everything. Drawing a circle gives a slightly square-ish shape.

Each version has slightly different properties. The output range differs a bit and the behaviour when the curve crosses zero varies. All versions generates signed values in the range ± ~64.

## Original 19 byte version

![](/images/sine_original.png)

[**sine_original.asm**](sine_original.asm)

This is the original version released at Lovebyte 2024. The sine generator code uses 19 bytes on the ZX Spectrum when the sine table is written one page after the load address.

The output values are in the range -64 to +63.

## 16 byte version by Baze/3SC

![](/images/sine_baze.png)

[**sine_baze.asm**](sine_baze.asm)

Baze/3SC did his usual magic and shaved off 3 bytes. The output values are in the range -64 to +62 has two repeating values at around 0 and π. The sine table can be placed anywhere.

## Alternative 16 byte version

![](/images/sine_baze_alt.png)

[**sine_baze_alt.asm**](sine_baze_alt.asm)

By using `inc c` instead of `dec c`, the output range changes to -65 to +63 and there is one repeating value when going from index 255 to 0. The curve is also flipped upside down compared to the others. 

## 18 byte version that does not modify de (or bc)

[**sine_no_de.asm**](sine_no_de.asm)

Outputs the same curve as the 16 byte version, but does not modify the de register. This one is a bit harder to adjust than the others.


