local PORT = 120
local modem = component.proxy(component.list("modem")())
modem.open(PORT)
while true do
  local signal = {computer.pullSignal()}
  if signal[1] == "modem_message" and signal[4] == PORT then
    modem.broadcast(PORT, signal[6])
  end
end
