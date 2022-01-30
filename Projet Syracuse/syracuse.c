#include <stdio.h>
#include <string.h>

long stringToLong(char * text)
{
    int i=0;
    long number=0;
    long result=0;

    while(text[i]!='\0'){ //we verify that the parameter is a number
        number=text[i]-'0'; //by doing the difference between the parameter in ascii and 0 in ascii
        if(number<0 || number>9)
            return -1;
        result=(result*10L) + number; //we transform the parameter in character(s) into a number
        i++;
    }
    return result;
}

int main(int argc, char** argv)
{
    FILE* fileOutput = NULL;

    long max_altitude=0;    //the maximum value of Un for each n
    long flight_duration=0;     //the number n at the end of each flight
    long altitude_duration=0;       //the maximum number of successives values up to each Un 
    long altitude_duration_temp=0;      //?
    long un=0;      //un is the actual altitude of the flight
    long u0=0;      //u0 is the number to begin the flight

    if(argc!=3){ //if there ain't exactly 3 parameters, we quit the program
        fprintf(stderr, "ERROR: bad parameters\n");
        return 1;
    }
    else if(strlen(argv[2])>FILENAME_MAX) //argv[1]>0 ? //or if the parameters' names are to long
    {
        fprintf(stderr, "ERROR: the given file name is too long\n");
        return 1;
    }
    

    u0=stringToLong(argv[1]); //we transform the first parameter which is in text string into a number

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
    fprintf(fileOutput, "0 %ld\n", u0);

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
        
        fprintf(fileOutput, "%ld %ld\n", flight_duration, un);
    }
    //we write the results of records at the end of the file
    fprintf(fileOutput, "altimax=%ld\ndureevol=%ld\ndureealtitude=%ld", max_altitude, flight_duration, altitude_duration);

    
    if(fclose(fileOutput)==EOF){ //time to close the file
        fprintf(stderr, "ERROR: the file can't be closed\n");
        return 1;
    }
    return 0;
}