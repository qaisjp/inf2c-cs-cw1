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

char word[(MAX_WORD_LENGTH*3)+1];
char preword[(MAX_WORD_LENGTH*3)+1];

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

int is_upper_char(char ch) {
    return ( ch >= 'A' && ch <= 'Z' );
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

// piglatinify takes a word with a trailing null character, and a length
int piglatinify(char* word, int length) {
    // Uncomment these two lines to check if the process_input code works correctly
    // word[0] = 'Q';
    // return length;

    // printf("Input word: %s\n", word);

    // We will reuse the register allocated for wordStart for this bit
    int firstCapped = is_upper_char(word[0]);
    int lastCapped = is_upper_char(word[length-1]);
    int word_index = 0;
    int vowel_index = -1;

    // If the first character is capped, but last not, make first character lowercase before moving it around
    if (firstCapped && !lastCapped) {
        word[0] = word[0]+32;
    }

    // First find the vowel index (or end of word)
    while (vowel_index < length) {
        vowel_index += 1;
        if (is_vowel(word[vowel_index])) {
            break;
        }
    }

    // printf("Post-vowel: %s (vowel at index %d)\n",word + vowel_index, vowel_index);

    // Append all character upto and excluding the vowel to the end of the word
    while (word_index < vowel_index) {
        // printf("Place character (%c, %d) at (%d)\n", word[word_index], word[word_index], length);
        word[length] = word[word_index];

        word_index += 1; // our progress through the word to the vowel
        length += 1; // the 
    }

    if (firstCapped && lastCapped) {
        word[length] = 'A';
        word[length+1] = 'Y';
    } else {
        word[length] = 'a';
        word[length+1] = 'y';        
    }
    length += 2;


    // Temporary code: clear everything before the vowel
    word_index = vowel_index;
    while (word_index > 0) {
        word_index -= 1;
        word[word_index] = '_';
    }

    // Start at the vowel index
    word_index = vowel_index;
    while (word_index < length) {
        // printf(
        //     "Move %c from %d to %d [w:%d, v:%d]\n", word[word_index], word_index, word_index-vowel_index
        //     , word_index, vowel_index
        // );

        word[word_index-vowel_index] = word[word_index];

        word_index += 1;
    }

    length -= vowel_index;

    // If the first character was capped, but last not, make sure the first character is uppercase
    if (firstCapped && !lastCapped) {
        word[0] = word[0]-32;
    }

    word[length] = '\0';
    // printf("%s\n\n", word);
    return length;
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

            // REMEMBER: wordStart will be reset after this branch, so we can freely use that variable.

            // First thing to do is build our word array.
            //
            // Usually we reserve wordStart to just storing the inp_index of the currently
            // tracked word. Since we'll be resetting wordStart at the end of this branch,
            // and since we'll only be referring to `inp` here in this branch, we can reuse
            // wordStart throughout this branch.
            //
            // So from now on, within this branch, wordStart is pretty much just a free inp_index.
            //
            int length = 0;
            while (wordStart < inp_index) {
                word[length] = inp[wordStart];
                wordStart += 1;
                length += 1;
            }

            // Trail the word with a null char for safety. Length of the string does not change.
            word[length] = '\0';

            // Do something to the word
            int newLength = piglatinify(word, length);

            // We need to append `word` onto `out`.
            // Reuse wordStart to refer to the progress through `word` so far.
            wordStart = 0;
            while (wordStart < newLength) {
                // Add the character to the output.
                out[out_index] = word[wordStart];

                // Increment the progress through `word`, and index of `out`.
                out_index += 1;
                wordStart += 1;
            }

            // Print that word out.
            // printf("%s\n", word);

            // We're at the end of the word, so we can peacefully reset the index marking
            // the beginning of the current word. This is so that we can further detect new words.
            wordStart = -1;
        }

        if (wordStart < 0) {
            out[out_index] = inp[inp_index];
            out_index += 1;

            // printf(
            //     "Char: %c (%s).\n",
            //     cur_char,
            //     cur_char_valid ? "valid": "invalid"
            // );
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

