Presentation
============

Sometime, a distant host has  little environment
* with TCP/IP
* without any Xorg, graphics display, graphics libraries

For this cases, displaying some graphics (text/vector/raster) from distant host is not easy. Tipical case are :

* embeded Linux with little memory : Omega2, Linkit Smart, Arduino Yun...
* router on OpenWrt
* Cloud Server without any remote display.





This tool offer a basic solution:

* a client, connect to host (ssh or tcp)
* if ssh, it run a distant program (shell script or others)
* this program print on STDOUT some lines of text which are vector graphics order
* client show the resulting graph one the (gtk) display.

Here a example of clock display (code in ```srv_clock.rb```) client show :

![clock](https://user-images.githubusercontent.com/27629/29925133-a7c12f2c-8e5f-11e7-8c92-7f6125610dbb.png)


Pros/Cons
+ very light , serveur-side and client-side
- very limited, http/canvas are more powerful


Usage
======
Usage:
```ruby
   >ruby client.rb ip-host user  pass|noport  ssh|tcp|local   command...
```

Exemples :
```sh
   ruby client.rb 192.168.0.1 root 1234 ssh ruby srv_clock.rb 22
   ruby client.rb ab.net root 1234 ssh ruby -e "'$stdout.sync=true;loop {puts "CLEAR;POS,0,20///# {Time.now};END" ;sleep 3}'"
   ruby client.rb ab.net root 8787 tcp -
```



For TCP usage, server can be run with ```netcat``` :

```shell
 nc  -kl 8787 -c ./srv.sh
```


In Ruby, server TCP can use ```gserver``` gem, or minitcp :

```ruby
MServer.service(8787,"0.0.0.0",22) do |socket|
  socket.on_timer(1000) do
     socket.write "CLEAR;POS, 1/20 /// Free Disk=> #{`df -h | grep tmp | head -1`};END"
  end
  socket.wait_end
end
sleep
```

Vector graphic Langage
=====
line is splited with /\s+[,/]\s+/.
usage is to use ',' for all, except for x/y point or w/h size, in these case, use '/'.

so:
DDDD/1,2,3
is same as :
DDDD,2, 1/3
or
DDDD, 2/1/3


```
  echo "CLEARBG"                            # start backgound vector list
  DIM w / h                                 # set dimensiion of client drawing area
  ....                                      # use pos/rect/pline/poly/ova
  echo "ENDBG"                              # end of background list (no refresh!)

  echo "CLEAR"                              # start vector list
  echo "POS,x/y /// Date: $(date)"          # text at x/y position (size nd color can(t be specified!)
  echo "RECT,#00F, #F00, 0, x/y, w/h"       # horizontal rectangle : (bgcolor fgcolor border-width)  x y w h
  echo "PLINE, #888, #888, 10, 0/50, 200/50, 200/60, 0/60" # poly-line: bgcolor fgcolor border-width x y x y...
  eco  "POLYG,#888, #888, 10, 0/50, 200/50, 200/60, 0/60" #  plygone  : bgcolor fgcolor border-width x y x y...
  echo "OVAL, #888, #888, 10, 0/50, 200"    # circle : bgcolor fgcolor border-width x-center y-center r

######   echo "END"                                #  end of list , refresh
```


At 'END' commande, refresh do a redraw of backdround layout AND THEN foreground layout.
So backgound can be a  heavy vectored (a svg export should be done...) , and forground show only varying vector.

Example : output of srv_clock.rb :
---

```
CLEARBG
RECT, #CCC, #CCC, 0 , 0 / 0 , 200  / 100
PLINE, #888, #888, 10, 0 / 70, 200 / 70, 200 / 80, 0 / 80
OVAL, #AAA, #FEE, 3, 150.0 / 50.0, 30.3
OVAL, #AAA, #AAA, 1, 150.0 / 50.0, 3
PLINE, #AAA, #AAA, 1, 152.82226850822664 / 23.14790882505662, 153.1358538980296 / 20.1643431389518
.... graduations drawing...
PLINE, #AAA, #AAA, 3, 150.0 / 26.0, 150.0 / 20.0
ENDBG

CLEAR
POS, 10 / 15 /// Date: 16:43:48
POS, 10 / 30 /// ls: 49
PLINE, #AAB, #AAB, 2, 150.0 / 50.0, 159.3377195495643 / 61.7391223527862
PLINE, #ABA, #ABA, 2, 150.0 / 50.0, 126.18924716845254 / 53.007997605543295
PLINE, #BAA, #BAA, 2, 150.0 / 50.0, 121.46830451114539 / 40.72949016875159
END
CLEAR
POS, 10 / 15 /// Date: 16:43:49
POS, 10 / 30 /// ls: 49
PLINE, #AAB, #AAB, 2, 150.0 / 50.0, 159.3377195495643 / 61.7391223527862
PLINE, #ABA, #ABA, 2, 150.0 / 50.0, 126.18403349074828 / 52.96643544177182
PLINE, #BAA, #BAA, 2, 150.0 / 50.0, 122.59363627072197 / 37.79790070772599
```


Examples of server programs
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


TODO
====

* [x] Force size of client drawing area
* [x] 2 layers : one static, at startup, other dynamic
* [ ] Text with style : font, size, emphasis...
* [ ] Raster image (?)
* [ ] scp integration : copy script to server before execution (?)
* [ ] test unit
* [ ] a gem (?)

License
=======
This project is licensed under the terms of the MIT license.

