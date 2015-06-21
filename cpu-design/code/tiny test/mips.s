label
lw $t0, 0($a1)
add $t1, $t1, $t0
addi $a1, $a1, 4
bne $a1, $t2, label
sw $t1, 0($a1)