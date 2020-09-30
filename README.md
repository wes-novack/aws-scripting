# aws-scripting

View the presentation video: https://www.youtube.com/watch?v=LG-_K4JIFRc&t=5s

Download the slide deck: https://goo.gl/Sabjue 

The file "functions.sh" is a collection of useful functions that can help you with querying for ec2 instance properties and to help with easily switching between awscli named profiles. I source this file in my .bashrc file so that I can easily call them from the command line.

The script `stop_start_ec2.sh` can be used to easily stop and then start instances from the command line.

The script `resize_ec2.sh` can be used to quickly resize an ec2 instance to a new instance type.

## FAQ

### Do these work on Linux?

Definitely. I orginally developed these on a notebook running Fedora, under bash. Since then, many others have contributed and run these scripts on various distributions, including Ubuntu and others.

### Do these work on Windows?

Yes! You can install the aws-cli on Windows and these scripts have been tested to work on both cygwin and Windows Subsystem for Linux.

### Do these work on Mac?

Yes!
