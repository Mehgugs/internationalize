local interp_t = {__i18n_istr = true}

function interp_t:__tostring()
    local out = {}
    for i = 1, #self do
        if type(self[i]) == 'string' then table.insert(out, self[i])
        else
            table.insert(out, "%{" .. self[i].key .. (self[i].modifier and (" " .. self[i].modifier) or "").."}")
        end
    end
    return table.concat(out)
end

local function interpolate(self, data)
    local out = {}
    for i = 1, #self do
        if type(self[i]) == 'string' then table.insert(out, self[i])
        else
            local interp = self[i]
            local value = data[interp.key]
            if interp.modifier then
                table.insert(out, interp.modifier:format(value))
            else
                table.insert(out, tostring(value))
            end
        end
    end
    return table.concat(out)
end

local PERCENT, OPEN_BRACE = ("%{"):byte(1, 2)


local function parse_modifier(s)
    if s:sub(1, 2) == "pl" then
        local rest = s:sub(3)
        if rest:sub(1, 1) == "." then rest = s:sub(4) end
        return true, "%" .. (rest ~= "" and rest or "s")
    else
        return false, "%"..s
    end
end

local function build_interp_string(s)
    local out, vars, plural_on = {}, {}
    local i = 1

    local cur

    while i <= #s do
        local A, B = s:byte(i,i+1)
        if A == PERCENT and B == OPEN_BRACE then
            if cur then
                table.insert(out, s:sub(cur[1], cur[2]))
                cur = nil
            end

            local st, e, key = s:find("^%s*([%a_][%w_]*)", i+2)

            if key then
                local interp = {key = key}
                table.insert(out, interp)
                table.insert(vars, key)

                local _, e_, modify = s:find("^%s*([^}]+)}", e + 1)

                if modify then e = e_;
                    local is_pl, fstr = parse_modifier(modify)
                    interp.modifier = fstr

                    if is_pl then
                        if plural_on then
                            return error("This interpolated string indicates its pluralization variable in multiple places @".."in "..("%q"):format(s))
                        end
                        plural_on = key
                    end
                end
            end

            _ , i = s:find("}", e, true)
            if not i then return error("Malformed interpolated string @"..(st -1).."in "..("%q"):format(s)) end
        else
            if cur then cur[2] = i
            else cur = {i, i}
            end
        end
        i = i + 1
    end

    if cur then
        if #out == 0 then
            return s:sub(cur[1], cur[2])
        else
            table.insert(out, s:sub(cur[1], cur[2]))
        end
    end

    if #vars == 1 then out.var = vars[1] end

    out.plural_var = plural_on
    return setmetatable(out, interp_t), plural_on
end

return {
    new = build_interp_string,
    interpolate = interpolate
}