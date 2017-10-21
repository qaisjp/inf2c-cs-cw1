#=========================================================================
# find_word.s
#=========================================================================
# 
# Inf2C Computer Systems
#
# Qais Patankar - s1620208
#
# The comment structure for Data Segment / Text Segment and other functions have been
# borrowed from hex.s given in this coursework.
        
        #==================================================================
        # DATA SEGMENT
        #==================================================================
        .data
        #------------------------------------------------------------------
        # Constant strings for output messages
        #------------------------------------------------------------------

read_input_prompt: .asciiz  "\nEnter input: "
outputmsg:         .asciiz  "\noutput:\n"
newline:           .asciiz  "\n"
blyet:             .asciiz  "======================================================================="
                    # Use .ascii because we don't want an extra null character.
nullchar:          .ascii   "\0" # Alternatively we could just do .asciiz ""

        # I am not using false/true defines because 0/1 is easy enough.
        # Also, that's a compile-time macro in C, not the storage of 0/1 in memory
        
        #------------------------------------------------------------------
        # Global variables in memory
        #------------------------------------------------------------------
        
        # // Maximum characters in an input sentence excluding terminating null character
        # #define MAX_SENTENCE_LENGTH 1000
MAX_SENTENCE_LENGTH: .word 1000                
        #
        # // Maximum characters in a word excluding terminating null character
        # #define MAX_WORD_LENGTH 50
MAX_WORD_LENGTH: .word 50
	#
        # // Global variables
        # // +1 to store terminating null character
        #
        # char input_sentence[MAX_SENTENCE_LENGTH+1];
input_sentence: .space 1001
	#
	# char word[MAX_WORD_LENGTH+1];
word:           .space 51
	#
	#
        #==================================================================
        # TEXT SEGMENT  
        #==================================================================
        .text

        #------------------------------------------------------------------
        # read_input function
        #------------------------------------------------------------------

                               # void read_input(const char* inp)
                               # out in $a0
read_input:
                               # {
                               #
        move $t1, $a0          #      auto $t1 = inp
                               #
	li $v0, 4              #      print_string("\nEnter input: ");
	la $a0, read_input_prompt
	syscall                #
                               #      // size is stored in $t2
                               #      int size = MAX_SENTENCE_LENGTH
	lw $t2, MAX_SENTENCE_LENGTH
	addi $t2, $t2, 1       #      size += 1;
                               #
	li $v0, 8              #      read_string(
	la $a0, ($t1)            #          inp,
	la $a1, ($t2)            #          size
	syscall                #      );
	
	jr $ra                 #      return
	                       # }

        #------------------------------------------------------------------
        # output function
        #------------------------------------------------------------------

                               # void output(const char* out)
                               # out in $a0
output:
                               # {
	li $v0, 4              #      print_string(
	#move $a0, $a0         #           out       // instruction commented because pointless
	syscall                #      );
                               #
	li $v0, 4              #      print_string(
	la $a0, newline        #          "\n"
	syscall                #      );
	                       #
	jr $ra                 #      return
	                       # }

        #------------------------------------------------------------------
        # is_valid_character function
        #------------------------------------------------------------------
        # Make sure a given character is an alphabetic character (upper or lower).
	# It checks: (ch >= 'a') && (ch <= 'z') && (ch >= 'A') && (ch <= 'Z')
	# It would be easier to just use 4 register, or even do some maths
	# but we need ot keep to the structure of the C code. Yay.
	#
	# returns true if an input character is a valid word character
	# returns false if an input character is any punctuation mark (including hyphen)

                               # int is_valid_character(char ch)
                               # ch in $a0
is_valid_character:
                               # {
                               #            $t0          $t1
                               #    if ( ch >= 'a' && ch <= 'z' )
	# note 'a' = 97	       #
	# note 'z' = 122       #
	sge $t0, $a0, 97       #      // $t0 = ch >= 'a'
	sle $t1, $a0, 122      #      // $t1 = ch <= 'z'
	and $v0, $t0, $t1      #      // $v0 = $t0 && $t1
			       #      // so if $v0 is true, return true (return $v0)
	beq $v0, 1, return_valid_character
	                       #
                               #      // it's false, so continue to the next case...
	                       #
	                       #
	                       #                  $t0           $t1
			       #    } else if ( ch >= 'A' && ch <= 'Z' ) {
	# note 'a' = 65	       #
	# note 'z' = 90        #
	sge $t0, $a0, 65       #      // $t0 = ch >= 'A'
	sle $t1, $a0, 90       #      // $t1 = ch <= 'Z'
	and $v0, $t0, $t1      #      // $v0 = $t0 && $t1
			       #      // so if $v0 is true, return true (return $v0)
	beq $v0, 1, return_valid_character
	                       #
	                       #      // it's false, so continue to the next case...
	                       #
	                       #    } else {
	                       #
	                       #    // return false     
	li $v0, 0 	       #    $v0 = 0   // (false)
	j return_valid_character
                               #    the jump is actually unnecessary, but it'll be useful in case
                               #    we make some changes later on
                               #
return_valid_character:        #
        jr $ra                 #     // return $v0
                               # }



        #------------------------------------------------------------------
        # is_hyphen function
        #------------------------------------------------------------------
        # hyphen character '-' is ascii code 45

                               # int is_hyphen(char ch)
                               # ch in $a0
is_hyphen:
                               # {
	seq $v0, $a0, 45       #     $v0 = (ch == 45)
	jr $ra                 #     return $v0
	                       # }
	                       
        #------------------------------------------------------------------
        # process_input function
        #------------------------------------------------------------------
        # // This function processes character array pointed to by "inp".
        # // It keeps processing "inp" till 
        # //   either it finds a valid word OR
        # //   it finds an end of a sentence
        # //
        # // If a valid word is found, it is stored at "w" and the function returns true.
        # // If no word is found and the end of sentence is encountered, it returns false.
        
                               # int process_input(char* inp, char* w)
                               # inp in $a0 ( to be $s3 )
                               # w in $a1 ( to be $s4 )
process_input:
                               # {
                               #     // NOTE: $s0, $s1, and $s2 are reserved!
        # store $a0 in $s3, and $a0 in $s4
        move $s3, $a0
        move $s4, $a1
        
	# char cur_char = $s5
	lb $s5, nullchar       #     char cur_char = '\0'; // $s5
	
	# bool is_valid_ch = $s6
	move $s6, $0           #     int is_valid_ch = false; // $s6
	                       #
	# Indicates how many elements in "w" contains valid word characters
	# int char_index = $s7
	li $s7, -1             #     int char_index = -1; // $s7
	                       #
	                       #
        # This loop runs until end of an input sentence is encountered or a valid word is extracted
process_while:                 #     while ( end_of_sentence == false ) {
                               #         // This means we continue if:
                               #         // - end_of_sentence == false == 0
                               #         // - continue if `eqz`
                               #         // - KILL WHILE LOOP if `neqz`
	bnez $s1, process_end  #
                               #
                               #         cur_char = inp[input_index];
        # first get the offset, this is the memory address
        add $t0, $s3, $s0      #         // address = inp + input_index;
        # then get the character at the address
        la $s5, ($t0)          #         // cur_char = *address;
	                       #
	addi $s0, $s0, 1       #         input_index++;
	                       #
        # OUR SHIT NOW
            # print character
            li $v0, 11
            lb $a0, ($s5)
            syscall
            
        # END OF OUR SHIT
	
	# jump back to the beginning of the while loop
	j process_while
                               
            
process_end:
	li $v0, 0              #     $v0 = false;
	jr $ra                 #     return $v0
	                       # }

        #------------------------------------------------------------------
        # MAIN code block
        #------------------------------------------------------------------

        .globl main           # Declare main label to be globally visible.
                              # Needed for correct operation with MARS
                 
main:             
        #------------------------------------------------------------------
        # Registers allocated for global variables
        #------------------------------------------------------------------
        #
        # // $s0 - current character
        # int input_index = 0;
        li $s0, 0
        #
        # // $s1 - marks if the sentence is processed
        # int end_of_sentence = false;
        li $s1, 0
        
        
        #------------------------------------------------------------------
        # main function
        #------------------------------------------------------------------

                               # int is_main() {
                               #
	li $s2, 0              #     int word_found = false; // $s2
                               #
                               #     $v0 = read_input(
	la $a0, input_sentence #         input_sentence,
	jal read_input         #     );
	                       #
	li $v0, 4              #     print_string(
	la $a0, outputmsg      #         "\noutput:\n"
	syscall                #     );
	                       #
main_loop:                     #     do {
                               #         $v0 = process_input(
        la $a0, input_sentence #             input_sentence,
        la $a1, word           #             word
        jal process_input      #         );
                               #
        move $s2, $v0          #         word_found = $v0
                               #
        bne $s2, 1, main_wordnotfound #  if ( word_found == true ) {
                               #
                               #             output(
        la $a0, word           #                 word
        jal output             #             );
                               #
main_wordnotfound:             #         }
                               #
	                       #     } while ( word_found == true );
	bnez $s2, main_loop    #     //
	                       #     // We want to jump to the
	                       #     // beginning of the loop only when:
	                       #     // word_found == true     i.e when:
	                       #     // word_found == 1        i.e when:
	                       #     // word_found != 0
main_end:                      #
        li   $v0, 10           #     return 0;
        syscall                # }

        #----------------------------------------------------------------
        # END OF CODE
        #----------------------------------------------------------------
