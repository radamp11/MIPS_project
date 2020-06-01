# MIPS project - drawing a 3rd degree polynomial on bitmap #
# without floating point system #
# @author: Adam Stec #

# assumptions: 	x belongs < -4 , 4 )
#		y belongs < -4 , 4 )
#		polynomial coefs belongs < -8 , 8 )
#		3 bits for an argument, 4 for coef, so (in worst case) it gives 4 + 3 + 3 + 3 + 1 for overflow = 14 bits
# 		for an integer part of number, and 18 for fractional part, to avoid overflow in further processing
		
		.data
R:		.byte 114
G:		.byte 100
B:		.byte 208

black:		.byte 0
R2:		.byte 0xff

text0:			.asciiz "Provide coefs of polynomial in order: 3rd degree, 2nd, 1st and constant.\nValues cannot extend this range: < -8 ; 8 ). Press enter after each value.\n"
input_img: 		.asciiz "D:/01 STUDIA/SEM4/ARKO/labki/projekt_mips/padding0.bmp"
output_img:		.asciiz "D:/01 STUDIA/SEM4/ARKO/labki/projekt_mips/new2.bmp"
text1:			.asciiz "Reading a BMP file.\n"
text2:			.asciiz "The program has finished its work."
input_file_error:	.asciiz "Error in reading a file (file does not exist).\n"
newline:		.asciiz "\n"
			.align 2
header:		.space  36

        	.text
        	.globl main
main:
	la	$a0, text1
	li	$v0, 4
	syscall
read:	
  	li	$v0, 13       	# open file
  	la	$a0, input_img	# output file name
  	li	$a1, 0        	# flags
  	li	$a2, 0        	# mode
  	syscall            
  	move	$t1, $v0      	# save descriptor in t1
  	bltz 	$t1, input_error

	# read 'BM' from header
 	li   	$v0, 14       
 	move 	$a0, $t1      	# file descriptor 
  	la   	$a1, header   	# header (buffer) address
 	li   	$a2, 2        	# bytes read
  	syscall
  	# read the rest of header
  	li   	$v0, 14       
 	move 	$a0, $t1      	# file descriptor 
  	la   	$a1, header   	# buffer address
 	li   	$a2, 36       	# bytes to read 
 	syscall
 	
 	la   	$t0, header
 	lw   	$s0, 0($t0)    	# reading the whole file size
 	lw   	$s2, 8($t0)    	# offset
 	lw   	$s1, 16($t0)   	# width of bitmap
 	lw	$s3, 20($t0)	# read the bitmap height
 	# close file
 	li   	$v0, 16       
  	move 	$a0, $t1
  	syscall
  	
	# allocating memory on heap
	la   	$v0, 9 
	la   	$a0, ($s0)
	syscall
	move 	$t0,$v0	   	# t0 - allocated memory address

	# open the file again and put it in allocated memory
  	li   	$v0, 13
  	la   	$a0, input_img
  	li   	$a1, 0
  	li   	$a2, 0
  	syscall   
  	move 	$t1, $v0      # save descriptor in t1
  	
  	li   	$v0, 14
 	move 	$a0, $t1
  	la   	$a1, ($t0)
 	move 	$a2, $s0
 	syscall	
 
  	# close file
  	li   	$v0, 16 
  	move 	$a0, $t1
  	syscall

	# Save the address of file beginning in s7 and set t0 to the beggining of pixels address
	move 	$s7,$t0
	add  	$t0,$t0,$s2
	
	# Counting the width in bytes with padding and save in s1
	add  	$t5, $s1, $s1	# width taken 3 times bcs 3 bytes on one pixel
 	add  	$t5, $t5, $s1
 	andi 	$t6, $t5, 3	# width % 4
 	beqz 	$t6, keep_goin 	# jump when padding = 0, else count padding

	# counting padding
	li   	$s4, 4
	sub  	$s4, $s4, $t6
	addu  	$t5, $t5, $s4

keep_goin:
	move 	$s6, $s1 	# keep in s6 value of pixels
	move 	$s1, $t5
	beq 	$s4, 0, padding_0
	beq 	$s4, 1, padding_1
	beq 	$s4, 2, padding_2
	beq 	$s4, 3, padding_3
padding_0:
	srl 	$t8, $s1, 1
	j draw_coords_system
padding_1:
	srl 	$t8, $s1, 1
	addu 	$t8, $t8, $s4
	j draw_coords_system
padding_2:
	subu 	$t8, $s1, $s4
	srl 	$t8, $t8, 1
	j draw_coords_system
padding_3:
	srl 	$t8, $s1, 1
#---------------------END OF READING A FILE--------------------#
	#				Usage of registers:
	# s0 - file size					# t0 - address with beginning of pixels
	# s1 - width in bytes with padding			# t1 - free
	# s2 - offset						# t2 - free
	# s3 - bitmap height (pixels)				# t3 - storing pixels pointer
	# s4 - padding value					# t4 - moving pointer
	# s5 - free						# t5 - free
	# s6 - bitmap width (pixels)				# t6 - free
	# s7 - file beginning address				# t7 - incrementer
								# t8 - half of OX regarding padding
								# t9 - half of OY
draw_coords_system:
	lb	$a1, R		# setting coords system color
	lb	$a2, G
	lb	$a3, B
	
	srl 	$t9, $s3, 1	# setting values in the middle
	move 	$t4, $t0	# set on the beginning of pixels
	addu 	$t4, $t4, $t8
	move 	$t3, $t4
	li 	$t7, 0		# incrementer
write_OY:
	jal 	store_color
	addu 	$t4, $t4, $s1	# incrementing address
	addiu 	$t7, $t7, 1
	move 	$t3, $t4
	blt 	$t7, $s3, write_OY
	
	li 	$t7, 0		# moving pointer to write OX
	move 	$t4, $t0
	mul 	$t6, $t9, $s1
	addu 	$t4, $t4, $t6
	move 	$t3, $t4
write_OX:
	jal 	store_color
	addiu 	$t3, $t3, 1
	addiu 	$t7, $t7, 1
	blt 	$t7, $s6, write_OX
	j 	read_coefs

store_color:
	sb    	$a3,($t3)
	addiu 	$t3,$t3,1
	sb    	$a2,($t3)
	addiu 	$t3,$t3,1
	sb    	$a1,($t3)
	jr    	$ra
	
#--------------------CHART DRAWING-------------------#
### - registers necessary to save a file - cannot change
	### s0 - file size	###				### t0 - address with beginning of pixels ###
	# s1 - width in pixels regarding padding		# t1 - y value counting
	# s2 - y jump value					# t2 - free
	# s3 - bitmap height (pixels)				# t3 - pinter
	# s4 - padding value					# t4 - free
	# s5 - x jump value					# t5 - x current value
	# s6 - bitmap width (pixels)				# t6 - bytes needed to move pointer from bottom to the middle of OY
	### s7 - beginning of file address	###		# t7 - incrementer
								# t8 - bottom control value
# from now on, I do not need:					# t9 - half of OY, then top control value
	# s4, s3
	# a2, a3 - need to use them due to lack of registers
# so I use them to save coefs of polynomial
	
read_coefs:
	li	$v0, 4
	la	$a0, text0
	syscall

	li	$v0, 5
	syscall
	move	$a3, $v0	# a3 - 3 degree coef
	li	$v0, 5
	syscall
	move	$a2, $v0	# a2 - 2 degree coef
	li	$v0, 5
	syscall
	move	$s4, $v0	# s4 - 1 degree coef
	li	$v0, 5
	syscall
	move	$s3, $v0	# s3 - constant
	
	sll	$a3, $a3, 18
	sll	$a2, $a2, 18
	sll	$s4, $s4, 18
	sll	$s3, $s3, 18

draw_chart:
	# jump values counting
	mul 	$t6, $t9, $s1	# t6 contains number of bytes that i need to add to set pointer in the middle of OY
				# counted here to use t9 register as range control value later
	li	$t1, 8		# range ( x_max - y_min )
	div	$t2, $t1, $s6 	# s6 - width in pixels
	sll	$t2, $t2, 18
	mfhi	$t3
	sll	$t3, $t3, 18
	div	$t3, $t3, $s6
	or	$s5, $t2, $t3	# x jump value
	
	div	$t2, $s6, $t1 	
	sll	$t2, $t2, 18
	mfhi	$t3
	sll	$t3, $t3, 18
	div	$t3, $t3, $t1
	or	$s2, $t2, $t3	# y jump value

	li	$t8, -4		# bottom control value of y scaled
	sll	$t8, $t8, 18
	li	$t9, 4		# top control value of y scaled
	sll	$t9, $t9, 18
	move 	$t5, $t8	# and set current value of x
	
	move 	$t3, $t0	# set pointer on the beggining address of pixels
	addu 	$t3, $t3, $t6	# and on OX ( in the middle of OY )
	li	$t7, 0		# set incrementer to 0
	
check: 				# counting y value with Horner's method
	move	$t1, $a3
	mul	$t1, $t1, $t5	#
	mfhi	$t4
	sll	$t4, $t4, 14
	srl	$t1, $t1, 18
	or	$t1, $t4, $t1
	add	$t1, $t1, $a2
	mul	$t1, $t1, $t5	#
	mfhi	$t4
	sll	$t4, $t4, 14
	srl	$t1, $t1, 18
	or	$t1, $t4, $t1
	add	$t1, $t1, $s4
	mul	$t1, $t1, $t5	#
	mfhi	$t4
	sll	$t4, $t4, 14
	srl	$t1, $t1, 18
	or	$t1, $t4, $t1
	add	$t1, $t1, $s3	# counted

	bgt 	$t1, $t9, inc_x_not_stored	# checkig, if the value does not extend range
	blt 	$t1, $t8, inc_x_not_stored	# if yes, just move pointer and current x and check again
	
	mul 	$t1, $t1, $s2			# if not, multiply y with jump
	mfhi 	$t4
	srl 	$t1, $t1, 18
	sll 	$t4, $t4, 14
	or 	$t1, $t4, $t1			
	sra 	$t1, $t1, 18			# converts y from my system to normal and moves pointer
	mul 	$t1, $t1, $s1
	addu 	$t3, $t3, $t1

	jal 	store_red_color
	j 	inc_x_stored
	
store_red_color:		# only one register used
	lb 	$a1, black
	sb    	$a1,($t3)
	addiu 	$t3,$t3,1
	sb    	$a1,($t3)
	addiu 	$t3,$t3,1
	lb 	$a1, R2
	sb    	$a1,($t3)
	jr    	$ra
	
inc_x_not_stored:
	addiu	$t3, $t3, 3	# when y extends the range, move pointer right
	addiu	$t7, $t7, 1
	addu	$t5, $t5, $s5
	blt 	$t7, $s6, check
	j save
	
inc_x_stored:			# sets the pointer in the middle of bitmap on the currently checked x
	addiu	$t7, $t7, 1
	move 	$t3, $t0
	addu	$t3, $t3, $t7	# move to incrementer ( 3 times as a convert from pixels to bytes ) on the bottom of bitmap
	addu	$t3, $t3, $t7
	addu	$t3, $t3, $t7
	addu	$t3, $t3, $t6	# and move to the middle of OY
	addu	$t5, $t5, $s5
	blt	$t7, $s6, check
	
#--------------------SAVE FILE--------------------#

save:	
 	li   	$v0, 13       		# open dest file
  	la   	$a0, output_img   	# output file name
  	li   	$a1, 1
  	li   	$a2, 0
  	syscall            
  	move 	$t1, $v0
  	
 	li   	$v0, 15       
 	move 	$a0, $t1      # file descriptor 
 	move 	$a1, $s7      # buffer address
 	move 	$a2, $s0      # bytes to save
  	syscall
  	
  	# close file
  	li   	$v0, 16
  	move 	$a0, $t1      # file descriptor to close
  	syscall  
  	
  	j 	end  	

input_error:	
	li   	$v0, 4
	la   	$a0, input_file_error
	syscall
end:	
	la   	$a0, text2
	li   	$v0, 4
	syscall	

	li   $v0, 10
    	syscall
