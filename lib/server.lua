local message = require "bluenet.lib.message"

local Server = {
    mt = {
        __name = "bluenet.server",
    }
}
---@param name string
---@param protocol string
---@param handle function
---@param timeout number?
---@return Server
function Server.new(name, protocol, handle, timeout)
    ---@class Server
    return setmetatable({
        name = name,
        protocol = protocol,
        handle = handle,
        timeout = timeout or 10,

        open = Server.open,
        listen = Server.listen,
        close = Server.close,
    }, Server.mt)
end
---@param self Server
function Server:open()
    rednet.host(self.protocol, self.name)
end
---@param self Server
function Server:listen()
    while true do
        local id, msg = message.accept(self.protocol, self.timeout)
        if id and msg then
            local exit = self.handle(id, msg)
            if exit then break end
        end
    end
end
---@param self Server
function Server:close()
    rednet.unhost(self.protocol, self.name)
end