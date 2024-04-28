#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER_SIZE 1024
extern char * fuzz_target(char *param_1,size_t param_2);

int main() {
    char buffer[BUFFER_SIZE] = {0};

    // Read data from stdin
    size_t data_length = fread(buffer, 1, BUFFER_SIZE-1, stdin);
    char* output = fuzz_target(buffer, data_length);
    if (output) {
        printf("Processed output:\n%s\n", output);
        // The function allocated memory on the heap
        // Let's be polite and free it in case we do a persistent fuzz later
        free(output);
    } else {
        printf("Function returned NULL\n");
    }
    return EXIT_SUCCESS;
}