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

char word[MAX_WORD_LENGTH+1];


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


// returns true only if an input character is a vowel
int is_vowel(char ch) {
    char* vowels = "aeiouAEIOU";

    int i = 0;
    while (i < 10)
    {
        if (ch == vowels[i]) {
            return true;
        }

        i += 1;
    }
    
    return false;
}

// piglatinify
int piglatinify(char* word, int length) {
    word[length] = 'y';
    word[length+1] = '\0';

    return length + 1;
}

void process_input(char* inp, char* out) {
    int inp_index = -1; // regular iterator through the input
    char cur_char = '\0'; // current character
    int out_index = 0; // current index for the output
    int wordStart = -1; // the index in the input corresponding to the beginning of the word

    // While an end of sentence character has not been encountered
    do {
        // Prepare variables for this  loop
        inp_index += 1;
        cur_char = inp[inp_index];

        int cur_char_valid = is_valid_char(cur_char);

        // (wordStart < 0) means we aren't logging a word
        // So if the current character is a valid word character
        // mark the current index as the beginning of a word 
        if (wordStart < 0 && cur_char_valid) {
            wordStart = inp_index;
        }

        if (is_hyphen(cur_char) && is_valid_char(inp[inp_index+1])) {
            // If this is a hyphen, and next is a valid character, we don't want to do anything!
            // We're here because we're bang smack in the middle of a hyphenated word.
        } else if (wordStart >= 0 && !cur_char_valid) {
            // If we're currently marking a word (wordStart >= 0)
            // and the current character is not valid, then we need to
            // do things with the word that we have marked.

            // First thing to do is build our word array, trailing with a null char for safety.
            int word_index = wordStart;
            int length = 0;
            while (word_index < inp_index) {
                word[length] = inp[word_index];
                word_index += 1;
                length += 1;
            }
            word[length] = '\0';

            // Do something to the word
            int newLength = piglatinify(word, length);

            // reuse word_index for the output word
            word_index = 0;
            while (word_index < newLength) {
                out[out_index] = word[word_index];
                out_index += 1;
                word_index += 1;
            }

            // Print that word out.
            printf("%s\n", word);

            // We're at the end of the word, so we can peacefully reset the index marking
            // the beginning of the current word. This is so that we can further detect new words.
            wordStart = -1;
        }

        if (wordStart < 0) {
            out[out_index] = inp[inp_index];
            out_index += 1;

            printf(
                "Char: %c (%s, %s).\n",
                cur_char,
                cur_char_valid ? "valid": "invalid",
                is_vowel(cur_char) ? "vowel" : "not a vowel"
            );
        }

    } while ((cur_char != '\n') && (cur_char != '\0'));

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

