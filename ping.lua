local component = require("component")
local computer = require("computer")
local event = require("event")
local term = require("term")

if not component.isAvailable("modem") then
    error("This program requires network card!")
end
local modem = component.modem

term.clear()
print("--- OpenPing V1.0 ---")
print(" ")

io.write("Port?: ")
local port = tonumber(io.read())

if not port or port < 1 or port > 65535 then
    error("Wrong port!")
end

io.write("delay?: ")
local delay = tonumber(io.read())

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

while true do
local sentMessage = generateRandomString(16)
print("Sending packet: " .. sentMessage)

local startTime = computer.uptime()
modem.broadcast(port, sentMessage)

done = true
while done do
    local evt, _, _, msgPort, _, receivedMessage = event.pullMultiple(5, "modem_message", "key_down")
    
    if evt == "key_down" then
        modem.close(port)
        return
    end
    
    if not evt then
        print("Timeout")
        done = false
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
        
        done = false
    end
end

local delayStart = computer.uptime()
while computer.uptime() - delayStart < delay do
    local evt = event.pull(0.05, "key_down")
    if evt == "key_down" then
        modem.close(port)
        return
    end
end   
end
modem.close(port)
