local function each_word(f, s, ...)
    local n = 0
    for w in s:gmatch("%S+") do
        n = n + 1
        f(w, ...)
    end
    return n
end

local function between(value, min, max)
    return value >= min and value <= max
end

local function inside(v, a, ...)
    if v == a then return true end

    if ... == nil then return false
    else return inside(v, ...)
    end
end

local function add_rule(specifier, f, t)
    t[specifier] = f
end

local out = {}

local pluralization = setmetatable({}, {__newindex = function(_, k, v)
    each_word(add_rule, k, v, out)
end})


local function f1(n)
    return n == 1 and "one" or "other"
end

pluralization["\
  af asa bem bez bg bn brx ca cgg chr da de dv ee el\
  en eo es et eu fi fo fur fy gl gsw gu ha haw he is\
  it jmc kaj kcg kk kl ksb ku lb lg mas ml mn mr nah\
  nb nd ne nl nn no nr ny nyn om or pa pap ps pt rm \
  rof rwk saq seh sn so sq ss ssy st sv sw syr ta te\
  teo tig tk tn ts ur ve vun wae xh xog zu          \
"] = f1


local function f2(n)
    return (n == 0 or n == 1) and "one" or "other"
end

pluralization["ak am bh fil guw hi ln mg nso ti tl wa"] = f2


local named = {[0] = 'zero', [1] = 'one', [2] = 'two'}

local function f3(n)
    if not math.tointeger(n) then return 'other' end

    local name = named[n]
    local n_100 = n % 100

    if name then
        return name
    elseif between(n_100, 3, 10) then
        return 'few'
    elseif between(n_100, 11, 99) then
        return 'many'
    else
        return 'other'
    end
end

pluralization.ar = f3


pluralization["\
  az bm bo dz fa hu id ig ii ja jv ka kde kea km kn\
  ko lo ms my root sah ses sg th to tr vi wo yo zh\
"] = function () return 'other' end


local function f5(n)
    if not math.tointeger(n) then return 'other' end
    local n_10, n_100 = n % 10, n % 100

    if n_10 == 1 and n_100 == 11 then
        return 'one'
    elseif between(n_10, 2, 4) and not between(n_100, 12, 14) then
        return 'few'
    elseif n_10 == 0 or between(n_10, 5, 9) or between(n_100, 11, 14) then
        return 'many'
    else
        return 'other'
    end
end

pluralization["be bs hr ru sh sr uk"] = f5


local function f6(n)
    if not math.tointeger(n) then return 'other' end
    local n_10, n_100 = n % 10, n % 100

    if n_10 == 1 and not inside(n_100, 11,71,91) then
        return 'one'
    elseif n_10 == 2 and not inside(n_100, 12,72,92) then
        return 'two'
    elseif inside(n_10, 3,4,9)
        and (not between(n_100, 10, 19))
        and (not between(n_100, 70, 79))
        and (not between(n_100, 90, 99))
    then
        return 'few'
    elseif n ~= 0 and n % 1000000 == 0 then
        return 'many'
    else
        return 'other'
    end
end

pluralization.br = f6


local function f7(n)
    if n == 1 then
        return 'one'
    elseif n == 2 or n == 3 or n == 4 then
        return 'few'
    else
        return 'other'
    end
end

pluralization["cz sk"] = f7


local named2 = {
    [0] = 'zero',
    [1] = 'one',
    [2] = 'two',
    [3] = 'few',
    [6] = 'many',
}

local function f8(n)
    return named2[n] or 'other'
end

pluralization.cy = f8


local function f9(n)
    return (n >= 0 and n < 2 and 'one') or 'other'
end

pluralization["ff fr kab"] = f9


local named3 = {
    [1]  = 'one',
    [2]  = 'two',
    [3]  = 'few',
    [4]  = 'few',
    [5]  = 'few',
    [6]  = 'few',
    [7]  = 'many',
    [8]  = 'many',
    [9]  = 'many',
    [10] = 'many',
}

local function f10(n)
    return named3[n] or 'other'
end

pluralization.ga = f10


local named4 = {
    [1]  = 'one',
    [11] = 'one',
    [2]  = 'two',
    [12] = 'two',
}

local function f11(n)
    local name = named4[n]

    if name then
        return name
    elseif math.tointeger(n) and (between(n, 3, 10) or between(n, 13, 19)) then
        return 'few'
    else
        return 'other'
    end
end

pluralization.gd = f11


local function f12(n)
    local n_10 = n % 10

    if n_10 == 1 or n_10 == 2 or n % 20 == 0 then
        return 'one'
    else
        return 'other'
    end
end

pluralization.gv = f12


local named5 = {'one', 'two'}

local function f13(n)
    return named5[n] or 'other'
end

pluralization["iu kw naq se sma smi smj smn sms"] = f13


local named6 = {[0] = 'zero', 'one'}

local function f14(n)
    return named6[n] or 'other'
end

pluralization.ksh = f14


local function f15(n)
    if n == 0 then
        return 'zero'
    elseif 0 < n and n < 2 then
        return 'one'
    else
        return 'other'
    end
end

pluralization.lag = f15


local function f16(n)
    if (not math.tointeger(n)) or between(n % 100, 11, 19) then return 'other' end

    local n_10 = n % 10

    if n_10 == 1 then
        return 'one'
    elseif between(n_10, 2, 9) then
        return 'few'
    else
        return 'other'
    end
end

pluralization.lt = f16


local function f17(n)
    if n == 0 then
        return 'zero'
    elseif n % 10 == 1 and n % 100 ~= 11 then
        return 'one'
    else
        return 'other'
    end
end

pluralization.lv = f17


local function f18(n)
    if n % 10 == 1 and n ~= 11 then
        return 'one'
    else
        return 'other'
    end
end

pluralization.mk = f18


local function f19(n)
    if n == 1 then
        return 'one'
    elseif n == 0 or (n ~= 1 and math.tointeger(n) and between(n % 100, 1, 19)) then
        return 'few'
    else
        return 'other'
    end
end

pluralization["mo ro"] = f19


local function f20(n)
    if n == 1 then return 'one' end
    if not math.tointeger(n) then return 'other' end

    local n_100 = n % 100

    if n == 0 or between(n_100, 2, 10) then
        return 'few'
    elseif between(n_100, 11, 19) then
        return 'many'
    else
        return 'other'
    end
end

pluralization.mt = f20


local function f21(n)
    if n == 1 then return 'one' end
    if not math.tointeger(n) then return 'other' end

    local n_10, n_100 = n % 10, n % 100

    if between(n_10, 2, 4) and not between(n_100, 12, 14) then
        return 'few'
    elseif n_10 == 0 or n_10 == 1 or between(n_10, 5, 9) or between(n_100, 12, 14) then
        return 'many'
    else
        return 'other'
    end
end

pluralization.pl = f21


local function f22(n)
    return (n == 0 or n == 1) and 'one' or 'other'
end

pluralization.shi = f22


local named7 = {'one', 'two', 'few', 'few'}

local function f23(n)
    return named7[n % 100] or 'other'
end

pluralization.sl = f23


local function f24(n)
    if math.tointeger(n) and (n == 0 or n == 1 or between(n, 11, 99)) then
        return 'one'
    else
        return 'other'
    end
end

pluralization.tzm = f24

return out