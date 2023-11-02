//++
//romcksum
//
//   This program will read a ROM image from an Intel .HEX file, calculate a
// 16 bit checksum for it, and then store that checksum in the last two bytes
// of the ROM.  The checksum is calculated so that the 16 bit unsigned sum of
// all the bytes in the ROM, _including_ the checksum in the last two bytes,
// is equal to the last two bytes.
//
//   Since the checksum is included in itself, we have to go to some lengths
// to prevent the checksum value from affecting its own calculation.  The way
// that's done is to actually use the last _four_ bytes of the ROM - the last
// two contain the checksum and the two before that contain the two's complement
// of each byte in the checksum.  The sum of a byte and its complement is always
// 0x0100, and since there are two such bytes, adding a checksum to the ROM in
// this way always adds 0x0200 to the original checksum _regardless_ of what
// the actual checksum value may be.
//
//   This rather complicated system has a couple of advantages.  First, the
// checksum calculated by the Data IO EPROM programmer will always agree with
// the checksum calculated by this program.  Second, since the checksum is not
// zero (as it would be if we simply stored the two's complement of the
// checksum in the ROM), the checksum can be used to uniquely identify ROM
// versions.
//
//    The observant reader may notice that there's a tiny little problem with
// this algorithm.  If either byte of the checksum just happens to be 0x00,
// then the two's complement of 0 is, oopsss, 0!  Needless to say, 0 plus 0
// does not give 0x0100!  This is an unavoidable consequence of using the
// two's complement.  One easy fix would be to use the one's complement instead,
// which has no such nasty pitfall, but the weight of historical precendent
// prevents us from taking the easy way out.
//
//   Instead, the alorithm checks for this case (either or both bytes zero)
// and adjusts the checksum correction (normally 0x0200) accordingly.
//
//   One final side effect of this program is that it also fills unused bytes
// in the ROM image, and writes these filler characters out to the new HEX
// file.  Normally the filler is 0x00, but an alternate value may be specified
// on the command line.
//
// USAGE:
//   romcksum foo.hex
//	- just calculate (and print) the checksum of foo.hex
//
//   romcksum old.hex 32K 0xFF new.hex
//	- calculate the checksum of old.hex and generate the image for a 32K
//	  ROM, including filler bytes and checksum, in new.hex
//
// NOTE:
//   This program will work for ROMs up to 64K, which requires that longs
// be used to sizes and counts...
//
// REVISION HISTORY
// 12-May-98	RLA	New file...
//--
#include <stdio.h>		// printf(), scanf(), et al.
#include <stdlib.h>		// exit(), ...
#include <malloc.h>		// malloc(), _fmalloc(), etc...
#include <memory.h>		// memset(), etc...
#include <string.h>

// Handy types...
typedef unsigned char uchar;
typedef unsigned int bool;
#define FALSE	((bool) (0))
#define TRUE	((bool) (~FALSE))

// Globals...
long  lROMSize;					// size of the ROM, in bytes (e.g. 65536)
uchar uFillByte;				// filler value for unused ROM locations
long  lChecksumOffset;			// position of the checksum bytes
long  lROMOffset;				// offset of the EPROM in memory
bool  fVerbose;					// true for verbose output
bool  fLittleEndian;			// store checksum in little endian format
bool  fOnesComplement;			// use the 1's complement algorithm
char  szInputFile[_MAX_PATH];	// input file specification
char  szOutputFile[_MAX_PATH];	// output file specification



//++
//ReadHex
//
//   This function will load a standard Intel format .HEX file into memory.
// Only the traditional 16-bit address format is supported, which puts an
// upper limit of 64K on the amount of data which may be loaded.  Only
// record types 00 (data) and 01 (end of file) are recognized.
//
//   The number of bytes read will be returned as the function's value,
// and this will be zero if any error occurs.  Note that all counts, sizes
// and offsets must be longs on the off chance that exactly 64K bytes will
// be read!
//--
long ReadHex (		// returns count of bytes read, or zero if error
  char      *Name,	// name of the .HEX file to be loaded
  uchar far *Data,	// this array receives the data loaded
  long       Size,	// maximum size of the array, in bytes
  long    lOffset)	// offset applied to input records
{
  FILE	   *f;		// handle of the input file
  long      Count = 0;	// number of bytes loaded from file
  unsigned  Length;	// length       of the current .HEX record
  unsigned  Address;	// load address "   "     "      "     "
  unsigned  Type;	// type         "   "     "      "     "
  unsigned  Checksum;	// checksum     "   "     "      "     "
  unsigned  Byte;	// temporary for the data byte read...
  
  if ((f=fopen(Name, "rt")) == NULL)
    {fprintf(stderr,"%s: unable to open file\n", Name);  return 0;}

  while (1) {
    if (fscanf(f,":%2x%4x%2x",&Length,&Address,&Type) != 3)
      {fprintf(stderr,"%s: bad .HEX file format (1)\n", Name);  return 0;}
    if (Type > 1)
      {fprintf(stderr,"%s: unknown record type\n", Name);  return 0;}
    Checksum = Length + (Address >> 8) + (Address & 0xFF) + Type;
    for (;  Length > 0;  --Length, ++Address, ++Count) {
      if (fscanf(f,"%2x",&Byte) != 1)
        {fprintf(stderr,"%s: bad .HEX file format (2)\n", Name);  return 0;}
      if (((Address + lOffset) & 0xFFFF) >= Size)
        {fprintf(stderr,"%s: address outside ROM\n", Name);  return 0;}
      Data[(Address+lOffset) & 0xFFFF] = (uchar) Byte;
      Checksum += Byte;
    }
    if (fscanf(f,"%2x\n",&Byte) != 1)
      {fprintf(stderr,"%s: bad .HEX file format (3)\n", Name);  return 0;}
    Checksum = (Checksum + Byte) & 0xFF;
    if (Checksum != 0)
      {fprintf(stderr,"%s: checksum error\n", Name);  return 0;}
    if (Type == 1) break;
  }
  
  fclose(f);
  return Count;
}


//++
//WriteHex
//
//   This function will write an array of bytes to a file in standard Intex
// .HEX file format.  Only the traditional 16 bit format is supported and
// so the array must be 64K or less.  The only records generated are type 00
// (data) and 01 (end of file).  This routine always writes everything in
// the array and doesn't attempt to remove filler bytes...
//--
void WriteHex (
  char      *Name,	// name of the .HEX file to be written
  uchar far *Data,	// array of bytes to be saved
  long       Count)	// number of bytes to write
{
  FILE *f;		// handle of the output file
  unsigned Address = 0;	// address of the current record
  unsigned RecordSize;	// size of the current record
  int      Checksum;	// checksum "  "     "       "
  unsigned i;		// temporary...

  if ((f=fopen(Name, "wt")) == NULL)
    {fprintf(stderr,"%s: unable to write file\n", Name);  return;}

  while (Count > 0) {
    RecordSize = (Count > 16) ? 16 : (unsigned) Count;
    fprintf(f,":%02X%04X00", RecordSize, Address);
    Checksum = RecordSize + (Address >> 8) + (Address & 0xFF) + 00 /* Type */;
    for (i = 0;  i < RecordSize;  ++i) {
      fprintf(f,"%02X", *(Data+Address+i));
      Checksum += *(Data+Address+i);
    }
    fprintf(f,"%02X\n", (-Checksum) & 0xFF);
    Count -= RecordSize;  Address += RecordSize;
  }
  
  fprintf(f, ":00000001FF\n");  fclose(f);
}


//++
//   This function parses the command line and initializes all the global
// variables accordingly.  It's tedious, but fairly brainless work.  If there
// are any errors in the command line, then it simply prints an error message
// and exits - there is no error return from this function!
//--
void ParseCommand (int argc, char *argv[])
{
  int nArg;  char *psz;

  // First, set all the defaults...
  szInputFile[0] = szOutputFile[0] = '\0';
  lROMSize = lChecksumOffset = lROMOffset = 0L;  uFillByte = 0xFF;
  fLittleEndian = fVerbose = fOnesComplement = FALSE;

  // If there are no arguments, then just print the help and exit...
  if (argc == 1) {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr,"  romcksum input-file [-cnnnn] [-snnnn] [-onnnn] [-fnn] [-e] [-v] output-file\n");
    fprintf(stderr,"\t-cnnnn\t- set the offset of the checksum to nnnn\n");
    fprintf(stderr,"\t-snnnn\t- set the ROM size to nnnn bytes\n");
    fprintf(stderr,"\t-onnnn\t- set the offset applied to input files\n");
    fprintf(stderr,"\t-fnn\t- fill unused ROM locations with nn\n");
    fprintf(stderr,"\t-e\t- store the checksum in little-endian format\n");
    fprintf(stderr,"\t-1\t- use one's complement algorithm\n");
    fprintf(stderr,"\t-v\t- verbose output\n");
    exit(EXIT_SUCCESS);
  }

  for (nArg = 1;  nArg < argc;  ++nArg) {
    // If it doesn't start with a "-" character, then it must be a file name.
    if (argv[nArg][0] != '-') {
      if (strlen(szInputFile) == 0) strcpy(szInputFile, argv[nArg]);
      else if (strlen(szOutputFile)   == 0) strcpy(szOutputFile, argv[nArg]);
      else {
        fprintf(stderr, "romcksum: too many files specified: \"%s\"", argv[nArg]);
	exit(EXIT_FAILURE);
      }
      continue;
    }

    // Handle the -c (checksum) option...
    if (strncmp(argv[nArg], "-c", 2) == 0) {
      lChecksumOffset = strtoul(argv[nArg]+2, &psz, 10);
      if ((*psz != '\0') || (lChecksumOffset == 0) || (lChecksumOffset > 0xFFFF)) {
        fprintf(stderr, "romcksum: illegal offset: \"%s\"", argv[nArg]);
	exit(EXIT_FAILURE);
      }
      continue;
    }

    // Handle the -o (offset) option...
    if (strncmp(argv[nArg], "-o", 2) == 0) {
      lROMOffset = strtoul(argv[nArg]+2, &psz, 10);
      if ((*psz != '\0') || (lROMOffset > 0xFFFF)) {
        fprintf(stderr, "romcksum: illegal offset: \"%s\"", argv[nArg]);
	exit(EXIT_FAILURE);
      }
      continue;
    }

    // Handle the -s (ROM size) option...
    if (strncmp(argv[nArg], "-s", 2) == 0) {
      lROMSize = strtoul(argv[nArg]+2, &psz, 10);
      if (*psz == 'k' || *psz == 'K')   lROMSize <<= 10, ++psz;
      if (*psz != '\0') {
        fprintf(stderr,"romcksum: invalid ROM size \"%s\"\n", argv[nArg]);
        exit(EXIT_FAILURE);
      }
      continue;
    }

    // Handle the -f (fill byte) option...
    if (strncmp(argv[nArg], "-f", 2) == 0) {
      uFillByte = (unsigned) strtol(argv[nArg]+2, &psz, 10);
      if (*psz != '\0') {
        fprintf(stderr,"romcksum: invalid fill byte \"%s\"\n", argv[nArg]);
        exit(EXIT_FAILURE);
      }
      continue;
    }

    // Handle the -e (little endian) option...
    if (strcmp(argv[nArg], "-e") == 0) {
      fLittleEndian = TRUE;
      continue;
    }

    // Handle the -1 (ones complement) option...
    if (strcmp(argv[nArg], "-1") == 0) {
      fOnesComplement = TRUE;
      continue;
    }

    // Handle the -v (verbose) option...
    if (strcmp(argv[nArg], "-v") == 0) {
      fVerbose = TRUE;
      continue;
    }

    // Otherwise it's an illegal option...
    fprintf(stderr, "romcksum: unknown option - \"%s\"\n", argv[nArg]);
    exit(EXIT_FAILURE);
  }

  // Make sure all the file names were specified...
  if (strlen(szOutputFile) == 0) {
    fprintf(stderr, "romcksum: required file names missing");
    exit(EXIT_FAILURE);
  }
}


//++
//main
//--
void main (int argc, char *argv[])
{
  uchar far *Data;	// pointer to the ROM image buffer
  long       ByteCount;	// count of bytes loaded from the .HEX file
  unsigned   Checksum;	// computed checksum for the .HEX file
  unsigned   Checksum2;
  long       i;		// temporaries...	
  uchar c1, c2;
 
  ParseCommand(argc, argv);
  if (lROMSize == 0) lROMSize = 32768L;
  if (lChecksumOffset == 0) lChecksumOffset = lROMSize-4;
  if (fVerbose) {
    fprintf(stderr,"Input file  = %s\n", szInputFile);
    fprintf(stderr,"Output file = %s\n", szOutputFile);
    fprintf(stderr,"ROM Size        = %ld (0x%05lx)\n", lROMSize, lROMSize);
    fprintf(stderr,"Fill Byte       = %u (0x%02x)\n", uFillByte, uFillByte);
    fprintf(stderr,"Checksum Offset = %ld (0x%05lx)\n", lChecksumOffset, lChecksumOffset);
    fprintf(stderr,"ROM Offset      = %ld (0x%05lx)\n", lROMOffset, lROMOffset);
    fprintf(stderr,"Checksum Order  = %s\n", fLittleEndian ? "Little Endian" : "Big Endian");
  }
    
  // Allocate a buffer to hold the ROM image and fill it with the filler value.
  Data = (uchar far *) _halloc((size_t) lROMSize, 1);
  if (Data == NULL) {
    fprintf(stderr,"romcksum: failed to allocate memory\n");
    exit(1);
  }
  for (i = 0;  i < lROMSize;  ++i)  Data[i] = uFillByte;

  // Load the original .HEX file...
  ByteCount = ReadHex(szInputFile, Data, lROMSize, lROMOffset);
  if (ByteCount == 0)  exit(1);
  Data[lChecksumOffset+0] = Data[lChecksumOffset+1] = uFillByte;
  Data[lChecksumOffset+2] = Data[lChecksumOffset+3] = uFillByte;

  // Calculate the checksum of the entire ROM...
  for (i = 0, Checksum = 0;  i < lROMSize;  ++i)  Checksum += Data[i];

  //   Now, adjust the checksum by first subtracting off the original value
  // of the last four bytes (which we know now to be filler bytes).  Then,
  // since we know that no matter what the checksum actually is the last four
  // bytes will always total 0x0200, adjust the checksum for that.
  Checksum -= 4*((unsigned) uFillByte);
  Checksum += fOnesComplement ? (0xFF+0xFF) : 0x0200;
  
  // Put the checksum and its complement in the top of the ROM image...
  c1 = Checksum & 0xFF;  c2 = (Checksum >> 8) & 0xFF;
  if (fLittleEndian) {
    Data[lChecksumOffset+2] = c1;  Data[lChecksumOffset+3] = c2;
  } else {
    Data[lChecksumOffset+3] = c1;  Data[lChecksumOffset+2] = c2;
  }
  if (fOnesComplement) {
    Data[lChecksumOffset+1] = ~Data[lChecksumOffset+3];
    Data[lChecksumOffset+0] = ~Data[lChecksumOffset+2];
  } else {
    Data[lChecksumOffset+1] = 256 - Data[lChecksumOffset+3];
    Data[lChecksumOffset+0] = 256 - Data[lChecksumOffset+2];
  }

  // Dump out the new ROM image and we're all done...
  WriteHex(szOutputFile, Data, lROMSize);
  printf("%s: %ld bytes, ROMsize=%ld, checksum=0x%04X\n", szOutputFile, ByteCount, lROMSize, Checksum);

  // Just for grins, verify it...
  for (i = 0, Checksum2 = 0;  i < lROMSize;  ++i)  Checksum2 += Data[i];
  if (Checksum != Checksum2) fprintf(stderr,"**** Checksum = 0x%04X\n", Checksum2);
  exit(0);  
}
