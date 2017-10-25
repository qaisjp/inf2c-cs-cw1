#=========================================================================
# convert_pig_latin.s
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
            #--------------------------------------------------------------
            # Constant strings for output messages (or other things)
            #--------------------------------------------------------------
outputmsg:     .asciiz "\noutput:\n"
newline:       .asciiz "\n"
nullchar:      .ascii "\0"
vowels:        .asciiz "aeiouAEIOU"
inputmsg:      .asciiz "Enter input: "

            #--------------------------------------------------------------
            # Global variables in memory
            #--------------------------------------------------------------

            # // Maximum characters in an input sentence excluding terminating null character
            # #define MAX_SENTENCE_LENGTH 1000
MAX_SENTENCE_LENGTH: .word 1000                
            #
            # // Maximum characters in a word excluding terminating null character
            # #define MAX_WORD_LENGTH 50
MAX_WORD_LENGTH:     .word 50
            #
            # // Global variables
            # // +1 to store terminating null character
            #
            # char input_sentence[MAX_SENTENCE_LENGTH+1];
input_sentence:      .space 1001
            #
            # char word[(3*MAX_WORD_LENGTH)+1];
word:                .space 154
            #
            # char output_sentence[(MAX_SENTENCE_LENGTH*3) + 1];
output_sentence:     .space 3001
            #

#==================================================================
# TEXT SEGMENT
#==================================================================
.text

        #------------------------------------------------------------------
        # read_input function (copied from find_word.s)
        #------------------------------------------------------------------

                               # void read_input(const char* inp)
                               # out in $a0
read_input:
                               # {
                               #
        move $t1, $a0          #      auto $t1 = inp
                               #
        li $v0, 4              #      print_string("\nEnter input: ");
        la $a0, inputmsg
        syscall                #
                               #      // size is stored in $t2
                               #      int size = MAX_SENTENCE_LENGTH
        lw $t2, MAX_SENTENCE_LENGTH
        addi $t2, $t2, 1       #      size += 1;
                               #
        li $v0, 8              #      read_string(
        la $a0, ($t1)          #          inp,
        la $a1, ($t2)          #          size
        syscall                #      );
        
        jr $ra                 #      return
                               # }

        #------------------------------------------------------------------
        # output function (copied from find_word.s)
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
        # note 'a' = 97        #
        # note 'z' = 122       #
        sge $t0, $a0, 97       #     $t0 = ch >= 'a';
        sle $t1, $a0, 122      #     $t1 = ch <= 'z';
        and $t2, $t0, $t1      #     $t2 = $t0 && $t1;
                               #
        # note 'a' = 65        #
        # note 'z' = 90        #
        sge $t0, $a0, 65       #     $t0 = ch >= 'A';
        sle $t1, $a0, 90       #     $t1 = ch <= 'Z';
        and $t0, $t0, $t1      #     $t0 = $t0 && $t1;
                               #
        or $v0, $t2, $t0       #     $v0 = $t0 || $t2;
                               #
        jr $ra                 #     return $v0;
                               # }
                               
        #------------------------------------------------------------------
        # is_upper_char
        #------------------------------------------------------------------

                               # int is_upper_char(char ch)
                               # ch in $a0
is_upper_char:
                               # {
        sge $t0, $a0, 65       #     $t0 = $a0 >= 'A';
        sle $t1, $a0, 90       #     $t1 = ch <= 'Z';
        and $v0, $t0, $t1      #     $v0 = $t0 && $t1;
                               #
        jr $ra                 #     return $v0;
                               # }

        #------------------------------------------------------------------
        # is_vowel, returns true only if an input char is a vowel
        #------------------------------------------------------------------

                               # int is_vowel(char ch)
                               # ch in $a0
is_vowel:
                               # {
        la $t0, vowels         #     char* vowels = "aeiouAEIOU";
        li $t1, 0              #     int i = 10;
        li $v0, 1              #     $v0 = true; // assume true;
        
is_vowel_while:                #     while (i < 10) {
        bge $t1, 10, is_vowel_endwhile
                               #
                               
                               
        addi $t1, $t1, 1       #         i += 1;
                               #     }
is_vowel_endwhile:
        li $v0, 0              #     $v0 = false;
        jr $ra                 #     return $v0;
                               # }

        #------------------------------------------------------------------
        # piglatinify function
        #------------------------------------------------------------------
                               # int piglatinify(char* word, int length)
                               # word in $a0, length in $a1
piglatinify:
                               # {
        # HACK: This is abuse. Move $ra into $fp.
        move $fp, $ra
        
        # Store our args into s0 and s1
        move $s0, $a0          #     $s0 = word
        move $s1, $a1          #     $s1 = length
                               #
        # firstCapped          #
        lb $a0, ($s0)          #     $v0 = is_upper_char(word[0]
        jal is_upper_char      #     );
        move $s2, $v0          #     int firstCapped = $v0;
        
        # lastCapped           #
        add $t0, $s0, $s1      #     word_address = word + length
        subi $t0, $t0, 1       #     word_address -= 1
        lb $t0, ($t0)          #     $t0 = *word_address
        move $a0, $t0          #     $v0 = is_upper_char(word[length-1]
        jal is_upper_char      #     );
        move $s3, $v0          #     int lastCapped = $v0;
        
        # word_index and vowel_index
        li $s4, 0              #     int word_index = 0;
        li $s5, -1             #     int vowel_index = -1;
        
        # // If the first character is capped, but last not, make first character lowercase before moving it around
        not $t0, $s3           #     $t0 = !lastCapped;
        and $t0, $t0, $s2      #     $t0 = !lastCapped && firstCapped;
        beqz $t0, piglatin_skiptolower_first # if (firstCapped && !lastCapped) {
        lb $t0, 0($s0)         #         $t0 = word[0]; // firstChar
        addi $t0, $t0, 32      #         $t0 += 32; // lowercase the firstChar
        sb $t0, 0($s0)         #         word[0] = word[0] + 32;
                               #
piglatin_skiptolower_first:    #     }
                               #
                               #
piglatin_findvowel_while:      #     while (vowel_index < length) {
        # // First find the vowel index (or end of word)
        bge $s5, $s1, piglatin_findvowel_endwhile
                               #
        # increment vowel_index#
        addi $s5, $s5, 1       #         vowel_index += 1;
        
        # break loop if is vowel
        add $t0, $s0, $s5      #         word_address = word + vowel_index
        lb $t0, ($t0)          #         $t0 = *word_address
        move $a0, $t0          #         $a0 = $t0; // = word[vowel_index]);
        jal is_vowel           #         $v0 = is_vowel(word[vowel_index]);
        beq $v0, 1, piglatin_findvowel_endwhile # if is_vowel(word[vowel_index]) break
        
        j piglatin_findvowel_while
piglatin_findvowel_endwhile:



        # // If the first character was capped, but last not, make sure the first character is uppercase
        not $t0, $s3           #     $t0 = !lastCapped;
        and $t0, $t0, $s2      #     $t0 = !lastCapped && firstCapped;
        beqz $t0, piglatin_skiptolower_last # if (firstCapped && !lastCapped) {
                               #      
        lb $t0, 0($s0)         #         $t0 = word[0]; // firstChar
        subi $t0, $t0, 32      #         $t0 += 32; // upper the firstChar
        sb $t0, 0($s0)         #         word[0] = word[0] - 32;        
piglatin_skiptolower_last:     #     }
                               #
        add $t0, $s0, $s1     #     address = word + length;
        sb $zero, ($t0)        #     *address = '\0'; // word[length] = '\0'
        
        # (UN)HACK: This is abuse. Move the return address in $fp back into $ra.
        move $ra, $fp
        
        # Make sure we set the return value to our accumulated length
        move $v0, $a1          #     $v0 = length;
        
        jr $ra                 #     return $v0;
                               # }

        #------------------------------------------------------------------
        # process_input function
        #------------------------------------------------------------------
                               # void process_input(char* inp, char* out)
                               # inp = $a0
                               # out = $a1
process_input:
        addi $sp, $sp, -12
        sw $ra 0($sp)           # offset 0 is $ra
        sw $a0 4($sp)          # offset 4 is $a0
        sw $a1 8($sp)          # offset 8 is $a1
        
                               # {
        li $s0, -1             #     int inp_index = -1; // regular iterator through the input, $s0
        lb, $s1, nullchar      #     char cur_char = '\0'; // curr char, $s1
        li $s2, 0              #     int out_index = 0; // $s2 current index for the ouptut
        li $s3, -1             #     int wordStart = -1; // $s3 the index in the input corresponding to the beginning fo the word
        li $s4, 0              #     int cur_char_valid = false; // $s4
                               #
        # While an end of sentence character has not been encountered
process_loop_do:               #     do {
                               #
        addi $s0, $s0, 1       #         inp_index += 1;

        lw $t0, 4($sp)        #         address = stack[1]; // stack[1] = inp;
        add $t0, $t0, $s0      #         address += inp_index;
        lb $s1, ($t0)          #         cur_char = *address;

        move $a0, $s1          #         $v0 = is_valid_char(cur_char
        jal is_valid_character #         );
        move $s4, $v0          #         cur_char_valid = $v0

        # // (wordStart < 0) means we aren't logging a word
        # // So if the current character is a valid word character
        # // mark the current index as the beginning of a word
        slt $t0, $s3, $0       #         $t0 = wordStart < 0
        and $t0, $t0, $s4      #         $t0 = (wordStart < 0) && cur_char_valid
        beqz $t0, process_beginword_not# if (wordStart < 0 && cur_char_valid) {

        move $s3, $s0          #             wordStart = inp_index;
                               #         }
process_beginword_not: # We jump here if we shouldn't start marking a word


        lw $t0, 4($sp)        #         address = stack[1]; // stack[1] = inp;
        add $t0, $t0, $s0      #         address += inp_index;
        addi $t0, $t0, 1       #         address += 1;
        lb $a0, ($t0)          #         next_char = *address; // in $a0

        jal is_valid_character #         $v0 = is_valid_character(next_char);
        seq $t0, $s1, '-'      #         $t0 = (cur_char == ''); // is_hyphen(curr_char) inlined
        and $t0, $t0, $v0      #         $t0 = $t0 && $v0 = is_hyphen(cur_char) && is_valid_character(next_char);
        
        bnez $t0, process_endif_badchar# if (is_hyphen(cur_char) && is_valid_char(inp[inp_index+1])) {
                               #             // jump over this entire if branch.
                               #         } else {
                               #
        sge $t0, $s3, 0        #             $t0 = wordStart >= 0;
        not $t1, $s4           #             $t1 = !cur_char_valid;
        and $t0, $t0, $t1      #             $t0 = (wordStart >= 0) && !cur_char_valid;
        bne $t0, 1, process_endif_badchar #  if ((wordStart >= 0) && !cur_char_valid) {
        
process_if_badchar: # // We land here if we are on a word (wordStart >= 0) and if we encounter a bad character (!cur_char_valid)
        
        # // Now we need to start building the word array with our found word
        li $t0, 0              #                 int length = 0; // in $t0
process_word_while:
        bge $s3, $s0, process_word_endwhile #    while (wordStart < inp_index) {
        
        lw $t1, 4($sp)         #                     inp_address = stack[1]; // stack[1] = inp
        add $t1, $t1, $s3      #                     inp_address += wordStart;
        lb $t1, ($t1)          #                     $t1 = *inp_address // $t1 = inp[wordStart]
                               #
        la $t2, word           #                     word_address = word
        add $t2, $t2, $t0      #                     word_address += length;
        sb $t1, ($t2)          #                     *word_address = $t1; // word[length] = inp[wordStart];
                               #
        addi $s3, $s3, 1       #                     wordStart += 1;
        addi $t0, $t0, 1       #                     length += 1;
                               #
        j process_word_while   #                 }
process_word_endwhile:         #
                               #
        # // Trail the word with a null char for safety. Length of the string does not change.
        la $t2, word           #                 word_address = word
        add $t2, $t2, $t0      #                 word_address += length;
        sb $zero, ($t2)        #                 *word_address = 0; // word[length] = '\0';
        
        # Push all our stored variables onto the stack
        addi $sp, $sp, -20
        sw $s0, 0($sp)
        sw $s1, 4($sp)
        sw $s2, 8($sp)
        sw $s3, 12($sp)
        sw $s4, 16($sp)
        
        # // Do something to the word
        la $a0, word           #                 $v0 = piglatinify(word,
        move $a1, $t0          #                     length
        jal piglatinify        #                 );
        move $t0, $v0          #                 length = newLength = $v0
        
        # Pop all our stored variables off the stack
        lw $s4, 16($sp)
        lw $s3, 12($sp)
        lw $s2, 8($sp)
        lw $s1, 4($sp)
        lw $s0, 0($sp)
        addi $sp, $sp, 20
        
        # // We need to append `word` to `out`.
        # // Reuse wordStart to refer to the progress through `word` so far.
        li $s3, 0              #                 wordStart = 0;
process_appendword_while:
        bge $s3, $t0, process_appendword_endwhile # while (wordStart < newLength)
                               #                 {
                               #
        # // Add the character to the output
        la $t1, word           #                     word_address = word
        add $t1, $t1, $s3      #                     word_address += wordStart;
        lb $t1, ($t1)          #                     $t1 = *word_address // $t1 = word[wordStart]
                               #
        lw $t2, 8($sp)        #                      out_address = stack[2] // stack[2] = out
        add $t2, $t2, $s2      #                     out_address += out_index;
        sb $t1, ($t2)          #                     *out_address = $t1; // out[out_index] = word[wordStart];
        
        # // Increment the progress through `word`, and index of `out`.
        addi $s2, $s2, 1       #                     out_index += 1;
        addi $s3, $s3, 1       #                     wordStart += 1;
        
        j process_appendword_while #             }
process_appendword_endwhile:   #
        
        li $s3, -1             #                 wordStart = -1;
                               #             }
                               #         }
process_endif_badchar:         #         // Mark end of badchar stream

process_if_printbadchar: bgez $s3, process_endif_printbadchar # // skip over if wordStart >= 0
                               #         if (wordStart < 0) {
        lw $t0, 8($sp)        #             out_addr = stack[2]; // stack[2] = out;
        add $t0, $t0, $s2      #             out_addr += out_index
                               #
        sb $s1, ($t0)          #             *out_addr = cur_char // out[out_index] = cur_char;
        addi $s2, $s2, 1       #             out_index += 1;
                               #
                               #         }
process_endif_printbadchar:    #
                               #         // Now we're at the end of the do loop
process_loop_thinkwhile:       #
        # Code to jump back to the beginning of this loop
        lb $t0, nullchar       #         // load nullchar
        lb $t1, newline        #         // load newline
        sne $t0, $s1, $t0      #         // $t0 = curr_char != '\0';
        sne $t1, $s1, $t1      #         // $t1 = curr_char != '\n';
        and $t0, $t0, $t1      #         // $t0 = (curr_char != '\0') && (curr_char != '\n');
        bnez $t0, process_loop_do #      while ((cur_char != '\n') && (cur_char != '\0'))
        
process_loop_enddo:
        # Done with the while loop? Revive return address from the stack, and jump back.
        lw $ra, 0($sp)         #     // Correct $ra is offset 0.
        addi $sp, $sp, 12      #     // Pop our things from the stack.
        jr $ra

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
                               #     $v0 = read_input(
        la $a0, input_sentence #         input_sentence,
        jal read_input         #     );
                               #
        li $v0, 4              #     print_string(
        la $a0, outputmsg      #         "\noutput:\n"
        syscall                #     );
                               #
        la $t0, output_sentence #     // $a0 = input_sentence;
        sb $zero, ($t0)        #     output_sentence[0] = '\0'
                               #
                               #     $v0 = process_input(
        la $a0, input_sentence #         input_sentence,
        la $a1, output_sentence#         output_sentence
        jal process_input      #     );
                               #
        la $a0, output_sentence#     $a0 = output_sentence;
        jal output             #     output(output_sentence);                                
                               
        li   $v0, 10           #     return 0;
        syscall                # }

        #----------------------------------------------------------------
        # END OF CODE
        #----------------------------------------------------------------
