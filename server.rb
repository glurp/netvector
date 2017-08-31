#########################################################################################
# sshvector: server.rb : prototype of 'serveur' sshvecor
# should be run as programme connection (ssh or telnet or tcp)
#
# send on stdout      : vector odrder
# receive on stdinput : mouse events and keyboard keys
#
#    serveur <>-login--ssh ----- <<  ---- ssh-client--- <> sshvector:client ---<> screen
##########################################################################################
$t=ARGV.first || "pos" 
cc=0
loop {
  cc+=1
  puts "CLEAR"
  case $t
  when "ps"
  `ps -W`.each_line.to_a.reverse.each_with_index {|line,i|
    puts "POS, 0, #{i*14}/// #{line.chomp[0..120].gsub(', ','')}, #044" if i<10
  }
  when "pos"
    puts "POS, #{(cc*3)%100}, #{(cc*2)%100} /// X"
  when "bl"
    puts "RECT, #044, #FF0, 1, #{(cc*3)%100}, #{(cc*2)%100}, #{3+cc%20}, #{3+cc%20}"
    puts "OVAL, #044, #FF0, 1, 40, 50, #{3+cc%20}" 
    puts "PLINE, #044, #FF0, 1, #{(cc*7)%100}, #{(cc*7)%100}, #{100+cc%20}, #{100+cc%20}, 10, 100" 
    puts "POLYG, #044, #FF0, 1, #{(cc*11)%100}, #{(cc*23)%100}, #{10+cc%20}, #{100+cc%20}, 100, 10" 
  end
  $stdout.flush
  sleep $t=="ps" ? 3 : 0.05
}