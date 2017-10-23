// ==========================================================================
// PigLatin Converter
// ==========================================================================
// Convert all words in a sentence using PigLatin rules 

// Inf2C-CS Coursework 1. Task B 
// PROVIDED file, to be used to complete the task in C and as a model for writing MIPS code.

// Instructor: Boris Grot
// TA: Priyank Faldu
// 10 Oct 2017

//---------------------------------------------------------------------------
// C definitions for SPIM system calls
//---------------------------------------------------------------------------
#include <stdio.h>

void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(char c)    { printf("%c", c); }   
void print_int(int num)    { printf("%d", num); }
void print_string(const char* s) { printf("%s", s); }

#define false 0
#define true 1

// Maximum characters in an input sentence excluding terminating null character
#define MAX_SENTENCE_LENGTH 1000

// Maximum characters in a word excluding terminating null character
#define MAX_WORD_LENGTH 50

// Global variables
// +1 to store terminating null character
char input_sentence[MAX_SENTENCE_LENGTH+1];
char output_sentence[(MAX_SENTENCE_LENGTH*3)+1];

void read_input(const char* inp) {
    print_string("Enter input: ");
    read_string(input_sentence, MAX_SENTENCE_LENGTH+1);
}

void output(const char* out) {
    print_string(out);
    print_string("\n");
}

// Do not modify anything above
//
//
// Define your global variables here
//
//
// Write your own functions here
//
//


// taken from find_word.c
// returns true if an input character is a valid word character
// returns false if an input character is any punctuation mark (including hyphen)
int is_valid_char(char ch) {
    if ( ch >= 'a' && ch <= 'z' ) {
        return true;
    } else if ( ch >= 'A' && ch <= 'Z' ) {
        return true;
    }

    return false;
}

// take from find_word.c
// returns true only if an input character is hyphen
int is_hyphen(char ch) {
    return ch == '-';
}


void process_input(char* inp, char* out) {
    int inp_index = 0;
    char cur_char = inp[inp_index];

    // While an end of sentence character has not been encountered
    while ((cur_char != '\n') && (cur_char != '\0')) {
        int cur_char_valid = is_valid_char(cur_char);

        printf("Current character, %c, is %s. It is %s a vowel.\n", cur_char, cur_char_valid ? "valid": "invalid", "?");

        // Prepare variables for the next loop
        inp_index += 1;
        cur_char = inp[inp_index];
    }

    // Indicates the current index in "out"
}





//
// Do not modify anything below


int main() {

    read_input(input_sentence);

    print_string("\noutput:\n");

    output_sentence[0] = '\0';
    process_input(input_sentence, output_sentence);

    output(output_sentence);

    return 0;
}

//---------------------------------------------------------------------------
// End of file
//---------------------------------------------------------------------------

