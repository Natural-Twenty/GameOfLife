# board1.s ... Game of Life on a 10x10 grid

	.data

N:	.word 10  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

newBoard: .space 100
# Game of Life on a NxN grid
#
# Written by The Minh Tran June 2019
#
# --- Ideas to try out if time allows: ---
# Iterate copyBackAndShow without using i and j to calculate position - DONE
# Do the same for other i-j functions - requires changes to arguments of functions
# Recursion? 
# Using the provided newBoard allows us to iterate using the first idea provided we
# know at least the number of rows of columns. Divide newBoard by row/column to get 
# other dimension which allows us to "newline" every row.
# Implement checks for invalid boards. (Game of Life on a triagle?)
# 

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state

## Provides:
	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow


########################################################################
# Note: Comments that map to C code is mapped based on the provided life.c 
    .data
scanMsg:
    .asciiz "# Iterations: " 
endMsg0:
    .asciiz "=== After iteration "
endMsg1:
    .asciiz " ===\n"
dead:
    .byte 0
period:
    .asciiz "."
hash:
    .asciiz "#"
one:
    .byte 1
newline:
    .asciiz "\n"
# .TEXT <main>
	.text
main:

# Frame:	...
# Uses:		...
# Clobbers:	...

# Locals:	...

# Structure:
#	main
#	-> [prologue]

#	-> ...

#	-> [epilogue]

# Code:



#   prologue
    sw   $fp, -4($sp)        # push $fp onto stack
    la   $fp, -4($sp)        # set up $fp for main
    sw   $ra, -4($fp)        # save return address
    sw   $s0, -8($fp)        # save $s0 to use as ... int i
    sw   $s1, -12($fp)       # save $s1 to use as ... int j
    sw   $s2, -16($fp)       # save $s2 to use as ... int maxiters ...
    sw   $s3, -20($fp)       # save $s3 to use as pointer to newBoard
    sw   $s4, -24($fp)       # save $s4 to use as pointer to board
    sw   $s5, -28($fp)       # save $s5 to use as int n
    sw   $s6, -32($fp)       # save $s6 to use as int N
    sw   $s7, -36($fp)       # save $s7 to use as offset
    addi $sp, $sp, -40       # reset $sp to latest pushed item
    

#   code
    li   $s0, 0              # int i = 0
    li   $s1, 0              # int j = 0
    
    la   $a0, scanMsg
    li   $v0, 4
    syscall                  # printf("# Iterations: ")
    
    li   $v0, 5
    syscall                  # scanf("%d" into $v0)
    
    move $s2, $v0            # move scanned integer to $s2 (maxiters)
    la   $s3, newBoard       # $s3 = &newBoard[0][0]
    li   $s5, 1              # int n = 1
    la   $s6, N              # $s6 contains address of N
    lw   $s6, ($s6)          # $s6 contains N
    la   $s4, board          # $s4 is pointer to board matrix
iteration_loop:
    bgt  $s5, $s2, iteration_exit   # start of for(n; n < maxiter; n++) loop
    nop                             # nop fills a delay slot
i_loop:
    bge  $s0, $s6, i_exit    # start of for(i; i < N; i++) loop
    nop
j_loop:
    bge  $s1, $s6, j_exit    # start of for(j; j < N; j++) loop
    nop
    move $a0, $s0            # prep argument, int i for neighbours function
    move $a1, $s1            # prep argument, int j for neighbours function
    jal neighbours           # call neighbours(int i, int j) function
    nop
    move $a1, $v0            # retrieve return results from neighbours function (int nn)
    
    mul  $t3, $s6, $s0       # row offset = N * i
    add  $s7, $t3, $s1       # total offset = row offset + j
    add  $t4, $s7, $s4       # address of board[i][j] using offset
    lb   $a0, ($t4)          # load content of board[i][j] as argument
    jal decideCell           # call decideCell(int old, int nn) function
    nop
    add  $t4, $s7, $s3       # address of newBoard[i][j] using offset
    sb   $v0, ($t4)          # update newBoard[i][j] using return value of decideCell
    
    addi $s1, $s1, 1         # j++ 
    j j_loop                 # jump to beginning of for(j; j < N; j++) loop    
j_exit:                     
    li   $s1, 0              # int j = 0 (reset j)
    addi $s0, $s0, 1         # i++
    j i_loop                 # jump to beginning of for(i; i < N; i++) loop
    nop
i_exit:
    li   $v0, 4             
    la   $a0, endMsg0
    syscall                  # printf("=== After iteration ")
    
    li   $v0, 1
    move $a0, $s5
    syscall                  # printf("%d", n)
    
    li   $v0, 4
    la   $a0, endMsg1
    syscall                  # printf(" ===\n")
    
    jal copyBackAndShow      # call function copyBackAndShow()
    nop
    
    li   $s0, 0              # int i = 0 (reset i)
    addi $s5, $s5, 1         # n++
    j iteration_loop         # jump to beginning of for(n; n < maxiter; n++) loop
    nop
iteration_exit:
#   epilogue
    lw   $s7, -36($fp)       # restore $s7 value
    lw   $s6, -32($fp)       # restore $s6 value
    lw   $s5, -28($fp)       # restore $s5 value
    lw   $s4, -24($fp)       # restore $s4 value
    lw   $s3, -20($fp)       # restore $s3 value
    lw   $s2, -16($fp)       # restore $s2 value
    lw   $s1, -12($fp)       # restore $s1 value
    lw   $s0, -8($fp)        # restore $s0 value
    lw   $ra, -4($fp)        # restore $ra for return
    la   $sp, 4($fp)         # restore $sp - remove stack frame
    lw   $fp, ($fp)          # restore $fp - remove stack frame
	jr   $ra                 # return 0

#main__post:

decideCell: # --- Tested - Working (correct inputs and outputs according to qtspim)
#   prologue                 $a0 = old, $a1 = nn (passed from main)
    sw   $fp, -4($sp)        # push $fp onto stack
    la   $fp, -4($sp)        # set up $fp for this function
    sw   $ra, -4($fp)        # save return address
    sw   $s0, -8($fp)        # save $s0 to use as ... char old 
    sw   $s1, -12($fp)       # save $s1 to use as ... int nn
    sw   $s2, -16($fp)       # save $s2 to use as ... char ret    
    addi $sp, $sp, -20       # reset $sp to latest pushed item
    
#   code

    la   $t0, dead           # We'll use la $s0, $t0 or $t1 to assign the char.
    lb   $t0, ($t0)          # "0" character
    la   $t1, one
    lb   $t1, ($t1)          # "1" character
    move $s0, $a0            # $s0, char old argument, changed to match types (board is char matrix)
    move $s1, $a1            # $s1, int nn argument
    
    bne  $s0, $t1, checkNeighbour0A # if (old == '1')
    nop
    li   $t2, 2
    bge  $s1, $t2, checkNeighbour1A # if (nn < 2)
    nop
    move $v0, $t0            # ret = '0'
    j if_exit                # exit control structure
    nop
checkNeighbour1A:            # else if
    beq  $s1, $t2, checkNeighbour1B # (nn == 2 || nn == 3)
    nop
    li   $t2, 3
    beq  $s1, $t2, checkNeighbour1B 
    nop
    move $v0, $t0            # ret = '0'
    j if_exit                # exit control structure
    nop
checkNeighbour1B:            # else  
    move $v0, $t1            # ret = '1'
    j if_exit                # exit control structure
    nop
checkNeighbour0A:
    li   $t2, 3              # else if
    bne  $s1, $t2, checkNeighbour0B # (nn = 3)
    nop
    move  $v0, $t1           # ret = '1'
    j if_exit                # exit control structure
    nop
checkNeighbour0B:
    move  $v0, $t0          
if_exit:      
#   epilogue  
    lw   $s2, -16($fp)       # restore $s2 value  
    lw   $s1, -12($fp)       # restore $s1 value
    lw   $s0, -8($fp)        # restore $s0 value
    lw   $ra, -4($fp)        # restore return address
    la   $sp, 4($fp)         # restore $sp - remove stack frame
    lw   $fp, ($fp)          # restore $fp - remove stack frame
    jr   $ra                 # return ret

neighbours: # --- Tested - Working (correct inputs and outputs according to qtspim)
#   prologue                   a0 = i, $a1 = j
    sw   $fp, -4($sp)        # push $fp onto stack
    la   $fp, -4($sp)        # set up $fp for this function
    sw   $ra, -4($fp)        # save return address
    sw   $s0, -8($fp)        # save $s0 to use as ... int i
    sw   $s1, -12($fp)       # save $s1 to use as ... int j
    sw   $s2, -16($fp)       # save $s2 to use as pointer to board matrix
    addi $sp, $sp, -20       # reset stack pointer to last pushed item
    
#   code body  
    li   $v0, 0              # int nn = 0;
    move $s0, $a0            # move argument i to saved register
    move $s1, $a1            # move argument j to saved register
    la   $s2, board
    li   $t0, -1             # int x (saved into callee saved register, $t0) = -1
    li   $t1, -1             # int y (saved into callee saved register, $t1) = -1
    la   $t2, N              # load dimension of board from boardX.s into $t2
    lw   $t2, ($t2)
    li   $t3, 1              # load integer 1 into temporary registry
    sub  $t6, $t2, $t3       # $t5 holds N - 1
    lb   $t9, one            # The byte '1' to compare the element to
x_loop:
    bgt  $t0, $t3, x_exit    # beginning of for(x; x <= 1; x++) loop
    nop
y_loop:
    bgt  $t1, $t3, y_exit    # beginning of for(y; y <= 1; y++) loop
    nop
    
    add  $t4, $s0, $t0       # $t4 = i + x
    blt  $t4, $zero, Continue   # if (i + x < 0 || i + x > N - 1) continue
    nop
    bgt  $t4, $t6, Continue
    nop
    
    add  $t5, $s1, $t1       # $t5 = j + y
    blt  $t5, $zero, Continue   # if (j + y < 0 || j + y > N - 1) continue
    nop
    bgt  $t5, $t6, Continue
    nop
    
    bne  $t0, $zero, final_condition    # if (x == 0 && y == 0) continue 
    nop
    bne  $t1, $zero, final_condition
    nop
Continue:
    addi $t1, $t1, 1         $ y++
    j y_loop                 # jump to beginning of for(y; y <= 1; y++) loop
    nop
final_condition:             
    mul  $t7, $t4, $t2       # $t7 is the offset = row * N  +
    add  $t7, $t7, $t5       #                     column
    add  $t8, $s2, $t7       # $t8 is the address of the element of interest
    lb   $t8, ($t8)          # load the byte content of the element into $t8
    bne  $t8, $t9, Continue  # if (board[i + x][j + y] == 1) 
    nop
    addi $v0, $v0, 1         # n++;
    j Continue               # continues the loop
    nop
y_exit:
    addi $t0, $t0, 1         # x++
    li   $t1, -1             # y = 0 (reset y)
    j x_loop                 # jump back to beginning of for(x; x <= 1; x++) loop
    nop
x_exit: 
#   epilogue
    lw   $s2, -16($fp)       # restore $s2 value
    lw   $s1, -12($fp)       # restore $s1 value
    lw   $s0, -8($fp)        # restore $s0 value
    lw   $ra, -4($fp)        # restore return address
    la   $sp, 4($fp)         # restore $sp - remove stack frmae
    lw   $fp, ($fp)          # restore $fp - remove stack frame
    jr   $ra                 # return nn
    
# --- Tested - Working (correct output according to terminal and qtspim) ---
copyBackAndShow:
#   prologue
    sw   $fp, -4($sp)        # push $fp onto stack
    la   $fp, -4($sp)        # set up $fp for this function
    sw   $ra, -4($fp)        # save return address
    sw   $s0, -8($fp)        # save $s0 to use as ... board matrix
    sw   $s1, -12($fp)       # save $s1 to use as ... newBoard matrix
    addi $sp, $sp, -16       # reset $sp to last pushed item   
#   code body
    la   $s0, board          # $s1 points to beginning of board matrix
    la   $s1, newBoard       # $s2 points to beggining of newBoard matrix
    la   $t0, N              # load address of board dimension
    lw   $t0, ($t0)          # load the content of the address above
    li   $t1, 1              # counter to N 
    la   $t2, one            
    lb   $t2, ($t2)          # $t2 = '1'
    li   $t4, 0              # counter to N*N to iterate through the matrix 
    mul  $t5, $t0, $t0       # N*N is the number of iterations required to go though the matrix
board_loop:               
    bge  $t4, $t5, board_exit_loop  # Essentially does the for(int i = 0; i < N; i++)
    nop                             # and for(int j = 0; j < N; j++) loops
    lb   $t3, ($s1)          # load newBoard[i][j]
    sb   $t3, ($s0)          # board[i][j] = newBoard[i][j]
    beq  $t3, $t2, hash_branch      # if (board[i][j] == "0")
    nop       
    la   $a0, period                
    la   $v0, 4
    syscall                         # putchar(".")
    j converge_branch
    nop
hash_branch:                 # else
    la   $a0, hash           
    la   $v0, 4
    syscall                  # putchar("#")
converge_branch:             # code that would appear in both branches goes here
    addi $s0, $s0, 1         # go to next byte in board matrix (offset++)
    addi $s1, $s1, 1         # go to next byte in newBoard matrix (offset++)
    bne  $t1, $t0, continue  # if N counter is at N, print newline
    nop
    li   $v0, 4
    la   $a0, newline        
    syscall                  # printf("\n") every N board_loops
    li   $t1, 0              # reset N counter (N = 0)
continue:
    addi $t1, $t1, 1         # brings N back to default 1
    addi $t4, $t4, 1         # increase N*N counter by 1
    j board_loop             # jump back to beginning of loop
board_exit_loop:
#   epilogue
    lw   $s1, -12($fp)       # restore $s1 value
    lw   $s0, -8($fp)        # restore $s0 value
    lw   $ra, -4($fp)        # restore return address
    la   $sp, 4($fp)         # restore $sp - remove stack frame
    lw   $fp, ($fp)          # restore $fp - remove stack frame
    jr   $ra                 # returns to return address (continues main function)

