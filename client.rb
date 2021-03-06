#########################################################################################
# netvector: client.rb : prototype of 'client' sshvector (POC, so => ruby  ; could be .net/Qt/java)
#      Establish a ssh (or tcp or local-exec) connection, 
#      Run a very simple serveur prog ; get STDOUT of this prog.
#      Manage graphique interface with this stdout
#
# Here a ssh/Gtk version.
# Could be done with electron/canvas...
#
# send on stdout      : vector order
# receive on stdinput : mouse events and keyboard keys
# 
#    serveur <>-login--ssh ----- <<  ---- ssh-client--- <> sshvector:client ---<> screen
#
# > ruby client.rb 10.203.76.202 actemium 8787  tcp ruby ./srv.rb
# > ruby client.rb 10.203.76.202 actemium pass  ssh ./srv.sh
# > ruby client.rb -             -        -     local ./srv.sh
# 
#-----------------------------------------------------------------------------------------
# 
#  Syntaxe of client graphique order :
#    fields must be separated by ',' or '/' ; special separator for text POS command: ///
#    END order grapic sequence, do refresh on client side
#    CLEAR reset the list of vector, on client side
#
#  echo "CLEARBG"                            # start backgound vector list
#  echo "CLEAR"                              # start vector list
#  echo "POS,10/15 /// Date: $(date)"        # x/y position , texte
#  echo "RECT,#CCC, #CCC, 0, 0/0, 200/100"   # bgcolor fgcolor border-width x y w h
#  echo "PLINE, #888, #888, 10, 0/50, 200/50, 200/60, 0/60" # ; bgcolor fgcolor border-width x y x y...
#  echo "POLYG, #888, #888, 10, 0/50, 200/50, 200/60, 0/60" # ; bgcolor fgcolor border-width x y x y...
#  echo "OVAL, #888, #888, 10, 0/50, 200"    # ; bgcolor fgcolor border-width x-center y-center r
#  echo "END"                                #  end of list , refresh
#  echo "ENDBG"                              #  end of background list
# 
##########################################################################################

if  ARGV.size<5
 puts "Usage:  \n   >ruby #{$0} [-d] ip-host      user pass|noport ssh|tcp|local command..."
 puts "Exemple:\n   >ruby #{$0}      192.168.0.1 root 1234 ssh ruby srv_clock.rb 22"
 puts %{   >ruby client.rb ab root 1234 ssh ruby -e "'$stdout.sync=true;loop {puts \"CLEAR;POS,0,20///# {Time.now};END\" ;sleep 3}'"}

 exit(1)
end

require 'Ruiby'
require 'minitcp'
require_relative  'utils'

$host= ARGV[0]
$user=ARGV[1]
$passwd= ARGV[2] 
$PROTO= ARGV[3]
$port=$passwd.to_i if $PROTO=="tcp"
$cmd=ARGV[4..-1].join(" ")

class SSHClient
  def initialize(app)
    @app=app
    @lvect=[[],[]]
    @nolayout=nil
  end
  ################## Net
  def connect()
    ici=self
    case $PROTO
      when "ssh" then Thread.new {loop { ssh_pipe_out($host,$user,$passwd,$cmd,self) ; sleep 10} }
      when "local" then Thread.new { loop { local_exec($cmd,self) ;sleep 1 } }
      when "tcp" 
        MClient.run_continious($host,$port.to_i,20) do |socket| 
          gui_invoke { ici.net_connected(1) }
          socket.on_receive_sep("\n") {|data| gui_invoke { ici.net_receive_data(data.chomp) } }
          socket.wait_end
          gui_invoke { ici.net_deconnected() }
        end
    else
      raise("unknonwn protocole : #{$PROTO}")
    end
  end
  def net_connected(channel) 
    @lvect=[[],[]]
    @nolayout=nil
    @app.set_label("Connected") 
  end
  
  def net_deconnected() 
    @app.set_label("Deconnected !") 
    ici=self
    @app.after(1000) { ici.reset    }
  end
  def reset()
    @lvect=[[],[]]
    @nolayout=nil
    $app.update
  end
  def net_receive_data(data0)
    data0.split(/\n|;/).each do |data|  
      data.strip!
      txt=nil
      data,txt=data.split(%r{\s*///\s*},2) if data[0,3]=="POS"
      cmd,*params=data.chomp.split(%r{\s*[,/]\s*})
      puts data if $DEBUG
      case(cmd)
        when "CLEARBG" 
          @nolayout=0
          @lvect[@nolayout]= []
        when "CLEAR" 
          @nolayout=1
          @lvect[@nolayout]= []
        when "DIM"   then (gui_invoke {@app.set_size(params[0].to_i,params[1].to_i) }) if @layout==0
        when "FONT"   then @lvect[@nolayout] << [:font,{size: params[0].to_i, name: params[1], fg: params[2]}]
        when "POS"   then @lvect[@nolayout] << [:pos,{x: params[0].to_i, y: params[1].to_i,t: (txt || params[2])}]
        when "RECT"  then @lvect[@nolayout] << [:rect,{x: params[3].to_i,y: params[4].to_i,w: params[5].to_i,h: params[6].to_i,cfg:params[0],cbg: params[1],ep: params[2].to_i}]
        when "OVAL"  then @lvect[@nolayout] << [:oval,{cfg:params[0],cbg: params[1],ep: params[2].to_i,x: params[3].to_i,y: params[4].to_i,r: params[5].to_i}]
        when "PLINE"  then @lvect[@nolayout] << [:plin,{cfg:params[0],cbg: params[1],ep: params[2].to_i,lxy:params[3..-1].map {|a|a.to_i}}]
        when "POLYG"  then @lvect[@nolayout] << [:polyg,{cfg:params[0],cbg: params[1],ep: params[2].to_i,lxy:params[3..-1].map {|a|a.to_i}}]
        when "ENDBG"   then @nolayout=1
        when "END"   then @app.update
        else
            puts "unknown line : #{data.inspect}"
            @lvect[@nolayout]=[] if @lvect[@nolayout].size>20 
            @lvect[@nolayout] << [:pos,{x: 50, y: (@lvect[@nolayout] .size+1)*10,t: "???>" + data}]
            @app.update
      end
    end  
    p @lvect if $DEBUG
  rescue
    @nolayout=1 unless @nolayout
    @lvect[@nolayout]=[] if @lvect[@nolayout].size>30 
    @lvect[@nolayout] << [:pos,{x: 0, y: (@lvect[@nolayout].size+1)*10,t: "   >" + $!.to_s}]
    @lvect[@nolayout] << [:pos,{x: 0, y: (@lvect[@nolayout].size+1)*10,t: "???>" + data}]
    @app.update
    puts $!
  end
  
  #################  Draw
  def redraw(w,cr)
    return unless @lvect.size>0 || @lvect[0].size+@lvect[1].size==0
    fg=nil
    @app.ctx_font(cr,"Courier new bold 12",12)
    @lvect.each do |layout| layout.each do |(cmd,h)|
      begin
        case(cmd)
          when :font
              size= h[:size]
              name= h[:name]
              fg=h[:fg]
              @app.ctx_font(cr,name,size)
          when :pos then w.draw_text(h[:x],h[:y],h[:t],1,fg || "#044")
          when :rect then w.draw_rectangle(h[:x],h[:y],h[:w],h[:h],h[:ep],h[:cbg],h[:cfg])
          when :oval then w.draw_circle(h[:x],h[:y],h[:r],h[:cbg],h[:cfg],h[:ep])
          when :plin then w.draw_line(h[:lxy],h[:cfg],h[:ep])
          when :polyg then w.draw_polygon(h[:lxy],h[:cbg],h[:cfg],h[:ep])
          else
            puts "unknown vector type: #{cmd}"
        end
      rescue
        puts "#{cmd}: Error #{$!} :\n       #{h}"
      end
    end end
  end
  def mouse_release(w,x,y,e) 
  end
end

##########################################################################################
#                                  M A I N 
##########################################################################################
module Ruiby_dsl
  def set_label(t) @lab.text=t end
  def update() @cv.redraw end
  def ctx_font(cr,name,size)
    fd=Pango::FontDescription.new(name)
    cr.select_font_face(fd.family, Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_NORMAL)
    cr.set_font_size(size)
  end
end
unless defined?($first)
Ruiby.app width:200, height:250, title: "S" do
  move(100,200)
  @cli= SSHClient.new(self)
  @chrome=true
  stack do
    flowi { @lab=label(" <status>  ")  }
    @cv=canvas(100,20) {
      on_canvas_draw { |w,ctx| @cli.redraw(w,ctx) }
      on_canvas_button_release {|w,e,o| @cli.mouse_release(w,e.x,e.y,e) }
      #on_canvas_keypress {|w,key| @cli.keyboard(w,k) }
    }
  end
  after(10) { @cli.connect() }
end
$first=true
end