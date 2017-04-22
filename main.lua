Hardon = require 'HC'

--array to hold rectangle information
arr_rectangles = {}
--array to hold rectangle hitbox information
arr_hitboxes = {}

MAX_RECTS = 49

WINDOW_WIDTH = 650
WINDOW_HEIGHT = 700

RECT_SIDE = WINDOW_WIDTH/10

RECT_OFFSET = 10.0

MAX_RECTS_ACROSS = MAX_RECTS/2
MAX_RECTS_VERTICAL = MAX_RECTS/2

left_most_rect = {}
bottom_most_rect = {}

first_rectangle = {}
first_hitbox = {}

mouse = Hardon.circle(400, 300, 20)
mouse:moveTo(love.mouse.getPosition())

there_are_collisions = false

function love.load()

	love.graphics.setBackgroundColor(50, 50, 50)
	--create a random seed
	math.randomseed(os.time())
	--initialize all the rectangles and their hitboxes
	first_rectangle = {}
	first_rectangle["x"] = math.random(WINDOW_WIDTH / RECT_SIDE)
	first_rectangle["y"] = math.random(WINDOW_HEIGHT / RECT_SIDE)
	first_rectangle["width"] = RECT_SIDE
	first_rectangle["height"] = RECT_SIDE

	first_hitbox = Hardon.rectangle(first_rectangle["x"], first_rectangle["y"], RECT_SIDE, RECT_SIDE)

	open_adjacent_spots = {{first_rectangle["x"] + RECT_SIDE + RECT_OFFSET, first_rectangle["y"]}, {first_rectangle["x"] - (RECT_SIDE + RECT_OFFSET), first_rectangle["y"]}, {first_rectangle["x"], first_rectangle["y"] + RECT_SIDE + RECT_OFFSET}, {first_rectangle["x"], first_rectangle["y"] - (RECT_SIDE + RECT_OFFSET)}}

	x = first_rectangle["x"] - math.floor(WINDOW_WIDTH/RECT_SIDE)
	y = first_rectangle["y"] - math.floor(WINDOW_HEIGHT/RECT_SIDE)

	--Create a map for occupied areas
	occupied_map = {}
	while x < first_rectangle["x"] + math.floor(WINDOW_WIDTH/RECT_SIDE) do
		while y < first_rectangle["y"] + math.floor(WINDOW_HEIGHT/RECT_SIDE) do
			occupied_map[x .. "," .. y] = false 
			y = y + RECT_SIDE + RECT_OFFSET
		end
		x = x + RECT_SIDE + RECT_OFFSET
	end

	occupied_map[first_rectangle["x"] .. "," .. first_rectangle["y"]] = true --Set the first graph as occupied

	left_most_rect = first_rectangle
	bottom_most_rect = first_rectangle

	table.insert(arr_rectangles, first_rectangle)
	table.insert(arr_hitboxes, first_hitbox)

	
	i = 2
	while i <= MAX_RECTS do
		--create a random seed
		math.randomseed(os.time())
		open_index = math.random(table.getn(open_adjacent_spots))

		if occupied_map[open_adjacent_spots[open_index][1] .. "," .. open_adjacent_spots[open_index][2]] then
				table.remove(open_adjacent_spots, open_index)
	else
		new_rectangle = {}
		new_rectangle["x"] = open_adjacent_spots[open_index][1]
		new_rectangle["y"] = open_adjacent_spots[open_index][2]
		new_rectangle["width"] = RECT_SIDE
		new_rectangle["height"] = RECT_SIDE

		new_hitbox = Hardon.rectangle(new_rectangle["x"], new_rectangle["y"], RECT_SIDE, RECT_SIDE)


		x_axis = new_rectangle["x"]
		y_axis = new_rectangle["y"]

		first_x = first_rectangle["x"]
		first_y = first_rectangle["y"]

			table.insert(open_adjacent_spots, {new_rectangle["x"] - (RECT_SIDE + RECT_OFFSET), new_rectangle["y"]})
			table.insert(open_adjacent_spots, {new_rectangle["x"] + RECT_SIDE + RECT_OFFSET, new_rectangle["y"]})
			table.insert(open_adjacent_spots, {new_rectangle["x"], new_rectangle["y"] - (RECT_SIDE + RECT_OFFSET)})
			table.insert(open_adjacent_spots, {new_rectangle["x"], new_rectangle["y"] + RECT_SIDE + RECT_OFFSET})


		occupied_map[new_rectangle["x"] .. "," .. new_rectangle["y"]] = true

		if new_rectangle["x"] < left_most_rect["x"] then
			left_most_rect = new_rectangle
		end
		if new_rectangle["y"] < bottom_most_rect["y"] then
			bottom_most_rect = new_rectangle
		end


		table.remove(open_adjacent_spots, open_index) --remove this open index so that it's not considered again

		table.insert(arr_rectangles, new_rectangle)
		table.insert(arr_hitboxes, new_hitbox)

		i = i + 1
	end
end
end

function love.update(dt)
	--Check for collisions when the mouse is down
	there_are_collisions = false
	if love.mouse.isDown(1) then
		for shape, delta in pairs(Hardon.collisions(mouse)) do
			there_are_collisions = true
			break
		end

	end
end

function love.draw(dt)
	OFFSET_X = left_most_rect["x"]
	OFFSET_Y = bottom_most_rect["y"]

	if OFFSET_Y < 0 then 
		OFFSET_Y = OFFSET_Y * -1 
	end

	if(there_are_collisions) then
		love.graphics.print("THERE ARE COLLISIONS YA BITCH!!!!!!", 10, 10)
	end

    for i, v in ipairs(arr_rectangles) do
    	love.graphics.rectangle("fill", v["x"] - OFFSET_X, v["y"] + OFFSET_Y, v["width"], v["height"], 20, 20)
    end
end