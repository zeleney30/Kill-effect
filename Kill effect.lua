local globals_realtime = globals.realtime
local globals_curtime = globals.curtime
local globals_frametime = globals.frametime
local globals_absolute_frametime = globals.absoluteframetime
local globals_maxplayers = globals.maxplayers
local globals_tickcount = globals.tickcount
local globals_tickinterval = globals.tickinterval
local globals_mapname = globals.mapname
 
local client_set_event_callback = client.set_event_callback
local client_console_log = client.log
local client_console_cmd = client.exec
local client_userid_to_entindex = client.userid_to_entindex
local client_get_cvar = client.get_cvar
local client_set_cvar = client.set_cvar
local client_draw_debug_text = client.draw_debug_text
local client_draw_hitboxes = client.draw_hitboxes
local client_draw_indicator = client.draw_indicator
local client_random_int = client.random_int
local client_random_float = client.random_float
local client_draw_text = client.draw_text
local client_draw_rectangle = client.draw_rectangle
local client_draw_line = client.draw_line
local client_draw_gradient = client.draw_gradient
local client_draw_cricle = client.draw_circle
local client_draw_circle_outline = client.draW_circle_outline
local client_world_to_screen = client.world_to_screen
local client_screen_size = client.screen_size
local client_visible = ui.set_visible
local client_delay_call = client.delay_call
local client_latency = client.latency
local client_camera_angles = client.camera_angles
local client_trace_line = client.trace_line
local client_eye_position = client.eye_position
 
local entity_get_local_player = entity.get_local_player
local entity_get_all = entity.get_all
local entity_get_players = entity.get_players
local entity_get_classname = entity.get_classname
local entity_set_prop = entity.set_prop
local entity_get_prop = entity.get_prop
local entity_is_enemy = entity.is_enemy
local entity_get_player_name = entity.get_player_name
local entity_get_player_weapon = entity.get_player_weapon
local entity_hitbox_position = entity.hitbox_position
local entity_get_steam64 = entity.get_steam64
local entity_get_bounding_box = entity.get_bounding_box
local entity_is_alive = entity.is_alive
 
local ui_new_checkbox = ui.new_checkbox
local ui_new_slider = ui.new_slider
local ui_new_combobox = ui.new_combobox
local ui_new_multiselect = ui.new_multiselect
local ui_new_hotkey = ui.new_hotkey
local ui_new_button = ui.new_button
local ui_new_color_picker = ui.new_color_picker
local ui_reference = ui.reference
local ui_set = ui.set
local ui_get = ui.get
local ui_set_callback = ui.set_callback
local ui_set_visible = ui.set_visible
local ui_is_menu_open = ui.is_menu_open
 
local math_floor = math.floor
local math_random = math.random
local meth_sqrt = math.sqrt
local table_insert = table.insert
local table_remove = table.remove
local table_size = table.getn
local table_sort = table.sort
local string_format = string.format
local bit_band = bit.band

local client_draw_line = client.draw_line
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
            client_draw_line(ctx, screen_x_line, screen_y_line, screen_x_line_old, screen_y_line_old, r, g, b, a)
        end
        screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
    end
end

local enable = ui_new_checkbox("VISUALS", "Effects", "Kill effect")
local color = ui_new_color_picker("VISUALS", "Effects", "Color", 255, 255, 255, 255)
local time = ui_new_slider("VISUALS", "Effects", "Duration", 1, 10, 2, true, "s")
local speed = ui_new_slider("VISUALS", "Effects", "Speed", 0, 100, 50, true, "%")
 
local killTable = {}

local radius = 25

client_set_event_callback("player_death", function(e)
 
    if ui_get(enable) == false then
 
        return
 
    end
 
    if client_userid_to_entindex(e.attacker) == entity_get_local_player() then

        posX, posY, posZ = entity_get_prop(client_userid_to_entindex(e.userid), "m_vecOrigin")

        local duckAmount = entity_get_prop(client_userid_to_entindex(e.userid), "m_flDuckAmount")
 
        killTable[#killTable + 1] = {posX, posY, posZ + (46 + (1 - duckAmount) * 18), globals_realtime() + ui_get(time), true}
 
    end
 
end)
 
client_set_event_callback("round_prestart", function(e)
 
    killTable = {}
 
end)
 
client_set_event_callback("paint", function(ctx)
    local r, g, b, a = ui_get(color)

    if ui_get(enable) then
        client_visible(color, true)
        client_visible(time, true)
        client_visible(speed, true)

        for i = 1, #killTable do
            if killTable[i][5] == true then
                if globals_realtime() >= killTable[i][4] then
                    killTable[i][5] = false
                end
     
                local x, y = client_world_to_screen(ctx, killTable[i][1], killTable[i][2], killTable[i][3])

                --client_draw_text(ctx, x, y, r, g, b, a, "cb", 0, "Kill")
                if x ~= nil then
                    DrawCircle3D(ctx, posX, posY, posZ, radius, r, g, b, a, 3)

                    posZ = posZ + ui_get(speed) / 100
                end
            end
        end
    else
        client_visible(color, false)
        client_visible(time, false)
        client_visible(speed, false)
    end
end)
