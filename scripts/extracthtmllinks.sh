#!/bin/bash
#One-liner to extract links from chrome bookmark exports
#use: extracthtmllinks.sh <filename>

sed s/^.*A\ HREF=\"//g $i | sed s/\"\ ADD.*//g
