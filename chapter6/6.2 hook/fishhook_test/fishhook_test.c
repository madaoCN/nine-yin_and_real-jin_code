#import <dlfcn.h>
#import <stdio.h>

#import "fishhook.h"

static FILE* (*orig_fopen)(const char *filename, const char *mode);
 
FILE* my_fopen(const char *filename, const char *mode){

  printf("fopen hook\n");
  printf("fopen filename: %s\n", filename);
  return orig_fopen(filename,mode);
}

int main(int argc, char * argv[])
{
    rebind_symbols((struct rebinding[1]){{"fopen", my_fopen, (void *)&orig_fopen}}, 1);
    FILE *fp = fopen("/usr/bin/debugserver","rb");
    fclose(fp);
    return 0;
}
