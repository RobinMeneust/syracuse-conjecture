/**
 * \file main.c
 * \brief It will check the user input and write in the given file (the second parameter) the sequence of integers generated with the Syracuse conjecture starting from the provided number (the first parameter)
 * \date 2022
 */

#include <stdio.h>
#include <string.h>

/**
 * \fn unsigned long long stringToUnsignedLongLong(char * text)
 * \brief Convert a string into an unsigned long long (integer). If there is a character that isn't a number then it returns an error
 * \param text The string that we want to convert to an unsigned long long
 * \return The unsigned long long converted from the text. It returns 0 if there was an error
 */

unsigned long long stringToUnsignedLongLong(char * text)
{
    int i=0;
    unsigned long long number=0;
    unsigned long long result=0;

    // We check that the parameter is a number by doing the difference between each of its characters and '0' in ASCII. If it's not a number we return -1
    // We also need to check if there is an overflow:
    // If the 10 times the result is greater than the maximum value a unsigned long long can contain (-1LLU)
    // If 10*result is equal to this maximum we will have an overflow if the number added is greater than the unit of this maximum
    while(text[i]!='\0'){ 
        number=text[i]-'0';
        if(number<0 || number>9 || result>((-1LLU)/10) || (result==((-1LLU)/10) && number>(-1LLU)%10))
            return 0;
        result=(result*10ULL) + number;
        i++;
    }
    return result;
}

/**
 * \fn int main(int argc, char** argv)
 * \brief Main function of this Syracuse project
 * \param argc An integer that contains the number of arguments given
 * \param argv An array containing the arguments given (it's an array of arrays of characters)
 * \return 0 if the function runs and exits correctly. It returns 1 if there was an error
 */

int main(int argc, char** argv)
{
    FILE* fileOutput = NULL;    // It will be use to write in the output file whose name is given in parameters, that will contain data about the Syracuse sequence starting from the given u0
    unsigned long long max_altitude=0;    // The maximum value of Un
    unsigned long long index=0;     // The index n of each un. At the end it will be equal to the flight duration
    unsigned long long altitude_duration=0;       // The maximum number of successive values greater than u0
    unsigned long long altitude_duration_temp=0;      // The current number of successive values greater than u0
    unsigned long long un=0;      // The current altitude of the flight
    unsigned long long u0=0;      // The first value of the sequence

    // If there aren't exactly 3 parameters (including the name of this program), we return an error and we exit this program
    if(argc != 3){ 
        fprintf(stderr, "ERROR: bad parameters. 2 parameters are expected\n");
        return 1;
    }

    // If the name of the output file provided by the second parameter is too long, an error is returned and we exit the program
    if(strlen(argv[2]) > FILENAME_MAX) 
    {
        fprintf(stderr, "ERROR: the given file name is too long\n");
        return 1;
    }

    // We convert the first parameter into a number
    u0=stringToUnsignedLongLong(argv[1]); 

    // We check if u0 is strictly positive since Syracuse's conjecture only works with it (except for some variants of this conjecture)
    if(u0 <= 0) 
    {
        fprintf(stderr, "ERROR: U0='%s' is not correct\n", argv[1]);
        return 1;
    }

    fileOutput = fopen(argv[2], "w");

    // If the file can't be opened it also returns an error and we exit the program
    if(!fileOutput){
        fprintf(stderr, "ERROR: the file can't be opened, it may be because of invalid characters\n");
        return 1;
    }
    
    un = u0;

    // We add a header and u0 to the output file
    fprintf(fileOutput,"n Un\n");
    fprintf(fileOutput, "0 %llu\n", u0);
    max_altitude=u0;
    
    while(un != 1)
    {
        if(un%2 == 0)
            un = un/2;
        else
            un = (un*3) + 1;

        if(max_altitude < un)
            max_altitude = un;

        if(un > u0)
            altitude_duration_temp++;
        else{
            if(altitude_duration < altitude_duration_temp)
                altitude_duration = altitude_duration_temp;
            altitude_duration_temp = 0;
        }

        index++;
        fprintf(fileOutput, "%llu %llu\n", index, un);
    }

    // We write at the end of the file: maximimum altitude, flight duration and altitude duration
    fprintf(fileOutput, "altimax=%llu\ndureevol=%llu\ndureealtitude=%llu", max_altitude, index, altitude_duration);

    // We close the file and check if it was done correctly
    if(fclose(fileOutput) == EOF){
        fprintf(stderr, "ERROR: the file can't be closed\n");
        return 1;
    }
    return 0;
}
