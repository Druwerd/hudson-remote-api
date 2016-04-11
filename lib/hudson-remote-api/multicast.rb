require 'socket'
require 'timeout'
require 'rexml/document'

module Hudson
  def self.discover(multicast_addr = "239.77.124.213", port=33848, timeout_limit=5)
    socket = UDPSocket.open
    socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [1].pack('i'))
    socket.send(ARGV.join(' '), 0, multicast_addr, port)
    msg = nil
    #msg, info = socket.recvfrom_nonblock(1024)
    Timeout.timeout(timeout_limit) do
      msg, info = socket.recvfrom(1024)
    end
    msg
  rescue Exception => e
    puts e
    nil
  ensure
    socket.close 
  end
end