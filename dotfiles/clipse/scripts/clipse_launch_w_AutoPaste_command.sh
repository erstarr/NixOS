#!/bin/bash




# Using BASH; run cliphist command from git. If i select something, return will be 0. in which case wait X seconds and paste by simuating a CTRL + V with wtype.  If i don't and exit (esc or Q), it will be 1, in which case simply exit
# -i is necessary
# -f in the second bash in there is 'fast', disables some features but it makes no difference anway with those commands
kitty --class clipse "bash" -ic '
clipse -enable-real-time
rc=$?
if [ "$rc" -eq 0 ]; then
    
    setsid bash -fc "sleep 0.7; wtype -M ctrl v -m ctrl" \
      </dev/null >/dev/null 2>&1 &
    
    exit
      
elif [ "$rc" -eq 1 ]; then
    exit
fi
'
exit
