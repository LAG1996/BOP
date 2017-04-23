Hardon = require 'HC'

--environment sprites
board_pieces = { 
	love.graphics.newImage("images/placepieces/brick_red.png"),
	love.graphics.newImage("images/placepieces/turqoise.png"),
	love.graphics.newImage("images/placepieces/yolk.png"),
	love.graphics.newImage("images/placepieces/shadow.png")
}

color_names = {"red", "green", "yellow"}

brushaff = "fonts/Brushaff.ttf"

--start the click delay timer
delay_timer = 0.0
AMT_DELAY_FRAMES = 7

--array to hold rectangle information
arr_rectangles = {}
--array to hold rectangle hitbox information
arr_hitboxes = {}
--Array for colors
color = {} 
color[1] = {0, 0, 255} --These are colors for the boxes (will be obsolete if we use sprites for the boxes)
color[2] = {255, 0, 0}
color[3] = {0, 255, 0}

-- Saving the shape and delta values in a global variable
mouseXPosition = nil
mouseYPosition = nil

lastRecordedRectColor = {} --A table for recording the last known color of a box. Probably useless as well.

box2rect = {} --A table for mapping hitboxes to their parent boxes
rect2box = {}

pos2rect = {} --A table for mapping positions to their parent boxes

WINDOW_WIDTH = 1024 --Value for window width
WINDOW_HEIGHT = 720 --Value for window height

RECT_SIDE = WINDOW_WIDTH/10 --Size of a box

MAX_RECTS = 50

RECT_OFFSET = 1.8 --The offset between the boxes

WINDOW_TOP_AREA_HEIGHT = 200 --An offset so that we have space to put a UI

left_most_rect = {} --A variable to store the left-most rectangle in the graph
bottom_most_rect = {} --A variable to store the bottom-most rectangle in the graph
left_top_most_rect = {}
left_bottom_most_rect = {}
right_top_most_rect = {}
right_bottom_most_rect = {}

first_rectangle = {} --A variable to store the first rectangle drawn
first_hitbox = {}

mouse = Hardon.circle(400, 300, 10) --The hitbox for checking mouse clicks
mouse:moveTo(love.mouse.getPosition()) --Default the circle to the mouse's position

there_are_collisions = false
hover = false

score_multiplier_counter = 1 --A counter for determining when a player gets a point added to their score multiplier
multiplier = 0 --The value of their multiplier
rectangles_that_have_changed = {} --A table of rectangles that are changed when clicked or switched by a computer
Player_Score = 0 --The player's current score
clicked_box = nil --Stores the hit-box the player chooses
hovered_box = nil

difficultyIncreaseTitle = "Save EARTH!!!"
difficultyIncreaseMessage = "The humans need to stop destroying EARTH.                       The difficulty will now Increase "
changeColorCount = 0
difficultyIncreaseButtons = {"OK", "No!", "Help", escapebutton = 2}

table_dimensions_x = 25
table_dimensions_y = 25

biomes = {"industry", "woodland", "ocean", "atmosphere"}

listOfInfluence = {}
alreadyTookOver = {}

MAX_RECTS = math.floor(table_dimensions_x * table_dimensions_y * .40)

piece_scale = 0.06
piece_size = 1024

camera = {0, 0}
camera_speed = 250

first_computer_action = true
computer_action_interval = 15.0
computer_acted = false
prompt_timer = 5.0
cur_pick = nil

seed = 123213213232
math.randomseed(os.time())

function love.load()
	my_color = 1
	love.graphics.setBackgroundColor(50, 50, 50)
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = true})

	--create a random seed
	--initialize all the rectangles and their hitboxes
	first_rectangle = {}
	first_rectangle["x"] = math.random(table_dimensions_x)
	first_rectangle["y"] = math.random(table_dimensions_y)
	first_rectangle["width"] = RECT_SIDE
	first_rectangle["height"] = RECT_SIDE
	first_rectangle["color"] = my_color
	first_rectangle["neighbors"] = {}

	my_color = my_color + 1

	open_adjacent_spots = {{first_rectangle["x"] + 1, first_rectangle["y"]}, {first_rectangle["x"] - 1, first_rectangle["y"]}, {first_rectangle["x"], first_rectangle["y"] + 1}, {first_rectangle["x"], first_rectangle["y"] - 1}}

	x = 1
	y = 1

	--Create a map for occupied areas
	occupied_map = {}
	while x < first_rectangle["x"] + math.floor(WINDOW_WIDTH/RECT_SIDE) do
		while y < first_rectangle["y"] + math.floor(WINDOW_HEIGHT/RECT_SIDE) do
			occupied_map[x .. "," .. y] = false 
			y = y + 1
		end
		x = x + 1
	end

	occupied_map[first_rectangle["x"] .. "," .. first_rectangle["y"]] = true --Set the first graph as occupied

	left_most_rect = first_rectangle
	bottom_most_rect = first_rectangle
	left_top_most_rect = first_rectangle
	left_bottom_most_rect = first_rectangle
	right_top_most_rect = first_rectangle
	right_bottom_most_rect = first_rectangle

	table.insert(arr_rectangles, first_rectangle)
	pos2rect[first_rectangle["x"]..","..first_rectangle["y"]] = first_rectangle
	
	i = 2
	while i <= MAX_RECTS do
		--create a random seed
		open_index = math.random(table.getn(open_adjacent_spots))


		if occupied_map[open_adjacent_spots[open_index][1] .. "," .. open_adjacent_spots[open_index][2]] then
			table.remove(open_adjacent_spots, open_index)
		else
			new_rectangle = {}
			new_rectangle["x"] = open_adjacent_spots[open_index][1]
			new_rectangle["y"] = open_adjacent_spots[open_index][2]
			new_rectangle["width"] = piece_size * piece_scale
			new_rectangle["height"] = piece_size * piece_scale
			new_rectangle["color"] = my_color

			--Set adjacent neighbors
			new_rectangle["neighbors"] = {}
			--Look at all nodes up, down, left, and right in the occupied_map
			if new_rectangle["x"] ~= table_dimensions_x then
				if occupied_map[new_rectangle["x"] + 1 .. "," .. new_rectangle["y"]] then
				table.insert(new_rectangle["neighbors"], pos2rect[new_rectangle["x"] + 1 ..","..new_rectangle["y"]])
				table.insert(pos2rect[new_rectangle["x"] + 1 .. "," .. new_rectangle["y"]], new_rectangle)
				end
			end
			if new_rectangle["x"] ~= 1 then
			if occupied_map[new_rectangle["x"] - 1 .. "," .. new_rectangle["y"]] then
				table.insert(new_rectangle["neighbors"], pos2rect[new_rectangle["x"] - 1 ..","..new_rectangle["y"]])
				table.insert(pos2rect[new_rectangle["x"] - 1 .. "," .. new_rectangle["y"]], new_rectangle)
			end
		end
		if new_rectangle["y"] ~= table_dimensions_y then
			if occupied_map[new_rectangle["x"] .. "," .. new_rectangle["y"] + 1] then
				table.insert(new_rectangle["neighbors"], pos2rect[new_rectangle["x"] ..",".. new_rectangle["y"] + 1])
				table.insert(pos2rect[new_rectangle["x"] .. "," .. new_rectangle["y"] + 1], new_rectangle)
			end
		end
		if new_rectangle["y"] ~= 1 then
			if occupied_map[new_rectangle["x"] .. "," .. new_rectangle["y"] - 1] then
				table.insert(new_rectangle["neighbors"], pos2rect[new_rectangle["x"] ..",".. new_rectangle["y"] - 1])
				table.insert(pos2rect[new_rectangle["x"] .. "," .. new_rectangle["y"] - 1], new_rectangle)
			end
		end

			my_color = my_color + 1

			if my_color == 4 then
				my_color = 1
			end


			x_axis = new_rectangle["x"]
			y_axis = new_rectangle["y"]

			first_x = first_rectangle["x"]
			first_y = first_rectangle["y"]

			table.insert(open_adjacent_spots, {new_rectangle["x"] - 1, new_rectangle["y"]})
			table.insert(open_adjacent_spots, {new_rectangle["x"] + 1, new_rectangle["y"]})
			table.insert(open_adjacent_spots, {new_rectangle["x"], new_rectangle["y"] - 1})
			table.insert(open_adjacent_spots, {new_rectangle["x"], new_rectangle["y"] + 1})


			occupied_map[new_rectangle["x"] .. "," .. new_rectangle["y"]] = true

			if new_rectangle["x"] < left_most_rect["x"] then
				left_most_rect = new_rectangle
			end
			if new_rectangle["y"] < bottom_most_rect["y"] then
				bottom_most_rect = new_rectangle
			end
			if new_rectangle["x"] < left_most_rect["x"] and new_rectangle["y"] < bottom_most_rect["y"] then
				left_bottom_most_rect = new_rectangle
			end
			if new_rectangle["x"] > left_most_rect["x"] and new_rectangle["y"] > bottom_most_rect["y"] then
				right_top_most_rect = new_rectangle
			end
			if new_rectangle["x"] < left_most_rect["x"] and new_rectangle["y"] > bottom_most_rect["y"] then
				right_top_most_rect = new_rectangle
			end
			if new_rectangle["x"] > left_most_rect["x"] and new_rectangle["y"] < bottom_most_rect["y"] then
				right_bottom_most_rect = new_rectangle
			end


			table.remove(open_adjacent_spots, open_index) --remove this open index so that it's not considered again

			table.insert(arr_rectangles, new_rectangle)

			pos2rect[new_rectangle["x"]..","..new_rectangle["y"]] = new_rectangle
			i = i + 1
		end
end
	
	for i, rect in ipairs(arr_rectangles) do
		new_hitbox = Hardon.rectangle(rect["x"] * piece_size * piece_scale - left_most_rect["x"] * piece_scale * piece_size, rect["y"] * piece_size * piece_scale - bottom_most_rect["y"] * piece_scale * piece_size + WINDOW_TOP_AREA_HEIGHT, rect["width"], rect["height"])
		box2rect[new_hitbox] = rect
		rect2box[rect] = new_hitbox
		lastRecordedRectColor[rect] = rect["color"]
		alreadyTookOver[rect["x"]..","..rect["y"]] = false
		table.insert(arr_hitboxes, new_hitbox)
	end

	table.insert(listOfInfluence, left_bottom_most_rect)
end

--Given an X and Y, tell me the biome I'm in
function GetBiome(x, y)
	
	if x <= table_dimensions_x / 2 and y >= table_dimensions_y / 2 then
		return "Industry"
	end

	if x > table_dimensions_x / 2 and y > table_dimensions_y / 2 then
		return "Forest"
	end

	if x <= table_dimensions_x / 2 and y <= table_dimensions_y /2 then
		return "Sky"
	end

	if x > table_dimensions_x / 2 and y < table_dimensions_y/2 then
		return "Ocean"
	end

	return "NA"
end

function love.update(dt)
	for i, rect in ipairs(rectangles_that_have_changed) do
		_HandleNewColor(rect)
		table.remove(rectangles_that_have_changed, i)
	end

	--Check for collisions when the mouse is down
	mouse:moveTo(love.mouse.getPosition())
	there_are_collisions = false
	hover = false
	clicked_box = nil
		for shape, delta in pairs(Hardon.collisions(mouse)) do
			mouseXPosition,mouseYPosition = love.mouse.getPosition()
				if love.mouse.isDown(1) or love.mouse.isDown(3) then
					there_are_collisions = true
					clicked_box = shape
				else
					hover = true
					hovered_box = shape
				break
			end

	end

	if love.keyboard.isDown("escape") then
		love.window.close()
	end

	--check for keyboard presses to move around the map
	if love.keyboard.isDown("w") and camera[2] - 1 * camera_speed * dt > WINDOW_TOP_AREA_HEIGHT then
		camera[2] = camera[2] - 1 * camera_speed * dt
	end

	if love.keyboard.isDown("a") and camera[1] - 1 * camera_speed * dt > (left_most_rect["x"] - 50) * piece_size * piece_scale then
		camera[1] = camera[1] - 1 * camera_speed * dt
	end

	if love.keyboard.isDown("s") and camera[2] + 1 * camera_speed * dt < (table_dimensions_y + 50) * piece_size * piece_scale then
		camera[2] = camera[2] + 1 * camera_speed * dt
	end

	if love.keyboard.isDown("d") and camera[1] + 1 * camera_speed * dt < (table_dimensions_x + 50) * piece_size * piece_scale then
		camera[1] = camera[1] + 1 * camera_speed * dt
	end

	if delay_timer >= AMT_DELAY_FRAMES then
		delay_timer = 0
	end

	if delay_timer >= 1.0 then
		delay_timer = delay_timer + 1
	end

	computer_action_interval = computer_action_interval - dt

	if prompt_timer > 0 then
		prompt_timer = prompt_timer - dt
	else
		computer_acted = false
	end

--[[
	if computer_action_interval <= 0 then
		Computer_Change()
	end
]]--
	Computer_Change()
end

function love.draw(dt)
	if there_are_collisions and delay_timer == 0 then
		_ChangeColor()
	end

    for i, v in pairs(box2rect) do
    	love.graphics.draw(board_pieces[v["color"]], v["x"] * RECT_OFFSET * piece_size * piece_scale - left_most_rect["x"] * RECT_OFFSET * piece_scale * piece_size - camera[1], v["y"] * RECT_OFFSET * piece_size * piece_scale - bottom_most_rect["y"] * RECT_OFFSET * piece_scale * piece_size + WINDOW_TOP_AREA_HEIGHT - camera[2], 0, piece_scale, piece_scale)
    	i:moveTo((v["x"] * RECT_OFFSET) * piece_size * piece_scale - left_most_rect["x"] * RECT_OFFSET * piece_scale * piece_size - camera[1] + v["width"]/2, (v["y"] * RECT_OFFSET) * piece_size * piece_scale - bottom_most_rect["y"]* RECT_OFFSET * piece_scale * piece_size + WINDOW_TOP_AREA_HEIGHT - camera[2] + v["height"]/2)
    end

    if hover then
		back_color = box2rect[hovered_box]["color"] - 1
		next_color = box2rect[hovered_box]["color"] + 1

		font = love.graphics.newFont(brushaff, 50)
		love.graphics.setFont(font)

		if back_color <= 0 then
			back_color = 3
		end
		if next_color >= 4 then
			next_color = 1
		end

		love.graphics.print("<L "..color_names[back_color].."\t"..color_names[next_color].." R>", 800, 50)
	end

    hovered_box = nil
    clicked_box = nil

    font = love.graphics.newFont(brushaff, 100)
	love.graphics.setFont(font)
	
	love.graphics.print("Balance Our Planet!", 10, 15)

	love.graphics.print("Score: " .. Player_Score, 100, 150)

	font = love.graphics.newFont(brushaff, 30)
	love.graphics.setFont(font)
	love.graphics.print("x" .. multiplier, 100, 250)

end

function _HandleNewColor(rect)
	is_different = 0
	for i, Neighbor in ipairs(rect["neighbors"]) do
		if Neighbor["color"] == rect["color"] then
			score_multiplier_counter = 1
		else
			Player_Score = Player_Score + 10 * math.pow(2, multiplier)
			score_multiplier_counter = score_multiplier_counter + 1
			is_different = is_different + 1

			if is_different == 2 then
				break
			end
		end
	end

	if score_multiplier_counter >= 15 then
		multiplier = 3
	elseif score_multiplier_counter >= 7 then
		multiplier = 2
	elseif score_multiplier_counter >= 3 then
		multiplier = 1
	else
		multiplier = 0
	end


end

function Computer_Change()

	node_to_change = {}
	math.randomseed(love.timer.getTime())
	math.random()
	math.random()
	math.random()
	math.random()
	node_to_change = arr_hitboxes[math.random(MAX_RECTS)]

		cur_pick = node_to_change

	tempColor = box2rect[node_to_change]["color"]
	sign = 0

	if math.random(2) == 1 then
		sign = -1
	else
		sign = 1
	end

	if tempColor + sign < 1 then
		tempColor = 3
		elseif tempColor + sign > 3 then
			tempColor = 1
		else
			tempColor = tempColor + sign
	end

	box2rect[node_to_change]["color"] = tempColor

	first_computer_action = false
	computer_action_interval = 5.0
	prompt_timer = 3.0
	computer_acted = true
end

function _ChangeColor()
	changeColorCount = changeColorCount + 1;
	if love.mouse.isDown(1) then
		tempColor = box2rect[clicked_box]["color"] + 1;
	end
	if love.mouse.isDown(3) then
		tempColor = box2rect[clicked_box]["color"] - 1;
	end
	if(tempColor == 4 ) then
		tempColor=1;
	end
	if (tempColor == 0) then
		tempColor = 3;
	end
	box2rect[clicked_box]["color"] = tempColor;

	--[[
   	if(changeColorCount==20) then
   		changeColorCount = 0
   		difficultyIncreaseButtonPressed = love.window.showMessageBox(difficultyIncreaseTitle, difficultyIncreaseMessage, difficultyIncreaseButtons)
   		if(difficultyIncreaseButtonPressed==1) then
			MAX_RECTS = MAX_RECTS * 3
			--RECT_SIDE = RECT_SIDE / 2
			--RECT_OFFSET = RECT_OFFSET / 2
			--WINDOW_WIDTH = WINDOW_WIDTH * 2
			--WINDOW_HEIGHT = WINDOW_HEIGHT * 2
			-- This won't clear the objects ( Since they are globally defined, will have to re-initialize)
			love.graphics.clear()
			love.load()
		elseif (difficultyIncreaseButtonPressed==2) then
			-- No
		elseif (difficultyIncreaseButtonPressed==3) then
			-- Help
		end
   	end]]--

		if(tempColor == 4 ) then
			tempColor=1;
		end
		if (tempColor == 0) then
			tempColor = 3;
		end
		box2rect[clicked_box]["color"] = tempColor;

		table.insert(rectangles_that_have_changed, box2rect[clicked_box])
		delay_timer = 1.0
end