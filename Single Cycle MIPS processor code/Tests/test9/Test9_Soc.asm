#################################
# This Test is created to verify the TIMER and GPIO connected Peripheral:
#################################
# Kernel will initalize $gp and $sp first to specify our used Memory.
addi $sp, $0, 0x7FFC					# $sp is located in the Reg file at address 29
addi $gp, $0, 0x1080  					# $gp is located in the Reg file at address 28
jal main								# main is located at 0x0400
#################################
main:
	addi $sp, $sp, −4 					# Move $sp one location to store thre return address.
	sw $ra, 0($sp) 						# store $ra (return address of OS before starting the main funtion) on stack
	#################################
	jal gpio_send_high_config
	jal timer_config
	jal gpio_send_low_config
	jal timer_config
	jal gpio_send_high_config
	jal timer_config
	jal gpio_send_low_config
	#################################
	Iw $ra, 0($sp) 						# restore $ra from stack
	addi $sp, $sp, 4 					# restore stack pointer
	jr $ra 								# return to operating system
#################################
gpio_send_high_config:
	lui $t0, 0xA000
	ori $t0, $t0, 0x0000
	lui $t1, 0x0000
	ori $t1, $t1, 0x0078
	sw  $t1, 0x0($t0)         			# Send logic HIGH to GPIO #3,4,5,6 which are connected to the LEDs.
	jr $ra 	
#################################
gpio_send_low_config:
	lui $t0, 0xA000
	ori $t0, $t0, 0x0000
	lui $t1, 0x0000
	ori $t1, $t1, 0x0000
	sw  $t1, 0x0($t0)         			# Send logic LOW to GPIO #3,4,5,6 which are connected to the LEDs.
	jr $ra 	
#################################
timer_config:
	lui $t0, 0xA000
	ori $t0, $t0, 0x0C00
	lui $t1, 0x0000
	ori $t1, $t1, 0x0001
	lui $t2, 0x07FF
	ori $t2, $t2, 0xFFFF
	sw  $t2, 0x4($t0)         			# Send Current Value with 0x07FF_FFFF = 1.3Sec if your freq=100MHz.
	sw  $t2, 0x8($t0)         			# Send Reload Value with 0x07FF_FFFF = 1.3Sec if your freq=100MHz.
	sw  $t1, 0x0($t0)         			# Set the Timer Enable.
	lui $t3, 0x0000
	ori $t3, $t3, 0x0000
	wait_loop: lw  $t4, 0x4($t0)  
	beq $t3, $t4, exit_wait_loop
	j wait_loop
	exit_wait_loop: jr $ra 
	
	