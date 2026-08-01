local component = require("component")
local event = require("event")
local term = require("term")

if not component.isAvailable("modem") then
    error("This program requires network card!")
end
local modem = component.modem

term.clear()
print("--- OpenPing V1.0 ---")
print(" ")

-- Port bekérése
io.write("Port?: ")
local port = tonumber(io.read())

if not port or port < 1 or port > 65535 then
    error("Wrong port!")
end

modem.open(port)
if not modem.isOpen(port) then
    error("Can't open port!")
end

local function generateRandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local str = ""
    for i = 1, length do
        local r = math.random(1, #chars)
        str = str .. chars:sub(r, r)
    end
    return str
end

local sentMessage = generateRandomString(16)
print("Küldendő teszt szöveg: " .. sentMessage)
print("Csomag küldése...")

local startTime = computer.uptime()
modem.broadcast(port, sentMessage)


while true do
    local evt, _, _, msgPort, _, receivedMessage = event.pull(5, "modem_message")
    
    if not evt then
        print("Timeout")
        break
    end
    
    if msgPort == port then
        local endTime = computer.uptime()
        local elapsedTime = (endTime - startTime) * 1000
        
        print("\n--- Package is recived ---")
        print(string.format("Ping: %.2f ms", elapsedTime))
        
        if not tostring(receivedMessage) == sentMessage then
            print("Package is corrupted!")
            print("Sended: " .. sentMessage)
            print("Recived:  " .. tostring(receivedMessage))
        end
        
        break 
    end
end

modem.close(port)
