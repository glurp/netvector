####################################################################################
#  srv_clock.rb : demo for  client netvector
####################################################################################

$lmtime= File.mtime(__FILE__) ; Thread.new {loop { exit(0) if File.mtime(__FILE__)!=$lmtime; sleep 3}}

def draw(c,r,color,coef,ratio)
 a=(ratio+0.75)*2.0*Math::PI
 sin,cos= 1.0*r*coef*Math.sin(a), 1.0*r*coef*Math.cos(a)
 c1=[c[0]+cos,c[1]+sin]
 puts "PLINE, #{color}, #{color}, 2, #{c[0]} / #{c[1]}, #{c1[0]} / #{c1[1]}"
end
def clock()
  t=Time.now
  s,m,h=t.sec,t.min,t.hour
  c,r=[150.0,50.0],30.0
  draw(c,r,"#AAB",0.5,1.0*((h+(m/60.0))%12)/12.0)
  draw(c,r,"#ABA",0.8,1.0*((m+s/60.0)/60.0))
  draw(c,r,"#BAA",1.0,1.0*s/60.0)
  #puts "POS, 130, 80, #{h}:#{m}:#{s}"
end 
def clock_init()
  c,r=[150.0,50.0],30.0
  puts "OVAL, #AAA, #FEE, 3, #{c[0]} / #{c[1]}, #{r*1.01}"
  puts "OVAL, #AAA, #AAA, 1, #{c[0]} / #{c[1]}, 3"
  (1..60).each  do |t|
    a=((1.0*t/60.0)+0.75)*2.0*Math::PI
    q=((t%5)==0) 
    coef=(!q) ? 0.90 : 0.80
    sin,cos= 1.0*r*coef*Math.sin(a), 1.0*r*coef*Math.cos(a)
    c1=[c[0]+cos,c[1]+sin]

    coef=1.0
    sin,cos= 1.0*r*coef*Math.sin(a), 1.0*r*coef*Math.cos(a)
    c2=[c[0]+cos,c[1]+sin]
    color="#AAA"
    #puts "# #{t} #{a} "
    puts "PLINE, #{color}, #{color}, #{q ? 3 : 1}, #{c1[0]} / #{c1[1]}, #{c2[0]} / #{c2[1]}"
  end
end 

puts "CLEAR"
puts "DIM,  200  / 100"
puts "POS, 40 / 40 /// Hello ! "
puts "PLINE, #888, #888, 10, 0, 50, 200, 50"
puts "END"
$stdout.flush
sleep 0.1
hh=0
puts "CLEARBG"
puts "RECT, #CCC, #CCC, 0 , 0 / 0 , 200  / 100"
puts "PLINE, #888, #888, 10, 0 / 70, 200 / 70, 200 / 80, 0 / 80"
clock_init()
puts "ENDBG"
loop {
  puts "CLEAR"
  hh= (hh + 1) % 100
  puts "POS, 10 / 15 /// Date: #{Time.now.to_s.split(/ /)[1]}"
  puts "FONT, 10 , Arial , #033" 
  puts "POS, 10 / 30 /// ls: #{Dir.glob("*").size}"
  clock()
  puts "END"
  $stdout.flush
  sleep 1
}

