--- Helper module (util functions)
helpers = {}

--- Returns a random item in tbl
function helpers.random(tbl)
    i = math.floor(math.random(1, #tbl))
    return tbl[i]
end
