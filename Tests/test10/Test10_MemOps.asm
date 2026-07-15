#################################
# This Test is created to verify the Load and Store Instructions:
#   lw, sw, lh, lhu, sh, lb, lbu, sb
#################################
# Kernel will initialize $gp and $sp first to specify our used Memory.
addi $sp, $0, 0x7FFC				# $sp is located in the Reg file at address 29
addi $gp, $0, 0x1080  				# $gp is located in the Reg file at address 28
jal main							# main is located at 0x0400
#################################
main:
	# Base address for load/store tests
	addi $t0, $0, 0x1000			# $t0 = 0x1000

	# 1. Test Word Store and Load (sw, lw)
	lui $t1, 0x1234
	ori $t1, $t1, 0x5678			# $t1 = 0x12345678
	sw $t1, 0($t0)					# RAM[0x1000] = 0x12345678
	lw $t2, 0($t0)					# $t2 = RAM[0x1000] = 0x12345678
	lui $t3, 0x1234
	ori $t3, $t3, 0x5678			# $t3 = 0x12345678
	bne $t2, $t3, ERROR

	# 2. Test Halfword Store and Load (sh, lh - positive value)
	sh $t1, 4($t0)					# RAM[0x1004] = 0x5678
	lh $t4, 4($t0)					# $t4 = 0x00005678 (sign-extended positive)
	addi $t5, $0, 0x5678			# $t5 = 0x00005678
	bne $t4, $t5, ERROR

	# 3. Test Halfword Store and Load (sh, lh - negative value)
	lui $t1, 0x0000
	ori $t1, $t1, 0x89AB			# $t1 = 0x000089AB
	sh $t1, 6($t0)					# RAM[0x1006] = 0x89AB
	lh $t4, 6($t0)					# $t4 = 0xFFFF89AB (sign-extended negative)
	lui $t5, 0xFFFF
	ori $t5, $t5, 0x89AB			# $t5 = 0xFFFF89AB
	bne $t4, $t5, ERROR

	# 4. Test Halfword Load Unsigned (lhu)
	lhu $t4, 6($t0)					# $t4 = 0x000089AB (zero-extended)
	ori $t5, $0, 0x89AB				# $t5 = 0x000089AB
	bne $t4, $t5, ERROR

	# 5. Test Byte Store and Load (sb, lb - negative value)
	sb $t1, 8($t0)					# RAM[0x1008] = 0xAB
	lb $t6, 8($t0)					# $t6 = 0xFFFFFFAB (sign-extended negative)
	lui $t7, 0xFFFF
	ori $t7, $t7, 0xFFAB			# $t7 = 0xFFFFFFAB
	bne $t6, $t7, ERROR

	# 6. Test Byte Load Unsigned (lbu)
	lbu $t6, 8($t0)					# $t6 = 0x000000AB (zero-extended)
	ori $t7, $0, 0x00AB				# $t7 = 0x000000AB
	bne $t6, $t7, ERROR

	# 7. Test Byte Store and Load (sb, lb - positive value)
	ori $t1, $0, 0x004F				# $t1 = 0x0000004F
	sb $t1, 9($t0)					# RAM[0x1009] = 0x4F
	lb $t6, 9($t0)					# $t6 = 0x0000004F (sign-extended positive)
	ori $t7, $0, 0x004F				# $t7 = 0x0000004F
	bne $t6, $t7, ERROR

	j DONE

ERROR:
	addi $s0, $0, 0xDEAD
	j SKIP

DONE:
	addi $s0, $0, 0xD08E

SKIP:
	jr $ra
