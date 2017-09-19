require 'net/ssh'
require 'open3'


def local_exec(cmd,client) 
  Open3.popen3(cmd) do |fin,fout,ferr|
     gui_invoke { client.net_connected(1) }
     loop {
      line=fout.gets
      break unless line
      gui_invoke { client.net_receive_data(line.encode("UTF-8").chomp) }
     }
   end
  gui_invoke {  client.net_deconnected() }
end

def ssh_pipe_out(host,user,passwd,cmd,client) 
  puts "SSH start for ssh://#{user}:#{"*****"}@#{host}:#{cmd}"
  with_output=false
  is_connected=false
  puts "  Start ssh..." if with_output
  Net::SSH.start(host, user, :password => passwd) do |session|
    puts "  ssh Connected" if with_output
    session.open_channel do |channel|
      gui_invoke { client.net_connected(channel) }
      is_connected=true
      channel.exec(cmd) {
        channel.on_data do |ch, data|
          puts "  ssh_pipe data #{data}" if with_output
          gui_invoke { client.net_receive_data(data) }
        end
      }
      puts "  ssh_pipe execute..." if with_output
    end
    puts "  session loop..." if with_output
    session.loop
    puts "  end session loop" if with_output
  end
  gui_invoke {  client.net_deconnected() } if is_connected
  puts "  end ssh_pipe" if with_output
end

def decode(t)  t[/jlklkjlkj(.*?)kmlkmlkmlk/,1].reverse end
def encode(t)    "jlklkjlkj"+t.reverse+"kmlkmlkmlk"    end
