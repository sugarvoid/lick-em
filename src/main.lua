slots = { 2, 20, 38, 56, 74, 92, 110 }

function _init()
    cartdata("lickem_data")
    poke(0x5f5c, 255)
    game_state = 0
    active_human = nil
    game_running = false
    high_score = nil
    sw_running = false
    title_choice = 1
    showing_info = false
    title_options = { "play", "info" }
    player_eat = { 146, 148, 150, 152, 154, 152, 154, 150, 148, 146 }
    p_anim_played = true
    tick = 0
    curr_human_slot = 1
    future_slot = 6
    marker_y = 85
    m_delta = 0.2
    next_slot = 2
end

function reset_game()
end

function start_game()
    frame_total = 0
    old_frame_total = dget(0)
    if old_frame_total == 0 then
        old_frame_total = 8000000000
    end
    high_score = old_frame_total
    game_state = 1
    timer_started = false
    licks_left = 20
    failed_reason = nil
    active_human = spawn_human(slots[curr_human_slot])
    game_running = true
end

function _update60()
    if game_state == 0 then
        u_main()
    elseif game_state == 1 then
        u_play()
        if sw_running then
            frame_total += (1 / 2) ^ 16 --0.000015259
            -- test_count+=(1/2)^16 keep
        end
    elseif game_state == 2 then
        u_gameover()
    end
end

function _draw()
    if game_state == 0 then
        d_main()
    elseif game_state == 1 then
        draw_play()
    elseif game_state == 2 then
        d_gameover()
    end
    --print("mem: "..flr(stat(0)).."kb", 0, 0, 8)
    --print("cpu: "..stat(1).. "%", 0, 8, 8)
end

function u_main()
    if btnp(🅾️) then
        start_game() 
    end
end


function d_main()
    cls()
    --if showing_info then
        cprint("how to play", 40)
        cprint("- lick 20 guys", 50)
        cprint("- 🅾️ to move", 60)
        cprint("- ❎ to lick", 70)
        cprint("how fast can you go?", 90)

        --cprint("🅾️ to go back", 64, 100)
        sspr(0, 32, 8 * 8, 4 * 8, 32, 3)

        cprint(" 🅾️ play",110, 7)
    --end
end

function draw_play()
    cls(0)
    
    rectfill(0, 104, 128, 128, 4)
    --line(0,104, 128,104,15)
    draw_spots()

    for h in all(humans) do
        h:draw()
    end


    player:draw()
    spr(17, slots[future_slot] + 4, marker_y)
    print("⧗", 2, 2, 10)
    print("⧗" .. get_time_from_frames(tostr(frame_total, 2)), 45, 35, 7)
    print(get_time_from_frames(tostr(high_score, 2)), 10, 2, 7)
    print("licks left:" .. licks_left, 65, 2)
    draw_controls()
end

function draw_controls()
    --if 1 == 1 then
        print("🅾️ move", 25, 120, 7)
        print("❎ lick", 65, 120, 7)
    --else
      --  print("🅾️ <--", 25, 120, 7)
       -- print("❎  -->", 65, 120, 7)
    --end
end

function u_play()
    player:update()
    for h in all(humans) do
        h:update()
    end

    marker_y += m_delta

    if marker_y <= 83 then
        m_delta *= -1
    elseif marker_y >= 89 then
        m_delta *= -1
    end

    if btnp(4) then player:move() end
    if btnp(5) then player:lick() end
end

function animationfinished()
    if game_running then
        active_human = spawn_human(slots[curr_human_slot])
        get_next()
    end
end

function goto_gameover(code)
    game_running = false
    p_anim_played = true
    for h in all(humans) do
        del(humans, h)
    end

    sw_running = false
    failed_reason = code
    if code == 0 or code == 1 then
        sfx(0)
    else
        sfx(3)
        --printh('saving: '..sw.f..", m"..sw.m..", s"..sw.m, 'save_time.txt')
        if frame_total < old_frame_total then
            dset(0, frame_total)
        end
    end

    game_state = 2
end

function draw_spots()
    --TODO: Change color based on is actor is on spot
    sspr(48, 0, 16, 8, slots[1], 106)
    sspr(48, 0, 16, 8, slots[2], 106)
    sspr(48, 0, 16, 8, slots[3], 106)
    sspr(48, 0, 16, 8, slots[4], 106)
    sspr(48, 0, 16, 8, slots[5], 106)
    sspr(48, 0, 16, 8, slots[6], 106)
    sspr(48, 0, 16, 8, slots[7], 106)
end

function u_gameover()
    if btnp(⬇️) then
        start_game()
    end
end

function d_gameover()
    cls(0)
    if active_human then
        pal(8, active_human.col)
    end

    if failed_reason == 0 then
        --should have licked
        spr(76, 45, 20, 4, 4)
        print("bad lick", 30, 60, 7)
    elseif failed_reason == 1 then
        --should have moved
        spr(72, 45, 20, 4, 4)
        print("bad move", 30, 60, 7)
    elseif failed_reason == 2 then
        print("you win", 30, 40, 7)

        if frame_total < old_frame_total then
            print("personal best!", 30, 52, 7) --todo: make text flash
        end

        print(get_time_from_frames(tostr(frame_total, 2)), 30, 65, 7)
    end
    pal()
    print("⬇️ to try again", 30, 100)
end

function get_next()
    n_pos = flr(rnd(7)) + 1
    while (n_pos == future_slot)
        or (n_pos == future_slot - 1)
        or (n_pos == future_slot + 1) do
        n_pos = flr(rnd(7)) + 1
    end
    future_slot = n_pos
end

-- center print
function cprint(s, y)
    print(s, 64 - (((#s * 4) - 1) / 2), y)
end




-- human=obj:new({
-- 	x,y=0,
-- 	col=nil,
--     img=38,
--     peaked=false,
--     scared=false,
--     facing_l=true,

-- 	update=function(self)
--         if self.scared then
--             self.img=40
--             self.y -=1
--         end

--         if self.y<=80 then
--             self.peaked=true
--         end

--         if self.peaked then
--             self.y+=4
--         end

-- 		if self.y >= 130 then
-- 			del(humans,self)
-- 		end

--   	end,

-- 	draw=function(self)
-- 		pal(8,self.col)
--         spr(self.img,self.x,self.y,2,2,self.facing_l)

-- 		pal()
-- 	end,
-- })

-- function spawn_human(x_pos)
-- 	new_guy = human:new()
--     new_guy.facing_l = p1.look_left
--     new_guy.img =38
-- 	new_guy.x=x_pos
-- 	new_guy.y=91
-- 	new_guy.col=rnd(cols)
-- 	add(humans,new_guy)
--     return new_guy
-- end


function get_time_from_frames(frame_total)
    local total_seconds = frame_total / 60 -- change to 30 is using _update()
    local minutes = flr(total_seconds / 60)
    local seconds = flr(total_seconds % 60)
    local centiseconds = flr((total_seconds - flr(total_seconds)) * 100)
    return pad_zero(minutes) .. ":" .. pad_zero(seconds) .. "." .. pad_zero(centiseconds)
end

function pad_zero(num)
    if num < 10 then
        return "0" .. num
    else
        return num
    end
end

function print_debug(str)
    printh("debug: " .. str, 'debug.txt')
end

-- function hcenter(s)
--     -- screen center minus the
--     -- string length times the
--     -- pixels in a char's width,
--     -- cut in half
--     return 64 - #s * 2
-- end

-- function vcenter(s)
--     -- screen center minus the
--     -- string height in pixels,
--     -- cut in half
--     return 61
-- end

-- function shuffle(t)
--     -- do a fisher-yates shuffle
--     for i = #t, 1, -1 do
--         local j = flr(rnd(i)) + 1
--         t[i], t[j] = t[j], t[i]
--     end
-- end

-- function randi_rang(l, h)
--     return flr(rnd(h)) + l
-- end
