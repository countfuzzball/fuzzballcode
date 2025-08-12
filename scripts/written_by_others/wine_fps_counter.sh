#Requires xosd (xosd-bin)
WINEDEBUG=+fps wine nwmain.exe 2>&1 | tee /dev/stderr | \
    grep --line-buffered "^trace:fps:" | osd_cat --lines="2"
