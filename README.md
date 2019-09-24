# aws-scripting

View the presentation video: https://www.youtube.com/watch?v=LG-_K4JIFRc&t=5s

Download the slide deck: https://goo.gl/Sabjue 

The file "functions.sh" is a collection of useful functions that can help you with querying for ec2 instance properties and to help with easily switching between awscli named profiles. I add these functions to my .bashrc file so that I can easily call them from the command line.

The script "stop_start_ec2.sh" can be used to easily stop and then start instances from the command line.

## FAQ

### Do these work on Linux?

Definitely. I developed these on a notebook running Fedora, under bash. 

### Do these work on Windows?

Yes! You can install the aws-cli on Windows and these scripts have been tested to work on both cygwin and Windows Subsystem for Linux.

### Do these work on Mac?

Yes, mostly. Some of these functions leverage "grep -P", which is the PCRE (Perl Compatible Regular Expression) mode available in GNU grep. Unfortunately, this parameter and mode is not available on POSIX/Unix grep, which MacOS uses. If there is a more cross-compatible way to accomplish the same functionality that these functions provide, I'd love to hear about it! Pull Requests welcome!
