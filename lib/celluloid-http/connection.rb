class Celluloid::Http::Connection
  include Celluloid::IO
  attr_reader :socket

  def open(host, port = 80, ssl = false)
    @socket ||= begin
      socket = TCPSocket.new(host, port)

      if ssl
        ssl_context = OpenSSL::SSL::SSLContext.new(:TLSv1_2_client)
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
        ssl_context.ca_file = ENV['SSL_CERT_FILE'] || OpenSSL::X509::DEFAULT_CERT_FILE

        socket = SSLSocket.new(socket, ssl_context)
        socket.connect
      end

      socket
    end
  end

  def close
    socket.close
    terminate
  end

  def send_request(request)
    socket.write(request.to_s)
  end

  def response
    response = Http::Response.new

    until response.finished?
      begin
        chunk = socket.readpartial(4096)
      rescue EOFError
        # do nothing
      ensure
        response << chunk if chunk
      end
    end

    response
  end

  def self.open(host, port = 80, ssl = false)
    connection = self.new
    connection.open(host, port, ssl)
    connection
  end

end
