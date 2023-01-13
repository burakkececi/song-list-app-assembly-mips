##############################################################
#Dynamic array
##############################################################
#   4 Bytes - Capacity
#	4 Bytes - Size
#   4 Bytes - Address of the Elements
##############################################################

##############################################################
#Song
##############################################################
#   4 Bytes - Address of the Name (name itself is 64 bytes)
#   4 Bytes - Duration
##############################################################


.data
space: .asciiz " "
newLine: .asciiz "\n"
tab: .asciiz "\t"
menu: .asciiz "\n● To add a song to the list-> \t\t enter 1\n● To delete a song from the list-> \t enter 2\n● To list all the songs-> \t\t enter 3\n● To exit-> \t\t\t enter 4\n"
menuWarn: .asciiz "Please enter a valid input!\n"
name: .asciiz "Enter the name of the song: "
duration: .asciiz "Enter the duration: "
name2: .asciiz "Song name: "
duration2: .asciiz "Song duration: "
emptyList: .asciiz "List is empty!\n"
noSong: .asciiz "\nSong not found!\n"
songAdded: .asciiz "\nSong added.\n"
songDeleted: .asciiz "\nSong deleted.\n"

copmStr: .space 64

sReg: .word 3, 7, 1, 2, 9, 4, 6, 5
songListAddress: .word 0 #the address of the song list stored here!

.text 
main:

	jal initDynamicArray
	sw $v0, songListAddress
	
	la $t0, sReg
	lw $s0, 0($t0)
	lw $s1, 4($t0)
	lw $s2, 8($t0)
	lw $s3, 12($t0)
	lw $s4, 16($t0)
	lw $s5, 20($t0)
	lw $s6, 24($t0)
	lw $s7, 28($t0)

menuStart:
	la $a0, menu    
    li $v0, 4
    syscall

	li $v0,  5
    syscall
	li $t0, 1
	beq $v0, $t0, addSong
	li $t0, 2
	beq $v0, $t0, deleteSong
	li $t0, 3
	beq $v0, $t0, listSongs
	li $t0, 4
	beq $v0, $t0, terminate
	
	la $a0, menuWarn    
    li $v0, 4
    syscall
	b menuStart
	
addSong:
	jal createSong
	lw $a0, songListAddress
	move $a1, $v0
	jal putElement
	b menuStart
	
deleteSong:
	lw $a0, songListAddress
	jal findSong
	lw $a0, songListAddress
	move $a1, $v0
	jal removeElement
	b menuStart
	
listSongs:
	lw $a0, songListAddress
	jal listElements
	b menuStart
	
terminate:
	la $a0, newLine		
	li $v0, 4
	syscall
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	move $a0, $s1
	syscall
	move $a0, $s2
	syscall
	move $a0, $s3
	syscall
	move $a0, $s4
	syscall
	move $a0, $s5
	syscall
	move $a0, $s6
	syscall
	move $a0, $s7
	syscall
	
	li $v0, 10
	syscall


initDynamicArray:
	li $a0, 12
	li $v0, 9
	syscall  # initialize the 12 bytes space for dynamic memory allocation.

	move $t0, $v0 # move the address of dynamic array to temp reg.

	li $a0, 8
	li $v0, 9
	syscall # initialize the size of 2 elements array

	li $t1, 2 # capacity
	li $t2, 0 # size

	sw $t1, 0($t0) 
	sw $t2, 4($t0) 
	sw $v0, 8($t0) # memory address of elements array saved in dynamic memory spcae
 
	move $v0, $t0
	# s0-s7 are not changed
	# v0 register holds address of dynamic array
	jr $ra

putElement:
	addi $sp, $sp, 4
	sw $a0, 0($sp)

	lw $t0, 0($a0) # t0 = load capacity of the elements array 
	lw $t1, 4($a0) # t1 = load size of the elements array
	bne $t0, $t1, exitPutElement

increaseCapacity:
	sll $t0, $t0, 1 # t0 = old capacity * 2 for dynamic array field
	sll $t1, $t0, 2 # t1 = new capacity * 4 for elements array

	move $a0, $t1 # a0 = new capacity * 4 
	li $v0, 9
	syscall

	lw $a0, 0($sp) # a0 = dynamic array
	sw $t0, 0($a0) # new array capacity -> dynamic array capacity

	move $t0, $v0 # new array adress -> t0
	lw $t1, 8($a0) # t1 = old array address
	sw $t0, 8($a0) # v0 -> new array address to dynamic array
	
	lw $t2, 4($a0) # t0 = array size
	lw $t3, 0($a0) # t6 = array capacity

	li $t4, 0 # t3 = 0 iterative

	# t0 = new array address, t1 = old array address, t2 = array size, t3 = array capacity, t4 = iterative
loopPutElement:
	beq $t4, $t2, loopPutElement2 # iterative == array size

	sll $t5, $t4, 2 # t4 = iterative * 4
	add $t6, $t0, $t5 # t5 = new array + t1
	add $t7, $t1, $t5 # t6 = old array + t1

	lw $t8, 0($t7) # t5 = old array index word
	sw $t8, 0($t6) # t0(index) = t5
	
	addi $t4, $t4, 1 # i += 1
	
	j loopPutElement

loopPutElement2:	
	beq $t4, $t3, exitPutElement # iterative == old array capacity
	sll $t5, $t4, 2 # t4 = iterative * 4
	add $t6, $t0, $t5 # t5 = new array + t1

	sw $zero, 0($t6)

	addi $t4, $t4, 1
	
	j loopPutElement2

exitPutElement:
	lw $a0, 0($sp)
	lw $t1, 4($a0) # t1 = load size of the elements array
	lw $t2, 8($a0) # t2 = load address of elements array from dynamic memory

	sll $t3, $t1, 2 # t3 = size of elements array * 4
	add $t3, $t2, $t3 # t2 = add size*4 to array's address
	sw $a1, 0($t3) # a1 -> store song adress into elements array 

	addi $t1, $t1, 1 # t1 = size = size + 1
	sw $t1, 4($a0) # t1 -> store size of elements into dynamic array

	la $a0, songAdded # a0 = string
	li $v0, 4
	syscall

	jr $ra
	

removeElement:
	
	addi $sp, $sp, -4
	sw $a0, 0($sp)

	lw $t0, 0($a0) # t0 = load capacity of the elements array 
	lw $t1, 4($a0) # t1 = load size of the elements array
	bne $t0, $t1, removeElementFunc

	lw $t0, 8($a0) # elements array
	addi $a1, $a1, 1

removeElementFunc:

	lw $a0, 0($sp)
	addi $sp, $sp, 4
	lw $t0, 4($a0) # t1 = load size of the elements array
	lw $t1, 8($a0) # t2 = load address of elements array from dynamic memory
removeloop:

	slt $t3, $a1, $t0 # i < size
	beq $t3, $zero, exitRemoveElement # i not than loop2
	sll $t3, $a1, 2  # i+1  * 4 
	add $t3, $t1, $t3 # t2 = add size*4 to array's address
	lw $t4, 0($t3)
	addi $t3, $t3, -4
	sw $t4, 0($t3)

	addi $a1, $a1, 1

	j removeloop

exitRemoveElement:
	addi $a1, $a1, -1
	sll $a1, $a1, 2
	add $t2, $t1, $a1
	sw $zero, 0($t2)

	addi $t0, $t0, -1 # t1 = size = size - 1
	sw $t0, 4($a0) # t1 -> store size of elements into dynamic array

	la $a0, songDeleted
	li $v0, 4
	syscall

	jr $ra

decreaseCapacity:
	lw $t0, 0($a0) # capacity
	srl $t0, $t0, 1 # t0 = old capacity / 2 for dynamic array field
	sll $t1, $t0, 2 # t1 = new capacity * 4 for elements array

	move $a0, $t1 # a0 = new capacity * 4 
	li $v0, 9
	syscall

	lw $a0, 0($sp) # a0 = dynamic array
	sw $t0, 0($a0) # new array capacity -> dynamic array capacity

	move $t0, $v0 # new array adress -> t0
	lw $t1, 8($a0) # t1 = old array address
	sw $t0, 8($a0) # v0 -> new array address to dynamic array
	
	lw $t2, 4($a0) # t0 = array size
	lw $t3, 0($a0) # t6 = array capacity

	li $t4, 0 # t3 = 0 iterative

	# t0 = new array address, t1 = old array address, t2 = array size, t3 = array capacity, t4 = iterative
loopRemoveElement:
	beq $t4, $t2, exitMain # iterative == array size

	sll $t5, $t4, 2 # t4 = iterative * 4
	add $t6, $t0, $t5 # t5 = new array + t1
	add $t7, $t1, $t5 # t6 = old array + t1

	lw $t8, 0($t7) # t5 = old array index word
	sw $t8, 0($t6) # t0(index) = t5
	
	addi $t4, $t4, 1 # i += 1
	
	j loopRemoveElement
exitMain:
	jr $ra

listElements:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	move $s0, $a0

	lw $t0, 4($s0) # size of array
	lw $s1, 8($s0) # address of element array
	move $t9, $zero # t1 = 0, t1 = i,
	
	bne $t0, $t9, listLoop # size == 0

	la $a0, emptyList
	li $v0, 4
	syscall

	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra

	# a0 = elements array, t0 = array size, t1 = 0 
listLoop:
	lw $t0, 4($s0) # size of array
	slt $t2, $t9, $t0 # t1 = i < size
	beq $t2, $zero, exitListLoop # if i == size then exit
	
	sll $t2, $t9, 2 # i * 4
	add $t3, $s1, $t2 # i + elements array head
	lw $a0, 0($t3) 

	jal printElement

	addi $t9, $t9, 1

	j listLoop

exitListLoop:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 8

	jr $ra

compareString:
	# a0 = compstr, a1 = songlist str, a2 = compSize 
	lb $t0, 0($a0)
	lb $t1, 0($a1)                   
    bne $t0,$t1, notEqualString      

    beq $t0,$zero, equalString              

    addi $a0,$a0,1                 
    addi $a1,$a1,1

    j compareString

equalString:
	li $v0, 1
	jr $ra

notEqualString:
	li $v0, 0
	jr $ra
	
printElement:
	
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)

	jal printSong # transition

	lw $ra, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8

	jr $ra

createSong:
	
	li $a0, 8 # heap allocation for creating song.
	li $v0, 9
	syscall

	move $t0, $v0 # return address of song into t0 reg

	la $a0, name # display string
	li $v0, 4
	syscall

	li $v0, 9
	li $a0, 64
	syscall

	move $a0, $v0 # string input buffer saved into 0($t0)
	li $a1, 64 # max 64 byte string acceptable
	li $v0,8 
	syscall

	sw $a0, 0($t0)

	la $a0, duration # display string
	li $v0, 4
	syscall

	li $v0, 5 # read int 
	syscall

	sw $v0, 4($t0) # return input int to 4($t0)

	move $v0, $t0 # return subroutine with putting song address into $v0

	jr $ra

findSong:

	addi $sp, $sp, 4
	sw $ra, 0($sp)

	move $t9, $a0 

	lw $t8, 8($t9)
	lw $t7, 4($t9) # size of array
	
	la $a0, name
	li $v0, 4
	syscall

	la $a0, copmStr
	li $a1, 64
	li $v0, 8
	syscall

	li $a2, 64 # comparison size
	li $t2, 0 # i
	li $t6, 1
	move $v0, $zero
findSongLoop:
	slt $t3, $t2, $t7 # t1 = i < size
	beq $t3, $zero, exitfindSongLoop # if i == size then exit
	
	sll $t3, $t2, 2 # i * 4
	add $t3, $t3, $t8 # i + elements array head
	lw $t4, 0($t3)
	lw $a1, 0($t4)
	
	jal compareString	#a0 copmstr
	beq $v0, $t6, exitfindSongLoop 
	li $v0, -1

	addi $t2, $t2, 1
	j findSongLoop

exitfindSongLoop:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $v0, $t2 
	jr $ra

printSong:

	move $t0, $a0 # move address of song

	la $a0, name2 # display string
	li $v0, 4
	syscall

	lw $a0, 0($t0) # song element name address copy into a0
	li $v0, 4
	syscall

	la $a0, duration2 # display string
	li $v0, 4
	syscall

	lw $a0, 4($t0) # song element duration copy into a0
	li $v0, 1
	syscall

	la $a0, newLine # display string
	li $v0, 4
	syscall
	
	jr $ra

additionalSubroutines:
