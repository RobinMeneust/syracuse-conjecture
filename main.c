/**
 * \file main.c
 * \brief It will check the user input and write in the given file the sequence of integers generated with the Syracuse conjecture starting from the provided number (the first parameter)
 * \date 2022
 */

#include <stdio.h>
#include <string.h>

unsigned long stringToUnsignedLong(char * text)
{
    int i=0;
    unsigned long number=0;
    unsigned long result=0;

    while(text[i]!='\0'){ //we verify that the parameter is a number
        number=text[i]-'0'; //by doing the difference between the parameter in ascii and 0 in ascii
        if(number<0 || number>9)
            return -1;
        result=(result*10L) + number; //we transform the parameter in character(s) into a number
        i++;
    }
    return result;
}

/**
 * \fn int main(int argc, char** argv)
 * \brief Main function of this Syracuse project
 * \param argc An integer that contains the number of arguments given
 * \param argv An array containing the arguments given (it's an array of arrays of characters)
 * \return 0 if the function runs and exits correctly
 */

int main(int argc, char** argv)
{
    FILE* fileOutput = NULL;

    unsigned long max_altitude=0;    //the maximum value of Un for each n
    unsigned long flight_duration=0;     //the number n at the end of each flight
    unsigned long altitude_duration=0;       //the maximum number of successives values up to each Un 
    unsigned long altitude_duration_temp=0;      //?
    unsigned long un=0;      //un is the actual altitude of the flight
    unsigned long u0=0;      //u0 is the number to begin the flight

    if(argc!=3){ //if there ain't exactly 3 parameters, we quit the program
        fprintf(stderr, "ERROR: bad parameters\n");
        return 1;
    }
    else if(strlen(argv[2])>FILENAME_MAX) //argv[1]>0 ? //or if the parameters' names are to long
    {
        fprintf(stderr, "ERROR: the given file name is too long\n");
        return 1;
    }
    

    u0=stringToUnsignedLong(argv[1]); //we transform the first parameter which is in text string into a number

    if(u0 <= 0) //Syracuse works with strictly postive numbers
    {
        fprintf(stderr, "ERROR: U0='%s' is not correct\n", argv[1]);
        return 1;
    }

    fileOutput = fopen(argv[2], "w"); //we do the same checking for the second parameter

    if(!fileOutput){
        fprintf(stderr, "ERROR: the file can't be opened, it may be because of invalid characters\n");
        return 1;
    }


    un=u0;

    //time to write in new files and prepare the columns n and Un
    fprintf(fileOutput,"n Un\n");
    fprintf(fileOutput, "0 %lu\n", u0);
    max_altitude=u0;
    
    while(un!=1) // or: stop when there is a cycle ?
    {
        if(un%2 == 0) //if the numer is an even number
            un = un/2;
        else
            un = (un*3) + 1;

        if(max_altitude<un)
            max_altitude=un;

        if(un>u0)
            altitude_duration_temp++;
        else{
            if(altitude_duration<altitude_duration_temp)
                altitude_duration = altitude_duration_temp;
            altitude_duration_temp=0;
        }

        flight_duration++;
        
        fprintf(fileOutput, "%lu %lu\n", flight_duration, un);
    }
    //we write the results of records at the end of the file
    fprintf(fileOutput, "altimax=%lu\ndureevol=%lu\ndureealtitude=%lu", max_altitude, flight_duration, altitude_duration);

    
    if(fclose(fileOutput)==EOF){ //time to close the file
        fprintf(stderr, "ERROR: the file can't be closed\n");
        return 1;
    }
    return 0;
}