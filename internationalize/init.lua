
local plurals     = require"internationalize.plural"
local interpolate = require"internationalize.interpolation".interpolate
local newstr      = require"internationalize.interpolation".new

local i18n_t = {__name = "internationalize"}
      i18n_t.__index = i18n_t

local function new(l) l = l or "en"
    return setmetatable({locale = l, fallback_locale = l, store = {}}, i18n_t)
end

local plural_table = {__name = "internationalize.plural-table"}

function plural_table:__i18n_plural()
    if not self[plural_table] then
        local var
        for _ , istr in pairs(self) do
            var = istr.plural_var
        end

        if var then self[plural_table] = var end

        for _ , istr in pairs(self) do
            if var and (istr.var ~= var) then
                var = 'count'
                break
            else
                var = istr.var
            end
        end

        if var then self[plural_table] = var
        else
            self[plural_table] = 'count'
        end
    end
    return self[plural_table]
end

local function paths(str)
    local chunks = {}
    local length = 0
    for chunk in str:gmatch"[^%.]+" do
        table.insert(chunks, chunk)
        length = length + 1
    end
    return chunks, length
end

local function rev(N, N_2, n, t)
    if n == N_2 then return t
    else
        t[n], t[N - n + 1] = t[N - n + 1], t[n]
        return rev(N , N_2, n - 1, t)
    end
end

local function locale_path(l)
    local out = { }
    local i = 1

    local iter = l:gmatch"[^%-]+"
    local component = iter()
    out[i] = component
    for chunk in iter do
        i = i + 1
        component = (component .."-"..chunk)
        out[i] = component
    end

    return i == 1 and out or rev(i, i//2, i, out), i
end

local function is_parent(parent, child)
    return not not child:find("^"..parent.."%-")
end

local function locale_root(l) return l:match"^[^%-]+" end

local function fallbacks(locale, fallback, strict)
    if locale == fallback or is_parent(fallback, locale) then
        return locale_path(locale)
    end

    if is_parent(locale, fallback) then
        return locale_path(fallback)
    end

    if not strict then
        local ancestry1, length1 = locale_path(locale)
        local ancestry2, length2 = locale_path(fallback)

        return table.move(ancestry2, 1, length2, length1+1, ancestry1), length1+length2
    else
        return locale_path(locale)
    end
end

i18n_t.fallbacks = fallbacks

local function pluralize(node, data, root, V) data = data or {}
    local plural_rule = plurals[root]

    local plural_form = plural_rule(data[V] or 1)

    return node[plural_form]
end

local function treat(node, data, root)
    local mt = getmetatable(node)
    if type(node) == 'string' then
        return node
    elseif mt and mt.__i18n_istr then
        return interpolate(node, data)
    elseif mt and mt.__i18n_plural then
        local pf = pluralize(node, data, root, mt.__i18n_plural(node))
        if getmetatable(pf).__i18n_istr then
            return interpolate(pf, data)
        else
            return pf
        end
    end
    return node
end

local function localized_translate(self, key, loc, data)
    local path, length = paths(loc:gsub("%-", ".") .. "." .. key)

    local node, k = self.store

    for i = 1, length do
        k = path[i]
        node = node[k]
        if not node then return nil end
    end

    return treat(node, data, locale_root(loc))
end


local EMPTY = {}
function i18n_t:translate(key, data, loc)
    data = data or EMPTY

    local locales, length = fallbacks(loc or data.locale or self.locale, self.fallback_locale, not not loc)

    for i = 1, length do
        local value = localized_translate(self, key, locales[i], data)
        if value then return value, locales[i] end
    end
    return data.default
end

function i18n_t:translations_of(key, data, ...)
    return self:translations_from(key, data, {...})
end

function i18n_t:translations_from(key, data, t)
    local locales = t
    local length = #t
    local out = {}
    for i = 1, length do
        local val, loc = self:translate(key, data, locales[i])
        if val then
            table.insert(out, {locales[i], val, loc})
        end
    end
    return out
end


function i18n_t:set(key, value)
    local path, length = paths((key:gsub("%-", ".")))

    local node, k = self.store

    for i = 1, length -1 do
        k = path[i]
        node[k] = node[k] or {}
        node = node[k]
    end

    print(key, path[length])

    if path[length] == 'other' then setmetatable(node, plural_table) end

    node[path[length]] = newstr(value)
end


local function recursive_load_back(self, current_context, N, data)
    current_context = current_context or {}
    N = N or 0
    for k,v in pairs(data) do
        local n = N + 1
        local myctx = table.move(current_context, 1, N, 1,  {})
        myctx[n] = tostring(k)
        if type(v) == 'string' then
            if n > 2 then
                self:set(table.concat(rev(n-2, (n-2)//2, n-2, rev(n-1, (n-1)//2, n-1, myctx)), "."), v)
            else
                self:set(table.concat(rev(n, n//2, n, myctx), "."), v)
            end
        else
            return recursive_load_back(self, myctx, n, v)
        end
    end
end

function i18n_t:set_all(data)
    recursive_load_back(self, nil, nil, data)
end


local function recursive_load(self, current_context, N, data)
    current_context = current_context or {}
    N = N or 0
    for k,v in pairs(data) do
        local n = N + 1
        local myctx = table.move(current_context, 1, N, 1,  {})
        myctx[n] = tostring(k)
        if type(v) == 'string' then
            self:set(table.concat(myctx, "."), v)
        else
            return recursive_load(self, myctx, n, v)
        end
    end
end

function i18n_t:load(data)
    recursive_load(self, nil, nil, data)
end


function i18n_t:set_locale(l, pf)
    self.locale = l
    if pf and not plurals[l] then
        plurals[l] = type(pf) == 'string' and plurals[pf] or pf
    end
end


function i18n_t:set_fallback_locale(l, pf)
    self.fallback_locale = l
    if pf and not plurals[l] then
        plurals[l] = type(pf) == 'string' and plurals[pf] or pf
    end
end

return new