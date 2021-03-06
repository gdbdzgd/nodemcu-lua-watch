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
    if (data:find("stat=on" )) then
        set_gas_on()
        print("set gas on")
        response[#response + 1] = "Content-Type: text/html\r\n\r\n"
        response[#response + 1] = "<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"></head>"
        response[#response + 1] = '<script language="javascript">'
        response[#response + 1] = 'document.location = "http://'
        response[#response + 1] = hostip
        response[#response + 1] = '";'
        response[#response + 1] = '</script>'
    elseif (data:find("stat=off" )) then
        set_gas_off()
        print("set gas off")
        response[#response + 1] = "Content-Type: text/html\r\n\r\n"
        response[#response + 1] = "<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"></head>"
        response[#response + 1] = '<script language="javascript">'
        response[#response + 1] = 'document.location = "http://'
        response[#response + 1] = hostip
        response[#response + 1] = '";'
        response[#response + 1] = '</script>'
    else
        response[#response + 1] = "Content-Type: text/html\r\n\r\n"
        response[#response + 1] = "<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"></head>"
        response[#response + 1] = "<body><h1>日期："
        response[#response + 1] = date
        response[#response + 1] = "</h1><h1>时间："
        response[#response + 1] = time
        response[#response + 1] = '</h1><h1>温度：'
        response[#response + 1] = Temp
        response[#response + 1] = '</h1><h1>湿度：'
        response[#response + 1] = Humidity
        response[#response + 1] = '</h1><h1>状态：'
        response[#response + 1] = gas_sta
        response[#response + 1] = '</h1><h1>设定温度：'
        response[#response + 1] = temp_set
        response[#response + 1] = '</h1>'
        response[#response + 1] = '<form action=\"/\"> 温度设定: <input type=\"number\" name=\"tem_set\" /><br/>'
        response[#response + 1] = '壁挂炉开关:<select name="stat"> '
        response[#response + 1] = '<option value="null"></option>'
        response[#response + 1] = '<option value="on"  >开</option>'
        response[#response + 1] = '<option value="off" >关</option> </select><br/>'
        response[#response + 1] = '温度设定是否生效:<select name="temp_set_effect"> '
        response[#response + 1] = '<option value="null"></option>'
        response[#response + 1] = '<option value="on"  >生效</option>'
        response[#response + 1] = '<option value="off" >不生效</option> </select><br/>'
        response[#response + 1] = '<input type="submit" value="确定" /> </form>'
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

