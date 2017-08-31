Presentation
============
Sometime, a distant host has  little envirronenent
* with TCP/IP
* without any Xorg, graphics display, graphics librairies

For this cases, diplaying some graphics (text/vector/raster) on dstant host is not easy.
This tool offer a basic solution:
* a client, connect to host (ssh or tcp)
* if ssh, it run a distant programme (shellscript or others)
* this programme print on STDOUT some lines of text which are vector graphics order
* client show the graph one the (gtk) display.



Usage
======
Usage:
```ruby
   >ruby client.rb ip-host      user pass|noport ssh|tcp|local command...
```

Exemples :
```sh
   ruby client.rb 192.168.0.1 root 1234 ssh ruby srv_clock.rb 22
   ruby client.rb ab root 1234 ssh ruby -e "'$stdout.sync=true;loop {puts "CLEAR;POS,0,20///# {Time.now};END" ;sleep 3}'"
```

For graphics 'language', see header of client.rb.

   
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

Here a clock display (code in ```srv_clock.rb```) client show :

![clock](https://user-images.githubusercontent.com/27629/29925133-a7c12f2c-8e5f-11e7-8c92-7f6125610dbb.png)


TODO
====

* [ ] force size of client drawing area
* [ ] text with style : font, size, emphasis...
* [ ] 2 layers : one static, at startup, other dynamic
* [ ] raster image (?)

License
=======
This project is licensed under the terms of the MIT license.
