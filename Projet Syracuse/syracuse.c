#include <stdio.h>
#include <string.h>

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
        fprintf(stderr, "ERROR: bad parameters\n");
        return 1;
    }
    else if(strlen(argv[2])>FILENAME_MAX) //argv[1]>0 ?
    {
        fprintf(stderr, "ERROR: the given file name is too long\n");
        return 1;
    }
    

    u0=stringToLong(argv[1]);

    if(u0 <= 0)
    {
        fprintf(stderr, "ERROR: U0='%s' is not correct\n", argv[1]);
        return 1;
    }

    fileOutput = fopen(argv[2], "w");

    if(!fileOutput){
        fprintf(stderr, "ERROR: the file can't be opened, it may be because of invalid characters\n");
        return 1;
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
        return 1;
    }
    return 0;
}