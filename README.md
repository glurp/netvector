Presentation
============
Sometime, a distant host has  little envirronenent
* with TPP/IP
* without any X or graphics display

For this case, diplaying some graphics (text/vector/raster) is not easy.
This tool offer a basic solution:
* a client, connect to host (ssh or tcp)
* if ssh, it run a distant programme (shellscript or others)
* this programme print on his STDOUT some line of text which are vector graphics order
* client show the graph one his (gtk) display


Usage
======
Usage:
```ruby
   >ruby client.rb ip-host      user pass|noport ssh|tcp|local command...

Exemples :
```
   >ruby client.rb 192.168.0.1 root 1234 ssh ruby srv_clock.rb 22
   >ruby client.rb ab root 1234 ssh ruby -e "'$stdout.sync=true;loop {puts "CLEAR;POS,0,20///# {Time.now};END" ;sleep 3}'"
```
   
Exemples of server programs
========


```shell
#!/bin/bash
echo  "CLEAR"
echo "POS, 40 / 40 /// Hello ! "
echo "PLINE, #888, #888, 10, 0 / 50, 200 / 50"
sleep 3
while :; do 
  echo "CLEAR"
  echo "RECT, #CCC, #CCC, 0, 0 / 0, 200 / 100"
  echo "POS, 10 / 15 /// Date: $(date | awk ' {printf $4}')"
  echo "POS, 10 / 30 /// ls: $(ls -1 | wc -l)"
  echo "PLINE, #888, #888, 10, 0/50, 200/50, 200/60, 0/60"
  sleep 1
done
```

then, client show :

