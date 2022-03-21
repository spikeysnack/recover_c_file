# recover_c_file

Recover an accidently written-over text file


## Description

Search raw disc bytes for a file containing a string and recover it.

This is for text file accidently removed or overwritten.

It only works well if you run it shortly after you realize
what happened and don't save a bunch of stuff to disk in between.


## Getting Started

### Dependencies

* getopt findmnt nice tr pv grep strings
 
  getopt, findmnt, and pv are standard linux utiltities that can
  be installed in your linux distro.
  
### Installing

* just run it with bash, or make it executable and run it.

### Usage
usage: <sudo> recover_c_file.sh options

   sudo  bash  recover_c_file.sh   <options>

   (must be run as super-user to read device)

   required:
   -s|--string "string"   string to search for
   -d|--dev    <device>   block device to scan

   optional:                                              (defaults)
   -p|--pre         <num>     how many lines before string   (50)
   -P|--post        <num>     how many lines after string    (100)
   -m|--matches     <num>     how many times to match        (5)
   -D|--output-dir  "string"  dir to save file to            (./)
   -o|--output-file "string"  filename to save to            ("recovered.txt")
   -c|--color       "string"  use color (yes/no/0/1)         (yes)

   info:
   -h|--help  output this message
   -t|--test  print out args read, don't start scanning
   -v|--version version info
   -l|--license license info

   description:
	  Search the device you specify
	  and create a file called 'recovered.txt'
	  preferrably on another file system.
	  The recovered file will contain:
	  50 lines pre-match, matching line, 100 lines post-match.
	  repeats 5 times, appending.


```
sudo bash recover_c_file.sh --help --string "a string" --dev "/dev/sda1" \
	--pre 50 --post 100 --matches 5 --output-dir /tmp --output-file recovered.c.txt
```

## Authors

# [Chris Reid](spikeysnack@gmail.com)


## Version History

* 1.1
    * checks for same partition and warns

## License

This project is licensed under the Creative Commons License. - see the LICENSE.md file for details

## Acknowledgments

[stackexchange.com](https://unix.stackexchange.com/questions/149342/can-overwritten-files-be-recovered)

for:

nice                	David MacKenzie     	GNU GPL 2.0 free software

tr                  	Jim Meyering        	GNU GPL 2.0 free software

grep                	Ken Thompson        	GNU GPL 2.0 free software

getopt              	Frodo Looijaard     	GNU GPL 2.0 free software

strings             	Kernighan & Ritchie 	GNU GPL 2.0 free software

pv                  	Andrew Wood         	ARTISTIC 2.0 free software

fimdmnt             	Karel Zak           	GNU GPL 2.0 free software



