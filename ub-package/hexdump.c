//
// hexdump.c: generate hex dumps from binary files
//            Written by 'Uncle Bernie' 23. November 2025

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <malloc.h>

int main(int argc, char *argv[])
{
 FILE *fp;
 unsigned int adr, skip, start, end;
 int i, byte, buf[16];

 if(argc < 2) {
  printf("Usage: hexdump <start> <end> [-s<skipcnt>] [<filename>] \n");
  printf("====== <start>, <end>, <skipcnt> must be hexadecimal.\n");
  printf("       <skipcnt> bytes are skipped, then <start> address begins.\n");
  printf("       <end> is the address of the last byte to be output.\n");
  printf("       If no <filename> is given, input is from stdin.\n");
  exit(1);
 }

 if(sscanf(argv[1], "%x", &start) != 1) {
  fprintf(stderr, "%s: bad start address, must be hexadecimal, arg1=%s\n",
   argv[0], argv[1]
  );
  exit(1);
 } 

 if(sscanf(argv[2], "%x", &end) != 1) {
  fprintf(stderr, "%s: bad end address, must be hexadecimal, arg2=%s\n",
   argv[0], argv[2]
  );
  exit(1);
 } 

 if(end < start) {
  fprintf(stderr, "%s: end address $%.4X < start address %.4X.\n",
   argv[0],  end, start
  );
  exit(1);
 }

 skip = 0;
 i = 3;
 if((argc > 3) && !strncmp(argv[3], "-s", 2)) {
  if(sscanf(argv[3] + 2, "%x", &skip) != 1) {
   fprintf(stderr, "%s: bad skip count, must be hexadecimal, arg3=%s\n",
    argv[0], argv[3] + 2
   );
   exit(1);
  }
  i++;
 } 

 if(argc > i) {
  if(!(fp = fopen(argv[i], "r"))) {
   fprintf(stderr, "Can't open file '%s'\n", argv[i]);
   exit(1);
  }
 } else fp = stdin;

 adr = 0;
 while(adr++ < skip) fgetc(fp);

 adr = start;
 while(adr <= end) {
  printf("%.4X", adr);
  for(i = 0; i < 16; i++) {
   byte = buf[i] = fgetc(fp);
   if((byte == EOF)||(adr + i > end)) {
    while(i < 16) {
     printf("   ");
     buf[i++] = ' ';
    }     
    break;
   }
   printf(" %.2X", byte);
  }
  putchar(' ');
  for(i = 0; i < 16; i++) {
   byte = buf[i] & 0x7F;
   if(isspace(byte)) byte = ' ';
    else if(!isprint(byte)) byte = '`';
   putchar(byte);
  }
  putchar('\n');
  adr += i;
 }
 
 exit(0);
}
