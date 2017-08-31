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
  c,r=[150,50],20
  puts "OVAL, #AAA, #FEE, 3, #{c[0]} / #{c[1]}, #{r*1.2}"
  draw(c,r,"#AAB",0.5,1.0*((h+(m/60.0))%12)/12.0)
  draw(c,r,"#ABA",0.8,1.0*((m+s/60.0)/60.0))
  draw(c,r,"#BAA",1.0,1.0*s/60.0)
  puts "OVAL, #AAA, #AAA, 1, #{c[0]} / #{c[1]}, 3"
  #puts "POS, 130, 80, #{h}:#{m}:#{s}"
end 

puts "CLEAR"
puts "POS, 40 / 40 /// Hello ! "
puts "PLINE, #888, #888, 10, 0, 50, 200, 50"
puts "END"
$stdout.flush
sleep 3
hh=0
loop {
  puts "CLEAR"
  puts "RECT, #CCC, #CCC, 0 , 0 / 0 , 200  / 100"
  hh= (hh + 1) % 100
  puts "PLINE, #888, #888, 10, 0 / #{hh}, 200 / #{hh}, 200 / #{hh+10}, 0 / #{hh+10}"
  puts "POS, 10 / 15 /// Date: #{Time.now.to_s.split(/ /)[1]}"
  puts "POS, 10 / 30 /// ls: #{Dir.glob("*").size}"
  puts "END"
  clock()
  $stdout.flush
  sleep 1
}
