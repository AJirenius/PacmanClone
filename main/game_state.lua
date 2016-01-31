local M = {}

M.STATE_START = 1
M.STATE_GAME_PLAY = 2
M.STATE_GAME_OVER = 3

local current_state = 1

function M.get_state()
	return current_state
end

function M.set_state(state)
	if state == current_state then return end
	current_state = state
	
	if state == M.STATE_GAME_PLAY then
	elseif state == M.STATE_GAME_PLAY then
	elseif state == M.STATE_GAME_OVER then
	end
end

return M



