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
            break;
        result=(result*10L) + number;
        i++;
    }
    return result;
}


int main(int argc, char** argv)
{
    long max_altitude=0;
    long flight_duration=0;
    long altitude_duration=0;
    long altitude_duration_temp=0;
    long un_before=0;
    long un=0;
    long u0=0;

    if(argc!=3){
        fprintf(stderr, "ERROR: bad parameters");
        return -1;
    }
    else if(strlen(argv[2])>FILENAME_MAX) //argv[1]>0 ?
    {
        fprintf(stderr, "ERROR: the given file name is too long"); // check if it has invalid characters too ?
        return -1;
    }

    u0=stringToLong(argv[1]);
    un=u0;

    printf("u[0] = %ld\n", u0);
    while(un!=1) // or: stop when there is a cycle ?
    {
        un_before=un;
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
        printf("u[%ld] = %ld\n", flight_duration, un);
    }
    printf("max_alt %ld  |   flight_dur %ld   |   altitude_dur %ld", max_altitude, flight_duration, altitude_duration);
    return 0;
}
