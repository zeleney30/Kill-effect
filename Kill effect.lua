local getui = ui.get
local entindexId = client.userid_to_entindex
local localPlayer = entity.get_local_player()
local getProp = entity.get_prop
local realtime = globals.realtime
local callback = client.set_event_callback
local line = renderer.line
local checkbox = ui.new_checkbox
local colorpicker = ui.new_color_picker
local slider = ui.new_slider
local visibility = ui.set_visible
local worldToScreen = client.world_to_screen
local combobox = ui.new_combobox
local randomFloat = client.random_float
local rectangle = renderer.rectangle
----------------------------------------------------------------------------------------------------------------------------------

local enable = checkbox("Visuals", "Effects", "Kill effect")
local color = colorpicker("Visuals", "Effects", "Color", 255, 255, 255, 255)
local style = combobox("Visuals", "Effects", "Style", "Circle up", "Circle down", "Circle", "Skull")
local time = slider("Visuals", "Effects", "Duration", 1, 10, 2, true, "s")
local speed = slider("Visuals", "Effects", "Speed", 0, 100, 50, true, "%")
local radius = slider("Visuals", "Effects", "radius", 0, 81, 25, true, "px")
local pos = slider("Visuals", "Effects", "Position", 0, 80, 40, true)
----------------------------------------------------------------------------------------------------------------------------------

local math_rad, math_cos, math_sin = math.rad, math.cos, math.sin

local function DrawCircle3D(ctx, x, y, z, radius, r, g, b, a, accuracy)
    local accuracy = accuracy or 3
    local screen_x_line_old, screen_y_line_old

    for rot=0, 360,accuracy do
        local rot_temp = math_rad(rot)
        local lineX = radius * math_cos(rot_temp) + x
        local lineY = radius * math_sin(rot_temp) + y
        local lineZ = z
        local screen_x_line, screen_y_line = client.world_to_screen(ctx, lineX, lineY, lineZ)

        if screen_x_line ~=nil and screen_x_line_old ~= nil then
            line(screen_x_line, screen_y_line, screen_x_line_old, screen_y_line_old, r, g, b, a)
        end

        screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
    end
end
----------------------------------------------------------------------------------------------------------------------------------

local killTable = {}

local function on_player_death(e)
	if getui(enable) == false then
        return
    end

    if entindexId(e.attacker) == localPlayer then
        posX, posY, posZ = getProp(entindexId(e.userid), "m_vecOrigin")

        local duckAmount = getProp(entindexId(e.userid), "m_flDuckAmount")

        killTable[#killTable + 1] = {posX, posY, posZ + (46 + (1 - duckAmount) * 18), realtime() + getui(time), true}
    end
end

callback('player_death', on_player_death)
----------------------------------------------------------------------------------------------------------------------------------

local function on_round_prestart(e)
	killTable = {}
end

callback('round_prestart', on_round_prestart)
----------------------------------------------------------------------------------------------------------------------------------

local function on_paint(ctx)
	local r, g, b, a = getui(color)

    if getui(enable) then
    	visibility(style, true)
        visibility(color, true)
        visibility(time, true)
        visibility(speed, true)
        visibility(radius, true)

        if getui(style) == "Circle" or getui(style) == "Skull" then
        	visibility(pos, true)
        else
        	visibility(pos, false)
        end

        if getui(style) ~= "Skull" then
        	visibility(radius, true)
        else
        	visibility(radius, false)
        end

        for i = 1, #killTable do
            if killTable[i][5] == true then
                if realtime() >= killTable[i][4] then
                    killTable[i][5] = false
                end
     
                local x, y = worldToScreen(ctx, killTable[i][1], killTable[i][2], killTable[i][3])

                if x ~= nil then
                	if getui(style) == "Circle up" then
	                    DrawCircle3D(ctx, posX, posY, posZ, getui(radius), r, g, b, a, 3)

	                    posZ = posZ + getui(speed) / 100
                    elseif getui(style) == "Circle down" then
                    	DrawCircle3D(ctx, posX, posY, posZ + 80, getui(radius), r, g, b, a, 3)

                    	posZ = posZ - getui(speed) / 100
                	elseif getui(style) == "Circle" then
	                    DrawCircle3D(ctx, posX, posY, posZ + getui(pos), getui(radius), r, g, b, a, 3)
	                elseif getui(style) == "Skull" then
	                	local h = getui(pos)
	                	local x, y = worldToScreen(ctx, killTable[i][1], killTable[i][2], killTable[i][3])
	                	--outline
	                	rectangle(x - 11, y + h, 27, 3, r, g, b, a)
	                	rectangle(x + 16, y + h + 3, 3, 3, r, g, b, a)
	                	rectangle(x + 19, y + h + 6, 3, 6, r, g, b, a)
	                	rectangle(x + 22, y + h + 12, 3, 27, r, g, b, a)
	                	rectangle(x + 16, y + h + 39, 6, 3, r, g, b, a)
	                	rectangle(x + 13, y + h + 42, 3, 9, r, g, b, a)
	                	rectangle(x - 11, y + h + 51, 27, 3, r, g, b, a)
	                	rectangle(x - 5, y + h + 48, 3, 3, r, g, b, a)
	                	rectangle(x + 1, y + h + 48, 3, 3, r, g, b, a)
	                	rectangle(x + 7, y + h + 48, 3, 3, r, g, b, a)
	                	rectangle(x - 11, y + h + 42, 3, 9, r, g, b, a)
	                	rectangle(x - 17, y + h + 39, 6, 3, r, g, b, a)
	                	rectangle(x - 20, y + h + 12, 3, 27, r, g, b, a)
	                	rectangle(x - 14, y + h + 3, 3, 3, r, g, b, a)
	                	rectangle(x - 17, y + h + 6, 3, 6, r, g, b, a)
	                	--inside left eye
	                	rectangle(x - 11, y + h + 18, 12, 9, r, g, b, a)
	                	rectangle(x - 8, y + h + 15, 6, 15, r, g, b, a)
	                	--inside right eye
	                	rectangle(x + 4, y + h + 18, 12, 9, r, g, b, a)
	                	rectangle(x + 7, y + h + 15, 6, 15, r, g, b, a)
	                	--inside nose
	                	rectangle(x - 2, y + h + 36, 9, 3, r, g, b, a)
	                	rectangle(x + 1, y + h + 33, 3, 3, r, g, b, a)


               			killTable[i][3] = killTable[i][3] + getui(speed) / 100
	                end
                end
            end
        end
    else
    	visibility(style, false)
        visibility(color, false)
        visibility(time, false)
        visibility(speed, false)
        visibility(radius, false)
        visibility(pos, false)
    end
end

callback('paint', on_paint)
