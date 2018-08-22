#!/bin/sh
#
# Many things are hard-coded in this script
#
# If someone is interested in using it, even make it generic, I can help...
# But for now, I am not even sure anyone would wanna use it.

# Start cups
/etc/init.d/dbus start
/etc/init.d/avahi-daemon start
/etc/init.d/cups start
/etc/init.d/cups-browsed start

# check if the printer is already configured
lpstat -v 2>/dev/null | grep -q LexmarkCX510
if [ $? -ne 0 ]
then
    # Printer driver is not installed: do it
    printeruri=$(lpinfo -v | grep "Lexmark/CX510" | cut -d" " -f2)
    if [ "$printeruri" = "" ]
    then
        echo "Lexmark CX510 printer not detected"
    fi
    # Add the printer
    lpadmin -p LexmarkCX510 -E -v $printeruri -m lsb/usr/Lexmark_PPD/Lexmark_CX510_Series.ppd
    # My options...
    lpoptions -p LexmarkCX510 -o PageSize=A4
fi


# And finally, start SANE in a loop (so that the container doesn't stop if saned dies)
while true
do
    /usr/sbin/saned -d 2
    sleep 2
done
