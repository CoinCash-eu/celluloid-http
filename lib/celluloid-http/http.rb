module Celluloid::Http::Http

  def send_requst(request)
    connection = Celluloid::Http::Connection.open(request.host, request.port)
    connection.send_request request

    response = connection.response
    connection.close
    response
  end

end