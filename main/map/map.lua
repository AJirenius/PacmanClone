local ghost_controller = require "main.ghost.ghost_controller"

local M = {}

local TILE_SIZE = 8
local grid 
local tilemap_width
local tilemap_height
local tilemap_pos
local lookup = {{-1,1},{0,1},{1,1},{-1,0},{1,0},{-1,-1},{0,-1},{1,-1}}
local l_values = {1,2,4,8,16,32,64,128}


local tile_views = {}
tile_views[208] = 1
tile_views[248] = 2
tile_views[249] = 2
tile_views[252] = 2
tile_views[104] = 3
tile_views[254] = 4
tile_views[251] = 5
tile_views[214] = 7
tile_views[215] = 7
tile_views[246] = 7
tile_views[255] = 8
tile_views[107] = 9
tile_views[111] = 9
tile_views[235] = 9
tile_views[223] = 10
tile_views[127] = 11
tile_views[22] = 13
tile_views[31] = 14
tile_views[63] = 14
tile_views[159] = 14
tile_views[11] = 15


function M.is_valid_path(tile_coord)
	-- check boundaries
	if tile_coord.x > 0 and tile_coord.x < tilemap_width and tile_coord.y > 0 and tile_coord.y < tilemap_height then
		if grid[tile_coord.x][tile_coord.y].wall == false then
			return true
		end
	end
	return false
end

function M.get_grid_pos(screen_pos)
	local grid_pos = vmath.vector3(math.floor((screen_pos.x-tilemap_pos.x+TILE_SIZE*0.5)/TILE_SIZE), math.floor((screen_pos.y-tilemap_pos.y+TILE_SIZE*0.5)/TILE_SIZE), 0)
	return grid_pos
end

function M.get_screen_pos(grid_pos)
	local screen_pos = vmath.vector3((grid_pos.x-0.5)*TILE_SIZE+tilemap_pos.x, (grid_pos.y-0.5)*TILE_SIZE+tilemap_pos.y, 0)
	return screen_pos
end

function M.create_map()
	local url = msg.url("/level#level1")
	
	local startx, starty, width, height = tilemap.get_bounds(url)
	tilemap_width = width
	tilemap_height = height
	tilemap_pos = go.get_position("/level")
	grid = {}
	for x = 1,width do
		local column = {}
		for y = 1,height do
			local tile = tilemap.get_tile(url, "layer1", x, y)
			local t = {  }
			if tile == 8 then 
				t.wall = true 
			else
				t.wall = false
			end
			if tile == 16 then 
				t.powerup = true
			else
				t.powerup = false
			end
			if tile == 0 then
				t.dot = true
				tilemap.set_tile(url, "layer1", x, y, 17)
			end	
			t.grid_pos = vmath.vector3(x,y,0)
			t.screen_pos = M.get_screen_pos(t.grid_pos)
			table.insert(column,t)
			
		end
		table.insert(grid,column)
	end
	for x = 1,width do
		for y = 1,height do
			local check_tile = grid[x][y]
			if check_tile.wall == true then
				-- get neighbour value
				local value = 0
				for i,v in ipairs(lookup) do
					local tile 
					if x > 1 and x < #grid and y > 1 and y < #grid[1] then tile = grid[x+v[1]][y+v[2]] end
					if tile ~= nil and tile.wall == true then
						value = value + l_values[i]
					end
				end
				local img = tile_views[value]
				if img then
					tilemap.set_tile(url, "layer1", x, y, img)
				end
			end
		end
	end
end

function M.on_reached_tile(grid_pos)
	local url = msg.url("/level#level1")
	local tile = grid[grid_pos.x][grid_pos.y]
	if tile.dot == true then
		tilemap.set_tile(url, "layer1", grid_pos.x, grid_pos.y, 8)
		tile.dot = false
		msg.post("/hud","add_score", { add = 175 } )
	elseif tile.powerup == true then
		tilemap.set_tile(url, "layer1", grid_pos.x, grid_pos.y, 8)
		tile.powerup = false
		msg.post("/hud","add_score", { add = 500 } )
		for i,ghost in ipairs(ghost_controller.ghosts) do
			msg.post(ghost, "set_state", { state = 2 } )
		end
		
	end
end

return M
