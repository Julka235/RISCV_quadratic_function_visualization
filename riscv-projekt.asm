	.eqv	FXP 8						# precision of fixed point
.macro lp(%x, %y)						# load pixel: color, first address in buffer
	sb %x, (%y)
	addi %y, %y, 1
	sb %x, (%y)
	addi %y, %y, 1
	sb %x, (%y)
.end_macro

.macro mulfxp(%a, %b, %res)					# load pixel: color, first address in buffer
	mul %res, %a, %b
	srai %res, %res, FXP
.end_macro

.macro pb(%x, %y, %ad, %tmp, %col)				# paint it: x, y, start address, tmps, color
	# we move data by x
	li %tmp, 3
	mul %tmp, %x, %tmp
	add %ad, s0, %tmp
	# calculate y move
	li %tmp, 3						# %x is now temporary
	mul %tmp, %tmp, s5
	add %tmp, %tmp, s7
	mul %tmp, %tmp, %y
	# move data by y
	add %ad, %ad, %tmp
	# paint it black
	sb %col, (%ad)
	addi %ad, %ad, 1
	sb %col, (%ad)
	addi %ad, %ad, 1
	sb %col, (%ad)
	# we move address to beginning of pixel
	addi %ad, %ad, -2
.end_macro

	.data
prompt: .asciz "Enter function values a, b, c in ax2+bx+c:\n"
filename: .asciz "in.bmp"					# input file
fileout: .asciz	"out.bmp"					# output file
buf:	.space 56						# staticly allocated space for bitmap header

	.text
	.globl main
main:
	# DISPLAY STRING
	li a7, 4
	la a0, prompt
	ecall
	
	# READ INT VALUES FOR QUADRATIC FUNCTION
	li a7, 5
	# a
	ecall
	mv s10, a0
	# b
	ecall
	mv s1, a0
	# c
	ecall
	slli s2, a0, FXP		# this one will be added, so has to be moved to fixed point
	
	# OPEN BMP FILE
	li a7, 1024
	la a0, filename
	li a1, 0
	ecall
	mv s3, a0 			# s3 - file descriptor for read-only file
	
	# GET BMP HEADER FROM FILE
	li a7, 63
	mv a0, s3
	la a1, buf
	addi a1, a1, 2			# align to word
	li a2, 54
	ecall
	
	# CALCULATE AND ALLOCATE HEAP MEMORY FOR PIXEL ARRAY WITH PADDING INCLUDED
	mv t0, a1
	addi t0, t0, 0x22
	li a7, 9
	lw a0, (t0)
	ecall
	
	mv s0, a0			# so now s0 stores address of allocated memory
	
	# READ PIXEL ARRAY WITH PADDING INCLUDED
	li a7, 63
	mv a0, s3
	mv a1, s0
	lw a2, (t0)
	ecall
	mv s4, a0 			# s4 - data read length
	
	# CLOSE INPUT FILE
	li a7, 57
	mv a0, s3
	ecall

	# s0 - begining of memory allocated for pixel array
	# s1 - b in quadratic function
	# s2 - c in quadratic function
	# s4 - pixel array data length
	# s5 - width
	# s6 - height
	# s7 - padding
	
	# width
	la t0, buf
	addi t0, t0, 2			# align to word
	addi t0, t0, 0x12
	lw s5, (t0)
	
	# height - we assume it's negative originally
	# so first pixel is top left
	addi t0, t0, 4
	lw s6, (t0)
	li t1, -1
	mul s6, s6, t1
	
	# CALCULATE PADDING
	mv s7, s4
	li t0, 3			
	mul t1, s5, s6
	mul t1, t1, t0
	sub s7, s7, t1
	divu s7, s7, s6
	li t0, 4
	sub s7, t0, s7
	beq  s7, t0, padding_fix

	# prepare for painting white
	mv t0, s0			# point t0 to begining of pixel map to paint it white
paint_white:
	sub t1, t0, s0
	bgt t1, s4, base_for_x_axis	# moves to x axis if all pixel are painted white

	# PAINT BYTE WHITE
	li t1, 0xff
	sb t1, (t0)
	addi t0, t0, 1
	b paint_white

padding_fix:
	li s7, 0
	mv t0, s0
	b paint_white
	
base_for_x_axis:
	# CALCULATE START
	# height of x axis
	srai t2, s6, 1
	addi t2, t2, 1
	# width with padding
	li t1, 3
	mul t3, s5, t1
	add t3, t3, s7
	# calculate starting pixel ofset
	mul t1, t2, t3
	# calculate memory position of starting pixel
	add t0, s0, t1
	# CALCULATE END
	li t1, 3
	mul t1, t1, s5
	add s9, t0, t1

draw_x_axis:
	bge t0, s9, base_for_y_axis		# if we reach end of axis we go to next stage
	
	li t1, 0x80				# we paint it gray
	sb t1, (t0)
	addi t0, t0, 1
	b draw_x_axis

base_for_y_axis:
	# CALCULATE START
	srai t1, s5, 1
	addi t1, t1, 1
	li t0, 3
	mul t0, t1, t0
	add t0, s0, t0
	# CALCULATE JUMP LENGTH
	li t1, 3
	mul s9, s5, t1
	add s9, s9, s7

draw_y_axis:
	sub t1, t0, s0
	bge t1, s4, scale_x		# if we reach end of axis we go to next stage
	
	li t1, 0x80
	lp(t1, t0)
	addi t0, t0, -2
	add t0, t0, s9
	b draw_y_axis

scale_x:
	# 3 up and 3 down pixels to signal integer value on scale
	# calculate 0 position
	srai t1, s5, 1
	addi t1, t1, 1
	# calculate len of one on scale in pixels
	srai t3, s5, 3
	# calculate leftest scale line needed to be drawn
	slli t0, t3, 2
	sub t0, t1, t0
	# calculate begin height pos
	srai t1, s6, 1
	addi t1, t1, -2

draw_x_scale:
	bge t0, s5, scale_y
	
	mv t2, s0
	li a1, 0x80
	pb(t0, t1, t2, a0, a1)
	addi t1, t1, 1
	pb(t0, t1, t2, a0, a1)
	addi t1, t1, 1
	pb(t0, t1, t2, a0, a1)
	addi t1, t1, 2
	pb(t0, t1, t2, a0, a1)
	addi t1, t1, 1
	pb(t0, t1, t2, a0, a1)
	addi t1, t1, 1
	pb(t0, t1, t2, a0, a1)
	addi t1, t1, -6
	
	add t0, t0, t3
	b draw_x_scale

scale_y:
	# 3 up and 3 down pixels to signal integer value on scale
	# calculate 0 position
	srai t1, s6, 1
	addi t1, t1, 1
	# t3 - len of one on scale in pixels
	# calculate highest scale line needed to be drawn
	slli t0, t3, 2
	sub t0, t1, t0
	# calculate begin width pos
	srai t1, s5, 1
	addi t1, t1, -2

draw_y_scale:
	bge t0, s6, base_for_f
	
	mv t2, s0
	li a1, 0x80
	pb(t1, t0, t2, a0, a1)
	addi t1, t1, 1
	pb(t1, t0, t2, a0, a1)
	addi t1, t1, 1
	pb(t1, t0, t2, a0, a1)
	addi t1, t1, 2
	pb(t1, t0, t2, a0, a1)
	addi t1, t1, 1
	pb(t1, t0, t2, a0, a1)
	addi t1, t1, 1
	pb(t1, t0, t2, a0, a1)
	addi t1, t1, -6
	
	add t0, t0, t3
	b draw_y_scale

base_for_f:
	# CALCULATE THE NUMBER OF PIXELS THAT EQUAL TO ONE ON OUR SCALE
	# we assume for now scale goes from -4 to 4
	# and fixed point is at FXP4
	li t0, 1
	slli t0, t0, FXP		# number of precision combinations for one
	slli t0, t0, 3			# scale from -4 to 4 so we multiply by 4*2 = 8
	divu t0, t0, s5
	mv s3, t0
	
	# s3 - precision "offset" for one pixel
	
	# CALCULATE MAX LEFT PIXEL
	srai t0, s5, 1
	mul t0, t0, s3			# t0 - x in scale not pixels
	li t1, -1
	mul t0, t0, t1

	# calculate tmp help values
	srai t4, s5, 1
	mul t4, t4, t1
	
	srai t5, s6, 1
	
	# t4 - min x pixel value with axis
	# t5 - max y pixel value with axis
	li a3, 0
	li a4, 0

draw_dots:
	# CALCULATE Y VALUE IN t1 FOR X STORED IN t0
	mulfxp(t0, t0, t1)			# x^2
	mul t1, t1, s10					# times a
	mul t2, s1, t0				# +bx
	add t1, t1, t2
	add t1, t1, s2				# +c
	# CALCULATE X IN PIXELS
	div t3, t0, s3
	sub t3, t3, t4
	# CHECK IF MAP FINISHED
	bge t3, s5, end
	# CALCULATE Y IN PIXELS
	div t1, t1, s3
	sub t1, t5, t1
	# CHECK Y IF IT'S OUTSIDE OF RANGE
	blt t1, zero, next_dot
	bge t1, s6, next_dot
	# PAINT IT
	mv t2, s0
	li a1, 0x00
	pb(t3, t1, a0, a2, a1)
	
	# prev x, y = a3, a4
	# current x, y = t3, t1
	# draw missing pixels to connect dots
	bge a4, t1, draw_up
	blt a4, t1, draw_down	

draw_up:
	addi a3, t3, -1
	ble a4, t1, next_dot	# if we reached the point we draw next dot
	
	li a1, 0x00
	pb(a3, a4, a0, a2, a1)
	addi a4, a4, -1
	b draw_up

draw_down:
	mv a3, t3
	addi a4, a4, 1
	bge a4, t1, next_dot	# if we reached the point we draw next dot
	
	li a1, 0x00
	pb(a3, a4, a0, a2, a1)
	b draw_down

next_dot:
	mv a3, t3
	mv a4, t1
	add t0, t0, s3
	b draw_dots
	
end:
	# OPEN BMP FILE FOR SOLUTION
	li a7, 1024
	la a0, fileout
	li a1, 1
	ecall
	mv s3, a0			# file descriptor
	
	# WRITE HEADER TO FILE
	li a7, 64
	mv a0, s3
	la a1, buf
	addi a1, a1, 2
	li a2, 54
	ecall
	
	# WRITE PIXEL ARRAY TO FILE
	mv a0, s3
	mv a1, s0
	mv a2, s4
	ecall
	
	# CLOSE THE FILE
	li a7, 57
	mv a0, s3
	ecall
	
	# EXIT PROGRAM
	li a7, 10
	ecall
	
