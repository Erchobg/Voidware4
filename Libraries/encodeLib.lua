local encodeLib = {}
local lower = {
    a = '$',
    b = '|',
    c = '@',
    d = '*',
    e = '(',
    f = ')',
    g = '-',
    h = '>',
    i = '/',
    j = '+',
    k = '{',
    l = '}', 
    m = ']',
    n = '[',
    o = '!',
    p = '^',
    q = '=',
    r = '&',
    s = '~',
    t = '.',
    u = '?',
    v = '#',
    w = '`',
    x = ',',
    y = ':',
    z = ';'
}

encodeLib.encode = function(text)
    text = tostring(text) 
    for i = 1, #text do 
        local char = text:sub(i, i):lower()
        if lower[char] then 
            text = text:lower():gsub(char, lower[char])
        end
    end 
    return text
end

encodeLib.decode = function(text)
    local newtext = ''
    text = tostring(text)
    for i = 1, #text do
        local char = text:sub(i, i)
        local encrypted
        for i2, v in next, lower do 
            if v == char then 
                newtext = (newtext..(i2))
                encrypted = true
            end
        end 
        if not encrypted then 
            newtext = (newtext..(char)) 
        end
    end
    return newtext
end

return encodeLib
