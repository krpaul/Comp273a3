# Kevin Paul, [redacted]
.data
bitmapDisplay: .space 0x80000 # enough memory for a 512x256 bitmap display
resolution: .word  512 256    # width and height of the bitmap display

windowlrbt: 
#.float -2.5 2.5 -1.25 1.25  					# good window for viewing Julia sets
.float -3 2 -1.25 1.25  					# good window for viewing full Mandelbrot set
# .float -0.807298 -0.799298 -0.179996 -0.175996 		# double spiral
#.float -1.019741354 -1.013877846  -0.325120847 -0.322189093 	# baby Mandelbrot
 
bound: .float 100	# bound for testing for unbounded growth during iteration
maxIter: .word 100	# maximum iteration count to be used by drawJulia and drawMandelbrot
scale: .word 16		# scale parameter used by computeColour

# Julia constants for testing, or likewise for more examples see
# https://en.wikipedia.org/wiki/Julia_set#Quadratic_polynomials  
JuliaC0:  .float 0    0    # should give you a circle, a good test, though boring!
JuliaC1:  .float 0.25 0.5 
JuliaC2:  .float 0    0.7 
JuliaC3:  .float 0    0.8 
JuliaC5:  .float 1.0 1.0

# a demo starting point for iteration tests
z0: .float  0 0

# TODO: define various constants you need in your .data segment here
newline: .asciiz "\n"
complex_i: .asciiz " i"
plus: .asciiz " + "
space: .asciiz " "
x: .asciiz "x"
y: .asciiz "y"
equals: .asciiz " = "
test1: .float 1.1
test2: .float 2.3

########################################################################################
.text
	
	# TODO: Write your function testing code here

	## multComplex Testing ##
	# la $t1, JuliaC1
	
	# lwc1 $f12, ($t1)
	# lwc1 $f13, 4($t1)
	# lwc1 $f14, ($t1)
	# lwc1 $f15, 4($t1)
	
	# jal multComplex
	
	# mov.s $f12, $f0
	# mov.s $f13, $f1
	
	# jal printComplex

	## iterateVerbose Testing ##
	# addi $a0 $zero 10 # n = 10

	# # a b = JuliaC1
	# la $t0 JuliaC0
	# lwc1 $f12 ($t0)
	# lwc1 $f13 4($t0)

	# # x0 y0 = JuliaC0
	# la $t0 JuliaC5
	# lwc1 $f14 ($t0)
	# lwc1 $f15 4($t0)

	# jal iterateVerbose
	
	## pixel2Cmplx testing ##
	# li $a0 452
	# li $a1 156

	# jal pixel2ComplexInWindow

	# mov.s $f12 $f0
	# mov.s $f13 $f1

	# jal printComplex

	## drawJulia testing code ##
	lwc1 $f12 JuliaC2
	lwc1 $f13 JuliaC2 + 4
	jal drawJulia

	## drawMandelbrot testing code ##
	# lwc1 $f12 JuliaC1
	# lwc1 $f13 JuliaC1 + 4
	# jal drawMandelbrot

	## test computer colour ##
	# li $a0 2
	# jal computeColour

	# move $a0 $v0
	# li $v0 1
	# syscall

	## exit code ##
	li $v0 10 
	syscall

# TODO: Write your functions to implement various assignment objectives here
printNewLine:
	li $v0, 4
	la $a0, newline
	syscall
	
	jr $ra

printComplex:
    # print first float

	# set print mode to 2 for float
	# float to print is already stored in $f12
    li $v0, 2
    syscall
    
    # print plus sign
	
	# set print mode to 4 for str
	# move str addr into $a0
    li $v0 4
    la $a0, plus
    syscall
    
    # move and print second float
    li $v0 2
    mov.s $f12 $f13
    syscall
    
    # print i
    li $v0 4
    la $a0 complex_i
    syscall

    jr $ra
    
multComplex:
	# 4 float arguments $f12 $f13 $f14 $f15
	
	# first calculate ac
	mul.s $f4 $f12 $f14
	
	# then calculate db
	mul.s $f5 $f13 $f15
	
	# ac - db
	sub.s $f0 $f4 $f5
	
	# calc ad
	mul.s $f4 $f12 $f15
	
	# calc bc
	mul.s $f5 $f13 $f14
	
	# ad + bc
	add.s $f1 $f4 $f5
	
	jr $ra
	
printCurrIteration:
	# $a1 is curr iteration number (n)
	# $f12 is real part, $f13 is complex part
	# this function will manipulate registers $a0, $v0

	# print x
	li $v0 4
	la $a0 x
	syscall

	# print n
	li $v0 1
	move $a0 $a1
	syscall

	# print plus
    li $v0 4
    la $a0, plus
    syscall

	# print y
	la $a0 y
	syscall

	# print n
	li $v0 1
	move $a0 $a1
	syscall

	# print =
	li $v0 4
    la $a0, equals
    syscall

	# preserve the return address
	addi $sp $sp -4
	sw $ra 0($sp)

	jal printComplex
	jal printNewLine 

	# reload the ra
	lw $ra 0($sp)
	addi $sp $sp 4
	
	jr $ra

endIteration:
	# save a0
	move $t0 $a0

	# print iter count 
	# (this will be do-while and therefore include      #
	# the zeroth iteration. ie. we count till x4 + y4,  #
	# count will be 5).									#

	li $v0 1
	move $a0 $a1
	syscall

	# set return iter count
	move $v0 $t0

	jal printNewLine

	# reload $ra
	lw $ra 0($sp)
	addi $sp $sp 4

	# jmp
	jr $ra

endIterationQuiet:
	# reload $ra
	lw $ra 0($sp)
	addi $sp $sp 4

	# set return iter count
	move $v0 $a1

	# jmp
	jr $ra

iterateVerbose: # n = $a0, count = $a1, a = $f12, b = $f13, x0 = $f14, y0 = $f15
	# first and foremost save the return address
	sw $ra -4($sp)
	addi $sp $sp -4

	## check end condition ##
	# square x and y
	mul.s $f4 $f14 $f14
	mul.s $f5 $f15 $f15

	# sum
	add.s $f6 $f4 $f5
	
	# check for out of bounds
	la $t0 bound
	lwc1 $f7 0($t0)
	c.lt.s $f7 $f6

	# stop iteration if needed
	bc1t endIteration

	# check for max iteration
	beq $a1 $a0 endIteration

	## copy a, b, $a2, $a3 onto stack,
	# float = 4bytes, ints = 2bytes
	swc1 $f12 -4($sp)
	swc1 $f13 -8($sp)
	sw $a1 -12($sp)
	sw $a0 -16($sp)

	# move stack pointer
	addi $sp, $sp, -16

	# set a=x, b=y, c=x, d=y
	mov.s $f12 $f14
	mov.s $f13 $f15

	# calculate complex product
	jal multComplex

	## we're gonna use temp registers for a bit ##
	## f4 = a, f5 = b, $f6 = x, $f7 = y 		##

	# copy results
	# real part goes into x
	# cmplx part goes into y
	mov.s $f6 $f0
	mov.s $f7 $f1

	## pop saved items off stack ##
	lw $a0 0($sp)
	lw $a1 4($sp)
	lwc1 $f5 8($sp)
	lwc1 $f4 12($sp)
	addi $sp $sp 16 # move stack pointer

	# add a to x
	# add b to y
	add.s $f6 $f6 $f4
	add.s $f7 $f7 $f5

	# save $a0
	sw $a0 -4($sp)
	addi $sp $sp -4

	# print curr iteration
	jal printCurrIteration

	# load $a0
	lw $a0 0($sp)
	addi $sp $sp 4

	# now put temp registers back into arg registers
	mov.s $f12 $f4
	mov.s $f13 $f5
	mov.s $f14 $f6
	mov.s $f15 $f7

	# increment count
	addi $a1 $a1 1

	# reload $ra
	lw $ra 0($sp)
	addi $sp $sp 4

	# loop
	j iterateVerbose

iterate:
	# first and foremost save the return address
	sw $ra -4($sp)
	addi $sp $sp -4

	## check end condition ##
	# square x and y
	mul.s $f4 $f14 $f14
	mul.s $f5 $f15 $f15

	# sum
	add.s $f6 $f4 $f5
	
	# check for out of bounds
	la $t0 bound
	lwc1 $f7 0($t0)
	c.lt.s $f7 $f6

	# stop iteration if needed
	bc1t endIterationQuiet

	# check for max iteration
	beq $a1 $a0 endIterationQuiet

	## copy a, b, $a2, $a3 onto stack,
	# float = 4bytes, ints = 2bytes
	swc1 $f12 -4($sp)
	swc1 $f13 -8($sp)
	sw $a1 -12($sp)
	sw $a0 -16($sp)

	# move stack pointer
	addi $sp, $sp, -16

	# set a=x, b=y, c=x, d=y
	mov.s $f12 $f14
	mov.s $f13 $f15

	# calculate complex product
	jal multComplex

	## we're gonna use temp registers for a bit ##
	## f4 = a, f5 = b, $f6 = x, $f7 = y 		##

	# copy results
	# real part goes into x
	# cmplx part goes into y
	mov.s $f6 $f0
	mov.s $f7 $f1

	## pop saved items off stack ##
	lw $a0 0($sp)
	lw $a1 4($sp)
	lwc1 $f5 8($sp)
	lwc1 $f4 12($sp)
	addi $sp $sp 16 # move stack pointer

	# add a to x
	# add b to y
	add.s $f6 $f6 $f4
	add.s $f7 $f7 $f5

	# now put temp registers back into arg registers
	mov.s $f12 $f4
	mov.s $f13 $f5
	mov.s $f14 $f6
	mov.s $f15 $f7

	# increment count
	addi $a1 $a1 1

	# reload $ra
	lw $ra 0($sp)
	addi $sp $sp 4

	# loop
	j iterate

pixel2ComplexInWindow:
	# $a0 = col, $a1 = row

	# load t0 = w, t1 = h
	lw $s6 resolution
	lw $s7 resolution + 4 

	# col will be $f4
	# row will be $f5
	# w will be $f6
	# h will be $f7
	mtc1 $a0 $f4
	mtc1 $a1 $f5
	mtc1 $s6 $f6
	mtc1 $s7 $f7

	# convert
	cvt.s.w $f4 $f4  
	cvt.s.w $f5 $f5 
	cvt.s.w $f6 $f6 
	cvt.s.w $f7 $f7 

	# f8 = l, f9 = r, f10 = b, f11 = t
	lwc1 $f8 windowlrbt
	lwc1 $f9 windowlrbt + 4
	lwc1 $f10 windowlrbt + 8
	lwc1 $f11 windowlrbt + 12

	# x calculations
	div.s $f12 $f4 $f6  # divide col / w -> $f12
	sub.s $f13 $f9 $f8  # subtract r - l -> $f13
	mul.s $f0 $f12 $f13 # multiply $f12 * $f13 -> $f0
	add.s $f0 $f0 $f8   # add l to $f0 -> $f0

	# y calculations
	div.s $f12 $f5 $f7   # divide row / h -> $f12
	sub.s $f13 $f11 $f10 # subtract t - b -> $f13
	mul.s $f1 $f12 $f13  # multiply $f12 * $f13 -> $f1
	add.s $f1 $f1 $f10   # add b to $f1 -> $f1

	jr $ra

DJFor1: # s2 = i; s3 = j; s0 = i max, s1 = j max; f12 = a, f13 = b(i), s4 = bitmapLocation
	beq $s2 $s0 exitFor
	addi $s2 $s2 1 # i++
	li $s3 0       # reset j = 0
DJFor2:
	beq $s3 $s1 DJFor1
	addi $s3 $s3 1 # j++

	# save $ra (points to drawJulia)
	sw $ra -4($sp)
	addi $sp $sp -4

	# save original a and b passed to drawJulia
	swc1 $f12 -4($sp)
	swc1 $f13 -8($sp)
	addi $sp $sp -8

	## calculate starting point ##
	# load i and j into a0 a1
	move $a0 $s3
	move $a1 $s2
	jal pixel2ComplexInWindow # returns in f0 and f1
	
	## now that we have a starting point, call iterate ##

	# load n
	la $t0 maxIter
	lw $a0 0($t0)

	# a,b already in correct registers
	
	# load x0, y0 from pixel2Complex's return
	mov.s $f14 $f0
	mov.s $f15 $f1

	# reset a1 (counter for iterate)
	move $a1 $zero

	# load a and b
	lwc1 $f13 0($sp)
	lwc1 $f12 4($sp)
	addi $sp $sp 8

	# call iterate
	jal iterate

	# check if maxIter was reached
	lw $t1 maxIter
	seq $t0 $v0 $t1 # t0 = 1 if reached, 0 if not

	## if not reached, call computeColour ##
	# gonna do a hack so that we can exploit the bltzal instr. 
	# since i dont see another way to branch and link
	# subtract 1 from t0. Now -1 if not reached and 0 if reached
	addi $t0 $t0 -1
	move $a0 $v0
	li $v0 0 # write black as default colour if bltzal doesn't branch
	bltzal $t0 computeColour
	
	# ARGB colour stored in $v0 now
	# now write pixel information
	sw $v0 ($s4)
	
	# reload $ra
	lw $ra 0($sp)
	addi $sp $sp 4

	addi $s4 $s4 4 # increments bitmap location
	j DJFor2

exitFor:
	# return row and col
	move $v0 $s2
	move $v1 $s3

	jr $ra

drawJulia:
	# $f12 = a, $f13 = b
	
	# save $ra 
	sw $ra -4($sp)
	addi $sp $sp -4

	# loads bitmap initial address
	la $s4 bitmapDisplay

	# load dimensions
	lw $s0 resolution + 4
	lw $s1 resolution

	# run for loop
	jal DJFor1

	# # row, col store in v0, v1 now
	# # move them to save registers for later
	# move $s3 $v0
	# move $s4 $v1

	# reload $ra
	lw $ra 0($sp)
	addi $sp $sp 4

	# return
	jr $ra

DMFor1: # s2 = i; s3 = j; s0 = i max, s1 = j max; f12 = a, f13 = b(i), s4 = bitmapLocation
	beq $s2 $s0 exitFor
	addi $s2 $s2 1 # i++
	li $s3 0       # reset j = 0
DMFor2:
	beq $s3 $s1 DMFor1
	addi $s3 $s3 1 # j++

	# save $ra (points to drawMandelbrot)
	sw $ra -4($sp)
	addi $sp $sp -4

	# save original a and b passed to drawJulia
	# swc1 $f12 -4($sp)
	# swc1 $f13 -8($sp)
	# addi $sp $sp -8

	## calculate a & b point ##
	# load a and b into a0 a1
	move $a0 $s3
	move $a1 $s2
	jal pixel2ComplexInWindow # returns in f0 and f1
	
	## now that we have a & b point, call iterate ##

	# load n
	la $t0 maxIter
	lw $a0 0($t0)

	# move result of pixel2cmplx into a and b
	mov.s $f12 $f0
	mov.s $f13 $f1	
	
	# load starting point 0, 0
	mtc1 $zero $f15
	mtc1 $zero $f14

	# reset a1 (counter for iterate)
	move $a1 $zero

	# load a and b
	# lwc1 $f13 0($sp)
	# lwc1 $f12 4($sp)
	# addi $sp $sp 8

	# call iterate
	jal iterate

	# check if maxIter was reached
	lw $t1 maxIter
	seq $t0 $v0 $t1 # t0 = 1 if reached, 0 if not

	## if not reached, call computeColour ##
	# gonna do a hack so that we can exploit the bltzal instr. 
	# since i dont see another way to branch and link
	# subtract 1 from t0. Now -1 if not reached and 0 if reached
	addi $t0 $t0 -1
	move $a0 $v0
	li $v0 0 # write black as default colour if bltzal doesn't branch
	bltzal $t0 computeColour
	
	# ARGB colour stored in $v0 now
	# now write pixel information
	# lw $t0 ($s4)
	# addi $t0 $t0 0xffff
	sw $v0 ($s4)
	
	# reload $ra
	lw $ra 0($sp)
	addi $sp $sp 4

	addi $s4 $s4 4 # increments bitmap location
	j DMFor2

drawMandelbrot:
	# $f12 = a, $f13 = b
	
	# save $ra 
	sw $ra -4($sp)
	addi $sp $sp -4

	# loads bitmap initial address
	la $s4 bitmapDisplay

	# load dimensions
	lw $s0 resolution + 4
	lw $s1 resolution

	# run for loop
	jal DMFor1

	# # row, col store in v0, v1 now
	# # move them to save registers for later
	# move $s3 $v0
	# move $s4 $v1

	# reload $ra
	lw $ra 0($sp)
	addi $sp $sp 4

	# return
	jr $ra

########################################################################################
# Computes a colour corresponding to a given iteration count in $a0
# The colours cycle smoothly through green blue and red, with a speed adjustable 
# by a scale parametre defined in the static .data segment
computeColour:
	la $t0 scale
	lw $t0 ($t0)
	mult $a0 $t0
	mflo $a0
ccLoop:
	slti $t0 $a0 256
	beq $t0 $0 ccSkip1
	li $t1 255
	sub $t1 $t1 $a0
	sll $t1 $t1 8
	add $v0 $t1 $a0
	jr $ra
ccSkip1:
  	slti $t0 $a0 512
	beq $t0 $0 ccSkip2
	addi $v0 $a0 -256
	li $t1 255
	sub $t1 $t1 $v0
	sll $v0 $v0 16
	or $v0 $v0 $t1
	jr $ra
ccSkip2:
	slti $t0 $a0 768
	beq $t0 $0 ccSkip3
	addi $v0 $a0 -512
	li $t1 255
	sub $t1 $t1 $v0
	sll $t1 $t1 16
	sll $v0 $v0 8
	or $v0 $v0 $t1
	jr $ra
ccSkip3:
 	addi $a0 $a0 -768
 	j ccLoop
