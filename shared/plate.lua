---@param plate string?
---@return string?
local function normalizePlate(plate)
    if not plate or plate == '' then return end
    return qbx.string.trim(plate):upper()
end

return {
    normalizePlate = normalizePlate,
}
