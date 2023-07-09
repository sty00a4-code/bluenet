local Message = {
    mt = {
        __name = "bluenet.message"
    }
}
---@param author integer
---@param target integer
---@param protocol string
---@param data any
---@return bluenet.message
function Message.new(author, target, protocol, data)
    ---@class bluenet.message
    return setmetatable({
        author = author,
        target = target,
        protocol = protocol,
        data = data
    }, Message.mt)
end
---@param t any
---@return bluenet.message?
function Message.from(t)
    if type(t) ~= "table" then return end
    if type(t.author) ~= "number" then return end
    if type(t.target) ~= "number" then return end
    if type(t.protocol) ~= "string" then return end
    return Message.new(t.author, t.target, t.protocol, t.data)
end
---@param self bluenet.message
function Message:tostring()
    return ("message(author: %q, target: %q, protocol: %q, data: %q)"):format(self.author, self.target, self.protocol, self.data)
end
Message.mt.__tostring = Message.tostring

---@param target integer
---@param data any
---@param protocol string
---@param author integer?
local function send(target, data, protocol, author)
    ---@diagnostic disable-next-line: undefined-field
    author = author or os.getComputerID()
    local msg = Message.new(author, target, protocol, data)
    rednet.broadcast(msg, "bluenet")
end
---@param author integer
---@param protocol string
---@param timeout number?
---@return bluenet.message?
local function receive(author, protocol, timeout)
    ---@type number
    local start_time = os.time()
    local id, msg
    while id ~= author do
        local enter_time = os.time()
        if enter_time - start_time > timeout then break end
        id, msg = rednet.receive("bluenet", timeout - (enter_time - start_time))
        if type(id) == "nil" then break end
    end
    return Message.from(msg)
end

return {
    Message = Message,
    send = send,
    receive = receive
}