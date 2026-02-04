local M = {}

M.fonts = {}

M.fonts.LEXIPA = function(size) local v =  love.graphics.newFont('src/assets/fonts/LEXIPA.ttf', size or 12) v:setFilter('nearest', 'nearest') return v end

return M