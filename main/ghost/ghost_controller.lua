local M = {}

M.ghosts = {}

function M.add_ghost(id)
	table.insert( M.ghosts, id )
end

return M

