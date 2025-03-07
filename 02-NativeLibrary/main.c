#include <stdlib.h>
#include <stdio.h>

// extern int aotsample_add(int a, int b);

int aotsample_add(int a, int b)
{
    return a + b;
}

int main(void)
{
    // Sum two integers
    int sum = aotsample_add(2, 8);
    printf("The sum is %d \n", sum);
}
