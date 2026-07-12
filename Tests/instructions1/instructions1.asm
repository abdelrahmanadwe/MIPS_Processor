add $16,$0,$0
addi $16,$0,7
add $17,$0,$0
addi $17,$0,1
beq $16,$0,target
mul $17,$17,$16
addi $16,$16,-1
j 0x10
target: sw $17,0x1000($0)
