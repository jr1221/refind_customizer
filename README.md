A CLI app for the rEFInd bootloader that can change your boot OS when the timer runs out.

## Install
Head over to releases and grab the binary, you can put it in your path if you want.

##Usage
`./rf-custom default`
````
Switch default OS to boot into if no user action taken during rEFInd timeout.

Usage: rf-custom default [arguments]
-h, --help                                         Print this usage information.
-n, --number                                       Default to the nth option in the menu (from left to right)
[1, 2, 3, 4, 5, 6, 7, 8, 9]
-s, --substring=<boot/vmlinuz-5.8.0-22-generic>    Default to the first matching string of any boot description, separate multiple strings by commas
-p, --efi-path=</boot/>                            Specify the path to the EFI directory, defaults to /boot/efi/
(defaults to "/boot/efi/")
-g, --get                                          Get the current selection configuration
-r, --remove-all                                   Remove all rules, previously booted OS will be default
````
### Boot into windows up next startup
`./rf-custom default -s Microsoft`

As seen above, the -s will allow rEFInd to match any description substring to a possible OS. 
Any part of the menu in rEFInd describing that boot option will help identify it.
It may take some experimenting to find the right string that works for your OSes.  
To restore select previously booted use the `-r` flag on `default`.  

#### Building from Source
Use dart2native from the dart SDK as such;
`dart2native bin/rf-custom.dart -o /path/to/binary/rf-custom`