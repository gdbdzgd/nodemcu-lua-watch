-- ChiliPeppr - Create webserver and host a web page

local w = {}

w.wifiSsid = "NETGEAR-main"
w.wifiPwd = "****"

w.callbackOn = nil
w.callbackOff = nil

function w.registerCallbackOn(f)
  w.callbackOn = f
end

function w.registerCallbackOff(f)
  w.callbackOff = f
end

function w.start()
  --register callback
 
  srv = net.createServer(net.TCP)

  srv:listen(80, function(conn)
    conn:on("receive", w.receiver)
  end)
  print("server started")
end

function w.receiver(sck, data)

  print("DATA: " .. data)
  
  -- local response = {}

  -- if you're sending back HTML over HTTP you'll want something like this instead
  local response = {"HTTP/1.0 200 OK\r\nServer: ChiliPeppr ESP32\r\n"}
  
  -- SEE IF DATA IS WANTING TO TURN ON ANYTHING
  if (data:find("^GET /on" )) then
    print("being asked to turn on fuel")
    response[#response + 1] = "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
    -- response[#response + 1] = "Turning on fuel"
    response[#response + 1] = '{"isFuelOn": true}'
    w.callbackOn()
  elseif (data:find("^GET /off" )) then
    print("being asked to turn off fuel")
    response[#response + 1] = "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
    -- response[#response + 1] = "Turning off fuel"
    response[#response + 1] = '{"isFuelOn": false}'
    w.callbackOff()
  else
    response[#response + 1] = "Content-Type: text/html\r\n\r\n"
    response[#response + 1] = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
    response[#response + 1] = "<body>日期："
    response[#response + 1] = date
    response[#response + 1] = "时间："
    response[#response + 1] = time
    response[#response + 1] = '温度：'
    response[#response + 1] = Temp
    response[#response + 1] = '湿度：'
    response[#response + 1] = Humidity
    
    response[#response + 1] = '</body>'
  end

  
  -- sends and removes the first element from the 'response' table
  local function send(localSocket)
    if #response > 0 then
      localSocket:send(table.remove(response, 1))
    else
      localSocket:close()
      response = nil
    end
  end

  -- triggers the send() function again once the first chunk of data was sent
  sck:on("sent", send)

  send(sck)
end

return w

