##################################################################### 
# 
# CSCB58 Winter 2022 Assembly Final Project 
# University of Toronto, Scarborough 
# 
# Student: Sauhaard Walia, 1006726483, waliasau, sauhaard.walia@mail.utoronto.ca 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 (update this as needed)  
# - Unit height in pixels: 8 (update this as needed) 
# - Display width in pixels: 256 (update this as needed) 
# - Display height in pixels: 256 (update this as needed) 
# - Base Address for Display: 0x10008000 ($gp) 
# 
# Which milestones have been reached in this submission? 
# (See the assignment handout for descriptions of the milestones) 
# - Milestone 1/2/3 (choose the one the applies) 
# - Milestone 3
# 
# Which approved features have been implemented for milestone 3? 
# (See the assignment handout for the list of additional features) 
# 1. A. Health/Score [2 marks]
# 2. B. Fail Condition [1 mark] 
# 3. C. Win Condition [1 mark]  
# 4. D. Moving Objects [2 marks]
# 5. G. Different Levels [2 marks]
# 
# 
# Link to video demonstration for final submission: 
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it! 
# 
# Are you OK with us sharing the video with people outside course staff? 
# - yes / no / yes, and please share this project github link as well! 
# - Yes I am ok with it, the link to the github is:
# 
# Any additional information that the TA needs to know: 
# - I also attempted to implement the start menu but due to the complexity in figuring out how to move the cursor rather than just 
# allowing the user to input the key as their choice (the prof said there wont be marks rewarded for this) I was unable to achieve this 
# feature
# 
##################################################################### 

.eqv	PINK		0xFADADD
.eqv	WHITE		0xFFFFFF
.eqv 	ORANGE		0xFA5E00
.eqv 	YELLOW		0xFFFD00
.eqv 	BLUE	 	0x1AA7EC
.eqv 	BROWN 		0x964B00
.eqv	RED		0xFF0000
.eqv	GREEN		0x00FF00
.eqv 	BLACK 		0x000000
.eqv 	PURPLE 		0x6A0DAD
.eqv 	LIGHT_BLUE 	0x00E3FF

.eqv	START_OF_DISPLAY	0x10008000

.data	
	ARRAY_OF_SUN: .space 20
	ARRAY_OF_SUN_second: .space 20
	ARRAY_OF_SUN_third: .space 20
	
	ARRAY_OF_SNAKE: .space 24
	ARRAY_OF_SNAKE_second: .space 24
	ARRAY_OF_SNAKE_third: .space 24
	
	
	ARRAY_OF_PLATFORMS: .space 160
	ARRAY_OF_PLATFORMS_second: .space 160
	ARRAY_OF_PLATFORMS_third: .space 160
	
	
	CURRENT_POSITION: 0x10008000
	CURRENT_SNAKE: 0x10008000
	SNAKE_COUNTER: 0
	CURRENT_VERTICAL: .word 0 #1 represents go up, 0 represents we are supposed to fall
	JUMP_COUNTER: .word 0 #stores how many jumps we have currently already done, after 8 it will fall again
	HEARTS: .word 3
	


.text		
initial:
	
	jal paint_background		# call the paint background function
	jal paint_bottom_line
	jal draw_platforms
	jal draw_sun
	jal draw_evil_insect
	jal draw_hearts

	
	lw $t0, CURRENT_POSITION	# to set the initial position for the character
	addi $t0, $t0, 1500		# move the character to desired starting position
	sw $t0, CURRENT_POSITION	# change the value in the global variable
	jal draw_player			# called to draw the actual character
	

	
main_loop:
	
	li $t9, 0xffff0000  
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened 
	
	j move_character_vertical
	
	keypress_happened:
	lw $t2, 4($t9) 
	beq $t2, 0x61, respond_to_a   # checking if 'a' was pressed
	beq $t2, 0x64, respond_to_d   # checking if 'd' was pressed
	beq $t2, 0x70, respond_to_p   # checking if 'p' was pressed	

	
	j move_character_vertical
	
	respond_to_p:
		j p_restart
		
	respond_to_a:
		li $t0, START_OF_DISPLAY	# Storing the start of the display
		lw $t1, CURRENT_POSITION	# Storing the current position of the character
		sub $t2, $t1, $t0		# Finding the characters relative position to the start
		li $t3, 128			# Store this value here as we will use it later to check if at start
		div $t2, $t3			# Divide current location by 128
		mfhi $t4			# Fetch the remainder
		beqz $t4, move_character_vertical # If remainder is 0 only move vertically
		subi $t1, $t1, 4		#else move character one place to the left
		sw $t1, CURRENT_POSITION
		
		jal paint_background		# call the paint background function
	
		jal paint_bottom_line
		jal draw_platforms
		jal draw_sun
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left
		
		move_right: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw
		 
		move_left:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw
			
		draw:
		jal draw_evil_insect
		jal draw_hearts
		jal draw_player	

		
		
		j move_character_vertical
		
	respond_to_d:
		li $t0, START_OF_DISPLAY	# Storing the start of the display
		lw $t1, CURRENT_POSITION	# Storing the current position of the character
		sub $t2, $t1, $t0		# Finding the characters relative position to the start
		li $t3, 128			# Store this value here as we will use it later to check if at start
		subi $t2, $t2, 116			# To check if character is at right most point
		
		div $t2, $t3			# Divide current location by 128
		mfhi $t4			# Fetch the remainder
		beqz $t4, move_character_vertical # If remainder is 0 only move vertically
		addi $t1, $t1, 4		#else move character one place to the left
		sw $t1, CURRENT_POSITION
		
		jal paint_background		# call the paint background function
	
		jal paint_bottom_line
		jal draw_platforms
		jal draw_sun
		
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_1
		
		move_right_1: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_1
		 
		move_left_1:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_1
		draw_1:
		jal draw_evil_insect
		jal draw_hearts
		jal draw_player	
		
		j move_character_vertical
	
			
	
	move_character_vertical:
		lw $t1, CURRENT_VERTICAL
		beq $t1, 1, bounce
		beq $t1, 0, fall
		
	bounce: 
		
		lw $t0, CURRENT_POSITION	# to fetch the initial position for the character
		subi $t0, $t0, 128
		sw $t0, CURRENT_POSITION # to update the initial position for the character
		
		jal paint_background		# call the paint background function
		jal paint_bottom_line
		jal draw_platforms
		jal draw_sun
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_2
		
		move_right_2: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_2
		 
		move_left_2:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_2
		draw_2:
		jal draw_evil_insect
		jal draw_hearts
		jal draw_player


		lw $t3, JUMP_COUNTER
		addi $t3, $t3, 1 # so that we can increment jump counter
		sw $t3, JUMP_COUNTER
		
		beq $t3, 12, change_to_fall
		
		j sleep
		
		change_to_fall:
			li $t5, 0
			sw $t5, CURRENT_VERTICAL
			sw $t5, JUMP_COUNTER
			j sleep
		
	
	fall:
		lw $t0, CURRENT_POSITION	# to fetch the initial position for the character
		addi $t0, $t0, 128
		sw $t0, CURRENT_POSITION # to update the initial position for the character	
	
		jal paint_background		# call the paint background function
		jal draw_sun
		jal draw_hearts

		jal draw_player
		
		jal paint_bottom_line
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_3
		
		move_right_3: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_3
		 
		move_left_3:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_3
		draw_3:
		
		jal draw_evil_insect
		jal draw_platforms

		lw $t0, CURRENT_POSITION # to update the initial position for the character	
		bge $t0, 268471812, lose_heart
		
		la $a0, ARRAY_OF_PLATFORMS
		lw $t0, CURRENT_POSITION
		
		addi $t1, $t0, 512 #bottom of left foot of character
		addi $t2, $t0, 520 #bottom of right foot of character
		
		li $t4, 0 # using t4 as a counter to see when we reach end of array
		li $t5, 120 # end of array point
		
		platform_check_loop:
			beq $t4, $t5, sun_check
				
			lw $t6, 0($a0)
			beq $t6, $t1, make_bounce
			beq $t6, $t2, make_bounce
			
			j increment
			
			make_bounce:
				li $t7, 1
				sw $t7, CURRENT_VERTICAL

			
			increment:
				addi $t4, $t4, 1 # increment the counter
			
				addi $a0, $a0, 4 # move to next element in array a
			
			j platform_check_loop
			
		sun_check:
			la $a0, ARRAY_OF_SUN
			lw $t0, CURRENT_POSITION # to update the initial position for the character
			addi $t4, $t0, 8
			addi $t5, $t0, 136
			
			li $t6, 0
			li $t7, 5
			
			sun_check_loop:
				beq $t6, $t7, snake_check
				lw $t8, 0($a0)
				
				#beq $t8, $t0, win_screen
				beq $t8, $t4, level_two
				beq $t8, $t5, level_two
				
				addi $t6, $t6, 1
				addi $a0, $a0, 4
				j sun_check_loop
				
		snake_check:
			la $a0, ARRAY_OF_SNAKE
			lw $t0, CURRENT_POSITION # to update the initial position for the character
			
			addi $t1, $t0, 512 #bottom of left foot of character
			addi $t2, $t0, 520 #bottom of right foot of character
			
			li $t6, 0
			li $t7, 6
		
			snake_check_loop:
				beq $t6, $t7, sleep
				lw $t8, 0($a0)
				
				#beq $t8, $t0, win_screen
				beq $t8, $t1, lose_heart
				beq $t8, $t2, lose_heart
				
				addi $t6, $t6, 1
				addi $a0, $a0, 4
				j snake_check_loop
	sleep:
		li $v0, 32
		li $a0, 40 # sleep for 40 miliseconds
		syscall
		j main_loop

level_two:
	li $t0, START_OF_DISPLAY
	sw $t0, CURRENT_POSITION
	sw $t0, CURRENT_SNAKE
	
	
	li $t0, 1
	sw $t0, CURRENT_VERTICAL
	
	li $t0, 0
	sw $t0, JUMP_COUNTER
	sw $t0, SNAKE_COUNTER
	
	
	jal paint_background		# call the paint background function
	
	jal paint_bottom_line
	jal draw_platforms_second
	jal draw_sun_second
	jal draw_evil_insect_second
	jal draw_hearts

	
	lw $t0, CURRENT_POSITION	# to set the initial position for the character
	addi $t0, $t0, 2012		# move the character to desired starting position
	sw $t0, CURRENT_POSITION	# change the value in the global variable
	jal draw_player			# called to draw the actual character
	

	
main_loop_second:
	
	li $t9, 0xffff0000  
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened_second
	
	j move_character_vertical_second
	
	keypress_happened_second:
	lw $t2, 4($t9) 
	beq $t2, 0x61, respond_to_a_second   # checking if 'a' was pressed
	beq $t2, 0x64, respond_to_d_second   # checking if 'd' was pressed
	beq $t2, 0x70, respond_to_p_second   # checking if 'p' was pressed	
	
	j move_character_vertical_second
	
	respond_to_p_second:
		j p_restart
		
	respond_to_a_second:
		li $t0, START_OF_DISPLAY	# Storing the start of the display
		lw $t1, CURRENT_POSITION	# Storing the current position of the character
		sub $t2, $t1, $t0		# Finding the characters relative position to the start
		li $t3, 128			# Store this value here as we will use it later to check if at start
		div $t2, $t3			# Divide current location by 128
		mfhi $t4			# Fetch the remainder
		beqz $t4, move_character_vertical_second # If remainder is 0 only move vertically
		subi $t1, $t1, 4		#else move character one place to the left
		sw $t1, CURRENT_POSITION
		
		jal paint_background		# call the paint background function
	
		jal paint_bottom_line
		jal draw_platforms_second
		jal draw_sun_second
				
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_10
		
		move_right_10: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_10
		 
		move_left_10:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_10
		draw_10:
		
		
		jal draw_evil_insect_second
		jal draw_hearts
		jal draw_player	

		
		
		j move_character_vertical_second
		
	respond_to_d_second:
		li $t0, START_OF_DISPLAY	# Storing the start of the display
		lw $t1, CURRENT_POSITION	# Storing the current position of the character
		sub $t2, $t1, $t0		# Finding the characters relative position to the start
		li $t3, 128			# Store this value here as we will use it later to check if at start
		subi $t2, $t2, 116			# To check if character is at right most point
		
		div $t2, $t3			# Divide current location by 128
		mfhi $t4			# Fetch the remainder
		beqz $t4, move_character_vertical_second # If remainder is 0 only move vertically
		addi $t1, $t1, 4		#else move character one place to the left
		sw $t1, CURRENT_POSITION
		
		jal paint_background		# call the paint background function
	
		jal paint_bottom_line
		jal draw_platforms_second
		jal draw_sun_second
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_11
		
		move_right_11: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_10
		 
		move_left_11:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_10
		draw_11:
		
		jal draw_evil_insect_second
		jal draw_hearts
		jal draw_player	
		
		j move_character_vertical_second
	
			
	
	move_character_vertical_second:
		lw $t1, CURRENT_VERTICAL
		beq $t1, 1, bounce_second
		beq $t1, 0, fall_second
		
	bounce_second: 
		
		lw $t0, CURRENT_POSITION	# to fetch the initial position for the character
		subi $t0, $t0, 128
		sw $t0, CURRENT_POSITION # to update the initial position for the character
		
		jal paint_background		# call the paint background function
		jal paint_bottom_line
		jal draw_platforms_second
		jal draw_sun_second
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_12
		
		move_right_12: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_12
		 
		move_left_12:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_12
		draw_12:
		
		jal draw_evil_insect_second
		jal draw_hearts
		jal draw_player


		lw $t3, JUMP_COUNTER
		addi $t3, $t3, 1 # so that we can increment jump counter
		sw $t3, JUMP_COUNTER
		
		beq $t3, 12, change_to_fall_second
		
		j sleep_second
		
		change_to_fall_second:
			li $t5, 0
			sw $t5, CURRENT_VERTICAL
			sw $t5, JUMP_COUNTER
			j sleep_second
		
	
	fall_second:
		lw $t0, CURRENT_POSITION	# to fetch the initial position for the character
		addi $t0, $t0, 128
		sw $t0, CURRENT_POSITION # to update the initial position for the character	
	
		jal paint_background		# call the paint background function

		jal draw_hearts

		
		
		jal paint_bottom_line
		jal draw_platforms_second
		jal draw_sun_second
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_13
		
		move_right_13: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_13
		 
		move_left_13:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_13
		draw_13:
		
		jal draw_evil_insect_second
		
		jal draw_player

		lw $t0, CURRENT_POSITION # to update the initial position for the character	
		bge $t0, 268471812, lose_heart
		
		la $a0, ARRAY_OF_PLATFORMS_second
		lw $t0, CURRENT_POSITION
		
		addi $t1, $t0, 512 #bottom of left foot of character
		addi $t2, $t0, 520 #bottom of right foot of character
		
		li $t4, 0 # using t4 as a counter to see when we reach end of array
		li $t5, 120 # end of array point
		
		platform_check_loop_second:
			beq $t4, $t5, sun_check_second
				
			lw $t6, 0($a0)
			beq $t6, $t1, make_bounce_second
			beq $t6, $t2, make_bounce_second
			
			j increment_second
			
			make_bounce_second:
				li $t7, 1
				sw $t7, CURRENT_VERTICAL

			
			increment_second:
				addi $t4, $t4, 1 # increment the counter
			
				addi $a0, $a0, 4 # move to next element in array a
			
			j platform_check_loop_second
			
		sun_check_second:
			la $a0, ARRAY_OF_SUN_second
			lw $t0, CURRENT_POSITION # to update the initial position for the character
			addi $t4, $t0, 8
			addi $t5, $t0, 136
			
			li $t6, 0
			li $t7, 5
			
			sun_check_loop_second:
				beq $t6, $t7, snake_check_second
				lw $t8, 0($a0)
				
				#beq $t8, $t0, win_screen
				beq $t8, $t4, level_three
				beq $t8, $t5, level_three
				
				addi $t6, $t6, 1
				addi $a0, $a0, 4
				j sun_check_loop_second
				
		snake_check_second:
			la $a0, ARRAY_OF_SNAKE_second
			lw $t0, CURRENT_POSITION # to update the initial position for the character
			
			addi $t1, $t0, 512 #bottom of left foot of character
			addi $t2, $t0, 520 #bottom of right foot of character
			
			li $t6, 0
			li $t7, 6
		
			snake_check_loop_second:
				beq $t6, $t7, sleep_second
				lw $t8, 0($a0)
				
				#beq $t8, $t0, win_screen
				beq $t8, $t1, lose_heart
				beq $t8, $t2, lose_heart
				
				addi $t6, $t6, 1
				addi $a0, $a0, 4
				j snake_check_loop_second
	sleep_second:
		li $v0, 32
		li $a0, 40 # sleep for 40 miliseconds
		syscall
		j main_loop_second


level_three: 
	li $t0, START_OF_DISPLAY
	sw $t0, CURRENT_POSITION
	sw $t0, CURRENT_SNAKE
	
	
	li $t0, 1
	sw $t0, CURRENT_VERTICAL
	
	li $t0, 0
	sw $t0, JUMP_COUNTER
	sw $t0, SNAKE_COUNTER
	
	jal paint_background		# call the paint background function
	
	jal paint_bottom_line
	jal draw_platforms_third
	jal draw_sun_third
	

	jal draw_evil_insect_third
	jal draw_hearts

	
	lw $t0, CURRENT_POSITION	# to set the initial position for the character
	addi $t0, $t0, 3468		# move the character to desired starting position
	sw $t0, CURRENT_POSITION	# change the value in the global variable
	jal draw_player			# called to draw the actual character
	

	
main_loop_third:
	
	li $t9, 0xffff0000  
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened_third
	
	j move_character_vertical_third
	
	keypress_happened_third:
	lw $t2, 4($t9) 
	beq $t2, 0x61, respond_to_a_third   # checking if 'a' was pressed
	beq $t2, 0x64, respond_to_d_third   # checking if 'd' was pressed
	beq $t2, 0x70, respond_to_p_third   # checking if 'p' was pressed	
	
	j move_character_vertical_third
	
	respond_to_p_third:
		j p_restart
		
	respond_to_a_third:
		li $t0, START_OF_DISPLAY	# Storing the start of the display
		lw $t1, CURRENT_POSITION	# Storing the current position of the character
		sub $t2, $t1, $t0		# Finding the characters relative position to the start
		li $t3, 128			# Store this value here as we will use it later to check if at start
		div $t2, $t3			# Divide current location by 128
		mfhi $t4			# Fetch the remainder
		beqz $t4, move_character_vertical_third # If remainder is 0 only move vertically
		subi $t1, $t1, 4		#else move character one place to the left
		sw $t1, CURRENT_POSITION
		
		jal paint_background		# call the paint background function
	
		jal paint_bottom_line
		jal draw_platforms_third
		jal draw_sun_third
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_21
		
		move_right_21: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_21
		 
		move_left_21:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_21
		draw_21:
		
		jal draw_evil_insect_third
		jal draw_hearts
		jal draw_player	

		
		
		j move_character_vertical_third
		
	respond_to_d_third:
		li $t0, START_OF_DISPLAY	# Storing the start of the display
		lw $t1, CURRENT_POSITION	# Storing the current position of the character
		sub $t2, $t1, $t0		# Finding the characters relative position to the start
		li $t3, 128			# Store this value here as we will use it later to check if at start
		subi $t2, $t2, 116			# To check if character is at right most point
		
		div $t2, $t3			# Divide current location by 128
		mfhi $t4			# Fetch the remainder
		beqz $t4, move_character_vertical_third # If remainder is 0 only move vertically
		addi $t1, $t1, 4		#else move character one place to the left
		sw $t1, CURRENT_POSITION
		
		jal paint_background		# call the paint background function
	
		jal paint_bottom_line
		jal draw_platforms_third
		jal draw_sun_third
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_22
		
		move_right_22: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_22
		 
		move_left_22:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_22
		draw_22:
		
		jal draw_evil_insect_third
		jal draw_hearts
		jal draw_player	 
		
		j move_character_vertical_third
	
			
	
	move_character_vertical_third:
		lw $t1, CURRENT_VERTICAL
		beq $t1, 1, bounce_third
		beq $t1, 0, fall_third
		
	bounce_third: 
		
		lw $t0, CURRENT_POSITION	# to fetch the initial position for the character
		subi $t0, $t0, 128
		sw $t0, CURRENT_POSITION # to update the initial position for the character
		
		jal paint_background		# call the paint background function
		jal paint_bottom_line
		jal draw_platforms_third
		jal draw_sun_third
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_23
		
		move_right_23: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_23
		 
		move_left_23:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_23
		draw_23:
		
		jal draw_evil_insect_third
		jal draw_hearts
		jal draw_player


		lw $t3, JUMP_COUNTER
		addi $t3, $t3, 1 # so that we can increment jump counter
		sw $t3, JUMP_COUNTER
		
		beq $t3, 12, change_to_fall_third
		
		j sleep_third
		
		change_to_fall_third:
			li $t5, 0
			sw $t5, CURRENT_VERTICAL
			sw $t5, JUMP_COUNTER
			j sleep_third
		
	
	fall_third:
		lw $t0, CURRENT_POSITION	# to fetch the initial position for the character
		addi $t0, $t0, 128
		sw $t0, CURRENT_POSITION # to update the initial position for the character	
	
		jal paint_background		# call the paint background function

		jal draw_hearts

		
		
		jal paint_bottom_line
		jal draw_platforms_third
		jal draw_sun_third
		
		lw $t7, SNAKE_COUNTER
		
		beq $t7, 1, move_left_20
		
		move_right_20: 
			addi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			addi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_20
		 
		move_left_20:
			subi $t7, $t7, 1
			sw $t7, SNAKE_COUNTER
			lw $t6, CURRENT_SNAKE
			subi $t6, $t6, 12
			sw $t6, CURRENT_SNAKE
			j draw_20
		draw_20:
		
		jal draw_evil_insect_third
		
		jal draw_player

		lw $t0, CURRENT_POSITION # to update the initial position for the character	
		bge $t0, 268471812, lose_heart
		
		la $a0, ARRAY_OF_PLATFORMS_third
		lw $t0, CURRENT_POSITION
		
		addi $t1, $t0, 512 #bottom of left foot of character
		addi $t2, $t0, 520 #bottom of right foot of character
		
		li $t4, 0 # using t4 as a counter to see when we reach end of array
		li $t5, 120 # end of array point
		
		platform_check_loop_third:
			beq $t4, $t5, sun_check_third
				
			lw $t6, 0($a0)
			beq $t6, $t1, make_bounce_third
			beq $t6, $t2, make_bounce_third
			
			j increment_third
			
			make_bounce_third:
				li $t7, 1
				sw $t7, CURRENT_VERTICAL

			
			increment_third:
				addi $t4, $t4, 1 # increment the counter
			
				addi $a0, $a0, 4 # move to next element in array a
			
			j platform_check_loop_third
			
		sun_check_third:
			la $a0, ARRAY_OF_SUN_third
			lw $t0, CURRENT_POSITION # to update the initial position for the character
			addi $t4, $t0, 8
			addi $t5, $t0, 136
			
			li $t6, 0
			li $t7, 5
			
			sun_check_loop_third:
				beq $t6, $t7, snake_check_third
				lw $t8, 0($a0)
				
				#beq $t8, $t0, win_screen
				beq $t8, $t4, win_screen
				beq $t8, $t5, win_screen
				
				addi $t6, $t6, 1
				addi $a0, $a0, 4
				j sun_check_loop_third
				
		snake_check_third:
			la $a0, ARRAY_OF_SNAKE_third
			lw $t0, CURRENT_POSITION # to update the initial position for the character
			
			addi $t1, $t0, 512 #bottom of left foot of character
			addi $t2, $t0, 520 #bottom of right foot of character
			
			li $t6, 0
			li $t7, 6
		
			snake_check_loop_third:
				beq $t6, $t7, sleep_third
				lw $t8, 0($a0)
				
				#beq $t8, $t0, win_screen
				beq $t8, $t1, lose_heart
				beq $t8, $t2, lose_heart
				
				addi $t6, $t6, 1
				addi $a0, $a0, 4
				j snake_check_loop_third
	sleep_third:
		li $v0, 32
		li $a0, 40 # sleep for 40 miliseconds
		syscall
		j main_loop_third

	
end: 
	li $v0, 10 # Use the system call 10 to terminate the game
	syscall
	 
	

	

draw_player:
	li $t1, YELLOW 			# storing yellow in $t1
	li $t2, RED 			# storing red in $t2
	li $t3, BLACK 			# storing black in $t3
	li $t4, BROWN 			# storing brown in $t4
	lw $t6, CURRENT_POSITION	# to fetch the initial position for the character
	sw $t1, 0($t6)			# drawing the character
	sw $t1, 4($t6)			# drawing the character
	sw $t1, 8($t6)			# drawing the character
	addi $t6, $t6, 128
	sw $t1, 0($t6)			# drawing the character
	sw $t1, 4($t6)			# drawing the character
	sw $t1, 8($t6)			# drawing the character
	addi $t6, $t6, 128
	sw $t4, 0($t6)			# drawing the character
	sw $t2, 4($t6)			# drawing the character
	sw $t4, 8($t6)			# drawing the character
	
	addi $t6, $t6, 128
	sw $t3, 0($t6)			# drawing the character

	sw $t3, 8($t6)			# drawing the character
	
	jr $ra

draw_evil_insect:
	li $t2, RED 			# storing red in $t2
	li $t3, GREEN 			# storing green in $t3
	li $t4, BLACK 			# storing black in $t3
	lw $t0, CURRENT_SNAKE		# setting the starting point for the painting
	la $a0, ARRAY_OF_SNAKE
	
	addi $t1, $t0, 1416		# to get to the 15th row from the top
	addi $t1, $t1, 12		# to move to start of second platform
	
	sw $t2, 0($t1)			# setting the eye of the insect
	sw $t3, 4($t1)			# setting the middle of the eyes of the insect
	sw $t2, 8($t1)			# setting the second eye of the insect	
	sw $t1, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t6, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t1, $t1, 116		# to get to the 16th row from the top
	addi $t1, $t1, 12		# to move to start of second platform
	sw $t3, 0($t1)			# setting the cheek of the insect
	sw $t4, 4($t1)			# setting the nose of the insect
	sw $t3, 8($t1)			# setting the second cheek of the insect
	sw $t1, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	jr $ra

draw_evil_insect_second:
	li $t2, RED 			# storing red in $t2
	li $t3, GREEN 			# storing green in $t3
	li $t4, BLACK 			# storing black in $t3
	lw $t0, CURRENT_SNAKE		# setting the starting point for the painting
	la $a0, ARRAY_OF_SNAKE_second
	
	addi $t1, $t0, 3296		# to get to the 15th row from the top

	
	sw $t2, 0($t1)			# setting the eye of the insect
	sw $t3, 4($t1)			# setting the middle of the eyes of the insect
	sw $t2, 8($t1)			# setting the second eye of the insect	
	sw $t1, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t6, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t1, $t1, 128
	sw $t3, 0($t1)			# setting the cheek of the insect
	sw $t4, 4($t1)			# setting the nose of the insect
	sw $t3, 8($t1)			# setting the second cheek of the insect
	sw $t1, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	jr $ra
	
draw_evil_insect_third:
	li $t2, RED 			# storing red in $t2
	li $t3, GREEN 			# storing green in $t3
	li $t4, BLACK 			# storing black in $t3
	lw $t0, CURRENT_SNAKE	# setting the starting point for the painting
	la $a0, ARRAY_OF_SNAKE_third
	
	addi $t1, $t0, 852		# to get to the 6th row from the top

	
	sw $t2, 0($t1)			# setting the eye of the insect
	sw $t3, 4($t1)			# setting the middle of the eyes of the insect
	sw $t2, 8($t1)			# setting the second eye of the insect	
	sw $t1, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t6, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t1, $t1, 128
	sw $t3, 0($t1)			# setting the cheek of the insect
	sw $t4, 4($t1)			# setting the nose of the insect
	sw $t3, 8($t1)			# setting the second cheek of the insect
	sw $t1, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4
	
	addi $t6, $t1, 4
	sw $t6, 0($a0)
	
	jr $ra
	
	
draw_platforms:
	li $t0, START_OF_DISPLAY	# setting the starting point for the painting
	addi $t1, $t0, 768		# to get to the 7th row from the top
	addi $t1, $t1, 48		# to move first platform a little bit to the right
	addi $t2, $t1, 40		# end of the first platform
	
	la $a0, ARRAY_OF_PLATFORMS	# copy over the start of the array of platforms
	li $t3, BLUE 			# storing blue in $t3

	draw_first_platform:
		beq $t2, $t1, draw_second_platform 	# checking if the end of the first platform has been reached
		sw $t3, 0($t1)				# drawing the first platform
		
		sw $t1, 0($a0)
		addi $a0, $a0, 4			# moving to the next element in the array		
		
		addi $t1, $t1, 4			# moving one pixel to the right

		j draw_first_platform			# loop back
		
	draw_second_platform:
		addi $t1, $t0, 1664		# to get to the 11th row from the top
		addi $t1, $t1, 12		# to move second platform a little bit to the right
		addi $t2, $t1, 40		# end of the second platform
		draw_second_platform_loop:
			beq $t2, $t1, draw_third_platform 	# checking if the end of the second platform has been reached
			sw $t3, 0($t1)				# drawing the second platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
			
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_second_platform_loop		# loop back
			
	draw_third_platform:
		addi $t1, $t0, 2560		# to get to the 19th row from the top
		addi $t1, $t1, 80		# to move third platform a little bit to the right
		addi $t2, $t1, 40		# end of the third platform
		draw_third_platform_loop:
			beq $t2, $t1, draw_fourth_platform 	# checking if the end of the third platform has been reached
			sw $t3, 0($t1)				# drawing the third platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
			
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_third_platform_loop		# loop back
	
	draw_fourth_platform:
		addi $t1, $t0, 3456		# to get to the 27th row from the top
		addi $t1, $t1, 8		# to move first platform a little bit to the right
		addi $t2, $t1, 40		# end of the fourth platform
		draw_fourth_platform_loop:
			beq $t2, $t1, return_to_caller 		# checking if the end of the fourth platform has been reached
			sw $t3, 0($t1)				# drawing the fourth platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
				
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_fourth_platform_loop		# loop back

			
			
			
draw_platforms_second:
	li $t0, START_OF_DISPLAY	# setting the starting point for the painting
	addi $t1, $t0, 1024		# to get to the 8th row from the top
	addi $t1, $t1, 0		# to move first platform a little bit to the right
	addi $t2, $t1, 40		# end of the first platform
	
	la $a0, ARRAY_OF_PLATFORMS_second	# copy over the start of the array of platforms
	li $t3, BLUE 			# storing blue in $t3

	draw_first_platform_second:
		beq $t2, $t1, draw_second_platform_second 	# checking if the end of the first platform has been reached
		sw $t3, 0($t1)				# drawing the first platform
		
		sw $t1, 0($a0)
		addi $a0, $a0, 4			# moving to the next element in the array		
		
		addi $t1, $t1, 4			# moving one pixel to the right

		j draw_first_platform_second			# loop back
		
	draw_second_platform_second:
		addi $t1, $t0, 1664		# to get to the 11th row from the top
		addi $t1, $t1, 32		# to move second platform a little bit to the right
		addi $t2, $t1, 40		# end of the second platform
		draw_second_platform_loop_second:
			beq $t2, $t1, draw_third_platform_second 	# checking if the end of the second platform has been reached
			sw $t3, 0($t1)				# drawing the second platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
			
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_second_platform_loop_second		# loop back
			
	draw_third_platform_second:
		addi $t1, $t0, 2568		# to get to the 19th row from the top
		addi $t1, $t1, 64		# to move third platform a little bit to the right
		addi $t2, $t1, 40		# end of the third platform
		draw_third_platform_loop_second:
			beq $t2, $t1, draw_fourth_platform_second 	# checking if the end of the third platform has been reached
			sw $t3, 0($t1)				# drawing the third platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
			
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_third_platform_loop_second		# loop back
	
	draw_fourth_platform_second:
		addi $t1, $t0, 3456		# to get to the 28th row from the top
		addi $t1, $t1, 88		# to move first platform a little bit to the right
		addi $t2, $t1, 40		# end of the fourth platform
		draw_fourth_platform_loop_second:
			beq $t2, $t1, return_to_caller		# checking if the end of the fourth platform has been reached
			sw $t3, 0($t1)				# drawing the fourth platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
				
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_fourth_platform_loop_second		# loop back


draw_platforms_third:
	li $t0, START_OF_DISPLAY	# setting the starting point for the painting
	addi $t1, $t0, 1024		# to get to the 8th row from the top
	addi $t1, $t1, 76		# to move first platform a little bit to the right
	addi $t2, $t1, 40		# end of the first platform
	
	la $a0, ARRAY_OF_PLATFORMS_third	# copy over the start of the array of platforms
	li $t3, BLUE 			# storing blue in $t3

	draw_first_platform_third:
		beq $t2, $t1, draw_second_platform_third 	# checking if the end of the first platform has been reached
		sw $t3, 0($t1)				# drawing the first platform
		
		sw $t1, 0($a0)
		addi $a0, $a0, 4			# moving to the next element in the array		
		
		addi $t1, $t1, 4			# moving one pixel to the right

		j draw_first_platform_third			# loop back
		
	draw_second_platform_third:
		addi $t1, $t0, 1664		# to get to the 11th row from the top
		addi $t1, $t1, 12		# to move second platform a little bit to the right
		addi $t2, $t1, 40		# end of the second platform
		draw_second_platform_loop_third:
			beq $t2, $t1, draw_third_platform_third 	# checking if the end of the second platform has been reached
			sw $t3, 0($t1)				# drawing the second platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
			
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_second_platform_loop_third		# loop back
			
	draw_third_platform_third:
		addi $t1, $t0, 2560		# to get to the 19th row from the top
		addi $t1, $t1, 76		# to move third platform a little bit to the right
		addi $t2, $t1, 40		# end of the third platform
		draw_third_platform_loop_third:
			beq $t2, $t1, draw_fourth_platform_third 	# checking if the end of the third platform has been reached
			sw $t3, 0($t1)				# drawing the third platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
			
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_third_platform_loop_third		# loop back
	
	draw_fourth_platform_third:
		addi $t1, $t0, 3456		# to get to the 28th row from the top
		addi $t1, $t1, 12		# to move first platform a little bit to the right
		addi $t2, $t1, 40		# end of the fourth platform
		draw_fourth_platform_loop_third:
			beq $t2, $t1, return_to_caller		# checking if the end of the fourth platform has been reached
			sw $t3, 0($t1)				# drawing the fourth platform
			
			sw $t1, 0($a0)
			addi $a0, $a0, 4			# moving to the next element in the array
				
			addi $t1, $t1, 4			# moving one pixel to the right
			j draw_fourth_platform_loop_third		# loop back

		
	
draw_sun:
	li $t0, START_OF_DISPLAY 	# to set the start of the display to t0
	li $t1, ORANGE			# storing orange in $t1
	li $t2, YELLOW			# storing yellow in $t2
	la $a0, ARRAY_OF_SUN
	
	
	addi $t3, $t0, 120		# to get the top of sun pixel
	sw $t1, 0($t3)			# colouring in the top of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t0, 244		# to get the left of sun pixel
	sw $t1, 0($t3)			# colouring in the left of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t3, 4		# moving one pixel to the right
	sw $t2, 0($t3)			# colouring in the center of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t3, 4		# moving one pixel to the right
	sw $t1, 0($t3)			# colouring in the right of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t0, 376		# to get the bottom of sun pixel
	sw $t1, 0($t3)			# colouring in the bottom of the sun
	sw $t3, 0($a0)

	
	jr $ra				# to get back to the calling function
	
draw_sun_second:
	li $t0, START_OF_DISPLAY 	# to set the start of the display to t0
	li $t1, ORANGE			# storing orange in $t1
	li $t2, YELLOW			# storing yellow in $t2
	la $a0, ARRAY_OF_SUN_second
	
	
	addi $t3, $t0, 80		# to get the top of sun pixel
	sw $t1, 0($t3)			# colouring in the top of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t3, 124		# to get the left of sun pixel
	sw $t1, 0($t3)			# colouring in the left of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t3, 4		# moving one pixel to the right
	sw $t2, 0($t3)			# colouring in the center of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t3, 4		# moving one pixel to the right
	sw $t1, 0($t3)			# colouring in the right of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t3, 124		# to get the bottom of sun pixel
	sw $t1, 0($t3)			# colouring in the bottom of the sun
	sw $t3, 0($a0)

	
	jr $ra				# to get back to the calling function
	
draw_sun_third:
	li $t0, START_OF_DISPLAY 	# to set the start of the display to t0
	li $t1, ORANGE			# storing orange in $t1
	li $t2, YELLOW			# storing yellow in $t2
	la $a0, ARRAY_OF_SUN_third
	
	
	addi $t3, $t0, 120		# to get the top of sun pixel
	sw $t1, 0($t3)			# colouring in the top of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t0, 244		# to get the left of sun pixel
	sw $t1, 0($t3)			# colouring in the left of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t3, 4		# moving one pixel to the right
	sw $t2, 0($t3)			# colouring in the center of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t3, 4		# moving one pixel to the right
	sw $t1, 0($t3)			# colouring in the right of the sun
	sw $t3, 0($a0)
	addi $a0, $a0, 4
	
	addi $t3, $t0, 376		# to get the bottom of sun pixel
	sw $t1, 0($t3)			# colouring in the bottom of the sun
	sw $t3, 0($a0)

	
	jr $ra				# to get back to the calling function
	

paint_background:
	li $t0, START_OF_DISPLAY	# setting the starting point for the painting
	li $t1, WHITE			# storing white in $t1
	li $t2, PINK			# storing pink in $t2
	addi $t3, $t0, 4096		# we store this so that we know once we have reached the last pixel in the image
		
	paint_background_loop:	
		beq $t0, $t3, return_to_caller	# if our current pixel has reached the bottom right pixel return
		sw $t1, 0($t0)			# paint the current pixel white
		sw $t2, 4($t0)			# paint the the next pixel pink
		addi $t0, $t0, 8		# make the register t0 hold the value of the pixel two places after the current one as we have already painted the next one
		j paint_background_loop		# loop back
		

	
paint_bottom_line:
	li $t0, START_OF_DISPLAY	# setting the starting point for the painting
	li $t1, RED 			# storing red in $t1
	addi $t0, $t0, 3968  		# reaching the last line in the screen
	addi $t3, $t0, 128		# we store this so that we know once we have reached the last pixel in the image
	
	paint_bottom_line_loop: 
		beq $t0, $t3, return_to_caller	# if our current pixel has reached the bottom right pixel return
		sw $t1, 0($t0)			# paint the current pixel red
		addi $t0, $t0, 4 		# storing the next pixel in $t0
		j paint_bottom_line_loop	# loop back
		
win_screen: 
	li $t0, START_OF_DISPLAY	# setting the starting point for the painting
	li $t1, GREEN			# storing white in $t1
	addi $t3, $t0, 4096		# we store this so that we know once we have reached the last pixel in the image
		
	win_screen_loop:	
		beq $t0, $t3, write_text_two	# if our current pixel has reached the bottom right pixel return
		sw $t1, 0($t0)			# paint the current pixel white
		addi $t0, $t0, 4		# make the register t0 hold the value of the pixel two places after the current one as we have already painted the next one
		j win_screen_loop		# loop back
		
	write_text_two:
		li $t0, START_OF_DISPLAY	# setting the starting point for the text
		li $t1, WHITE
		
		addi $t0, $t0, 1308
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, 8($t0)
		
		sw $t1, 16($t0)
		sw $t1, 20($t0)
		sw $t1, 24($t0)
		
		sw $t1, 32($t0)
		sw $t1, 48($t0)
		
		sw $t1, 56($t0)
		sw $t1, 60($t0)
		sw $t1, 64($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 16($t0)
		sw $t1, 24($t0)
		sw $t1, 32($t0)
		sw $t1, 36($t0)
		sw $t1, 44($t0)
		sw $t1, 48($t0)
		sw $t1, 56($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 8($t0)
		sw $t1, 16($t0)
		sw $t1, 20($t0)
		sw $t1, 24($t0)
		sw $t1, 32($t0)
		sw $t1, 40($t0)
		sw $t1, 48($t0)
		sw $t1, 56($t0)
		sw $t1, 60($t0)
		sw $t1, 64($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 8($t0)
		sw $t1, 16($t0)
		sw $t1, 24($t0)
		sw $t1, 32($t0)
		sw $t1, 48($t0)
		sw $t1, 56($t0)

		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, 8($t0)
		
		sw $t1, 16($t0)

		sw $t1, 24($t0)
		
		sw $t1, 32($t0)
		sw $t1, 48($t0)
		
		sw $t1, 56($t0)
		sw $t1, 60($t0)
		sw $t1, 64($t0)
		
		addi $t0, $t0, 256
		sw $t1, 0($t0)
		sw $t1, 16($t0)
		
		sw $t1, 24($t0)
		sw $t1, 28($t0)
		sw $t1, 32($t0)
		
		sw $t1, 40($t0)
		sw $t1, 52($t0)
		sw $t1, 60($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 16($t0)
		
		sw $t1, 24($t0)

		sw $t1, 32($t0)
		
		sw $t1, 40($t0)
		sw $t1, 44($t0)
		sw $t1, 52($t0)
		sw $t1, 60($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 8($t0)
		sw $t1, 16($t0)
		
		sw $t1, 24($t0)

		sw $t1, 32($t0)
		
		sw $t1, 40($t0)
		sw $t1, 48($t0)
		sw $t1, 52($t0)
		
		
		addi $t0, $t0, 128
		sw $t1, 4($t0)
		sw $t1, 12($t0)
		
		sw $t1, 24($t0)
		sw $t1, 28($t0)
		sw $t1, 32($t0)
		
		sw $t1, 40($t0)
		sw $t1, 52($t0)
		sw $t1, 60($t0)
		
		
	done_second:
		li $v0, 10 # Use the system call 10 to terminate the game
		syscall 
		
draw_hearts:
	li $t0, START_OF_DISPLAY
	lw $t1, HEARTS
	li $t2, RED
	
	beq $t1, 0, restart
	
	sw $t2, 4($t0)
	sw $t2, 12($t0)
	addi $t0, $t0, 128
	sw $t2, 0($t0)
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	addi $t0, $t0, 128
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	addi $t0, $t0, 128
	sw $t2, 8($t0)
	
	beq $t1, 1, here
	li $t0, START_OF_DISPLAY
	addi $t0, $t0, 24
	
	sw $t2, 4($t0)
	sw $t2, 12($t0)
	addi $t0, $t0, 128
	sw $t2, 0($t0)
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	addi $t0, $t0, 128
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	addi $t0, $t0, 128
	sw $t2, 8($t0)
	
	beq $t1, 2, here
	
	li $t0, START_OF_DISPLAY
	addi $t0, $t0, 48
	
	sw $t2, 4($t0)
	sw $t2, 12($t0)
	addi $t0, $t0, 128
	sw $t2, 0($t0)
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	addi $t0, $t0, 128
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	addi $t0, $t0, 128
	sw $t2, 8($t0)
	
	here:
	jr $ra
	
lose_heart:
	lw $t1, HEARTS
	subi $t1, $t1, 1
	sw $t1, HEARTS
	
	li $t0, START_OF_DISPLAY
	sw $t0, CURRENT_POSITION
	
	li $t0, 0
	sw $t0, CURRENT_VERTICAL
	
	li $t0, 0
	sw $t0, JUMP_COUNTER
	j initial
	
	

restart:
	li $t0, START_OF_DISPLAY	# setting the starting point for the painting
	li $t1, BLACK			# storing white in $t1
	addi $t3, $t0, 4096		# we store this so that we know once we have reached the last pixel in the image
		
	restart_loop:	
		beq $t0, $t3, write_text	# if our current pixel has reached the bottom right pixel return
		sw $t1, 0($t0)			# paint the current pixel white
		addi $t0, $t0, 4		# make the register t0 hold the value of the pixel two places after the current one as we have already painted the next one
		j restart_loop		# loop back
		
	write_text:
		li $t0, START_OF_DISPLAY	# setting the starting point for the text
		li $t1, WHITE
		
		addi $t0, $t0, 1308
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, 8($t0)
		
		sw $t1, 16($t0)
		sw $t1, 20($t0)
		sw $t1, 24($t0)
		
		sw $t1, 32($t0)
		sw $t1, 48($t0)
		
		sw $t1, 56($t0)
		sw $t1, 60($t0)
		sw $t1, 64($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 16($t0)
		sw $t1, 24($t0)
		sw $t1, 32($t0)
		sw $t1, 36($t0)
		sw $t1, 44($t0)
		sw $t1, 48($t0)
		sw $t1, 56($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 8($t0)
		sw $t1, 16($t0)
		sw $t1, 20($t0)
		sw $t1, 24($t0)
		sw $t1, 32($t0)
		sw $t1, 40($t0)
		sw $t1, 48($t0)
		sw $t1, 56($t0)
		sw $t1, 60($t0)
		sw $t1, 64($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 8($t0)
		sw $t1, 16($t0)
		sw $t1, 24($t0)
		sw $t1, 32($t0)
		sw $t1, 48($t0)
		sw $t1, 56($t0)
		
		addi $t0, $t0, 128
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, 8($t0)
		
		sw $t1, 16($t0)

		sw $t1, 24($t0)
		
		sw $t1, 32($t0)
		sw $t1, 48($t0)
		
		sw $t1, 56($t0)
		sw $t1, 60($t0)
		sw $t1, 64($t0)
		
		addi $t0, $t0, 256 #first row of over
		
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, 8($t0)
		
		sw $t1, 16($t0)
		sw $t1, 24($t0)
		
		sw $t1, 32($t0)
		sw $t1, 36($t0)
		sw $t1, 40($t0)
		
		sw $t1, 48($t0)
		sw $t1, 52($t0)
		sw $t1, 56($t0)
		
		
		addi $t0, $t0, 128 #second row of over
		
		sw $t1, 0($t0)
		sw $t1, 8($t0)
		
		sw $t1, 16($t0)
		sw $t1, 24($t0)
		
		sw $t1, 32($t0)
		
		sw $t1, 48($t0)
		sw $t1, 56($t0)
		
		addi $t0, $t0, 128 #third row of over
		sw $t1, 0($t0)

		sw $t1, 8($t0)
		
		sw $t1, 16($t0)

		sw $t1, 24($t0)
		
		sw $t1, 32($t0)
		sw $t1, 36($t0)
		sw $t1, 40($t0)
		
		sw $t1, 48($t0)
		sw $t1, 52($t0)
		sw $t1, 56($t0)
		
		addi $t0, $t0, 128 #fourth  row of over
		
		sw $t1, 0($t0)
		sw $t1, 8($t0)
		
		sw $t1, 16($t0)
		sw $t1, 24($t0)
		
		sw $t1, 32($t0)
		
		sw $t1, 48($t0)
		sw $t1, 52($t0)
		
		addi $t0, $t0, 128
		
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, 8($t0)
		
		sw $t1, 20($t0)	
				
		sw $t1, 32($t0)
		sw $t1, 36($t0)
		sw $t1, 40($t0)
		
		sw $t1, 48($t0)
		sw $t1, 56($t0)
		
		
	done_first:
		li $v0, 10 # Use the system call 10 to terminate the game
		syscall 
		
p_restart:
	li $t0, START_OF_DISPLAY
	sw $t0, CURRENT_POSITION
	
	li $t0, 1
	sw $t0, CURRENT_VERTICAL
	
	li $t0, 0
	sw $t0, JUMP_COUNTER
	j initial

		

	
return_to_caller:
	jr $ra
	
