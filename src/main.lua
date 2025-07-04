slots = { 2, 20, 38, 56, 74, 92, 110 }

function _init()
    cartdata("lickem_data")
    poke(0x5f5c, 255)
    is_game_running = false
    sw_running = false
    p_anim_played = true
    curr_human_slot = nil
    future_slot = nil
    marker_y = 85
    m_delta = 0.2
    --next_slot = 2
    gameover_col = 8
    --reset_spots()
    reset_game()
end

function get_spots()
    local x = rnd({3,4,5})
    local result = {x - 2, x, x + 2}
    shuffle(result)
    return result
end

function reset_spots()
    local spots = get_spots()
    curr_human_slot = spots[1]
    future_slot = spots[2]
    player.slot = spots[3]
    active_human = spawn_human(slots[curr_human_slot])
end

function reset_game()
    reset_spots()
    frame_total = 0
    old_frame_total = dget(0)
    if old_frame_total == 0 then
        old_frame_total = 8000000000
    end
    high_score = old_frame_total
    licks_left = 20
    failed_reason = nil
    --active_human = spawn_human(slots[curr_human_slot])
    is_game_running = true
    player:reset()
end

function _update60()
    if is_game_running then
        update_play()
    else
        update_gameover()
    end
end

function _draw()
    cls()
    if is_game_running then
        draw_play()
    else
        draw_gameover()
    end
end

function draw_play()
    draw_spots()
    if not sw_running then
        cprint("goal", 38, 12)
        cprint("lick 20 guys", 46)
        cprint("how fast can you go?", 64)
        sspr(8, 40, 48, 16, 20, 2, 96, 32)
    else
        print("licks left:" .. licks_left, 65, 2, 7)
        print("\^w\^t" .. get_time_from_frames(tostr(frame_total, 2)), 32, 35, 7)
    end
    print("⧗", 2, 2, 10)
    print(get_time_from_frames(tostr(high_score, 2)), 10, 2, 7)
    foreach(humans, function(obj) obj:draw() end)
    player:draw()
    spr(17, slots[future_slot] + 4, marker_y)
    draw_controls()
end

function draw_controls()
    print("🅾️ move", 25, 120, 7)
    print("❎ lick", 65, 120, 7)
end

function update_play()
    player:update()
    foreach(humans, function(obj) obj:update() end)

    marker_y += m_delta

    if marker_y <= 83 then
        m_delta *= -1
    elseif marker_y >= 89 then
        m_delta *= -1
    end

    if btnp(4) then player:move() end
    if btnp(5) then player:lick() end

    if sw_running then
        frame_total += (1 / 2) ^ 16 --0.000015259
    end
end

function animationfinished()
    if is_game_running then
        active_human = spawn_human(slots[curr_human_slot])
        gameover_col = active_human.col
        get_next()
    end
end

function goto_gameover(code)
    is_game_running = false
    p_anim_played = true
    foreach(humans, function(obj) del(humans, obj) end)
    sw_running = false
    failed_reason = code
    if code == 0 or code == 1 then
        sfx(0)
    else
        sfx(3)
        if frame_total < old_frame_total then
            dset(0, frame_total)
        end
    end
end

function draw_spots()
    for i=1, 7 ,1 do
        sspr(48, 0, 16, 8, slots[i], 105)
    end
end

function update_gameover()
    if btnp(⬇️) then
        reset_game()
    end
end

function draw_gameover()
    if failed_reason == 0 then
        --should have moved
        spr(76, 45, 20, 4, 4)
        cprint("bad lick", 60)
    elseif failed_reason == 1 then
        --should have licked
        pal(8, gameover_col)
        spr(72, 45, 20, 4, 4)
        pal()
        cprint("bad move", 60)
    elseif failed_reason == 2 then
        cprint("you win", 40, 7)

        if frame_total < old_frame_total then
            cprint("personal best!", 52, 7) --todo: make text flash
        end

        cprint(get_time_from_frames(tostr(frame_total, 2)), 65, 7)
    end

    cprint("⬇️ to try again", 100)
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
function cprint(s, y, c)
    print(s, 64 - (((#s * 4) - 1) / 2), y, c or 7)
end

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

function shuffle(t)
    -- do a fisher-yates shuffle
    for i = #t, 1, -1 do
      local j = flr(rnd(i)) + 1
      t[i], t[j] = t[j], t[i]
    end
  end
