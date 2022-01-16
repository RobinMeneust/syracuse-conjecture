#include <stdio.h>
#include <string.h>
#include <stdlib.h>

long stringToLong(char * text)
{
    int i=0;
    long number=0;
    long result=0;

    while(text[i]!='\0'){
        number=text[i]-'0';
        if(number<0 || number>9)
            return -1;
        result=(result*10L) + number;
        i++;
    }
    return result;
}

int main(int argc, char** argv)
{
    FILE* fileOutput = NULL;

    long max_altitude=0;
    long flight_duration=0;
    long altitude_duration=0;
    long altitude_duration_temp=0;
    long un=0;
    long u0=0;

    if(argc!=3){
        fprintf(stderr, "ERROR: bad parameters");
        exit(EXIT_FAILURE);
    }
    else if(strlen(argv[2])>FILENAME_MAX) //argv[1]>0 ?
    {
        fprintf(stderr, "ERROR: the given file name is too long"); // check if it has invalid characters too ?
        exit(EXIT_FAILURE);
    }
    

    u0=stringToLong(argv[1]);

    if(u0 <= 0)
    {
        fprintf(stderr, "ERROR: U0='%s' is not correct\n", argv[1]);
        exit(EXIT_FAILURE);
    }

    fileOutput = fopen(argv[2], "w");

    if(!fileOutput){
        fprintf(stderr, "ERROR: the file can't be opened\n");
        exit(EXIT_FAILURE);
    }


    un=u0;


    fprintf(fileOutput,"n Un\n");
    fprintf(fileOutput, "0 %ld\n", u0);

    while(un!=1) // or: stop when there is a cycle ?
    {
        if(un%2 == 0)
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
    fprintf(fileOutput, "altimax=%ld\ndureevol=%ld\ndureealtitude=%ld", max_altitude, flight_duration, altitude_duration);

    
    if(fclose(fileOutput)==EOF){
        fprintf(stderr, "ERROR: the file can't be closed\n");
        exit(EXIT_FAILURE);
    }
    return 0;
}