
obj= {
    new=function(self,tbl)
            tbl=tbl or {}
            setmetatable(tbl,{
                __index=self
            })
            return tbl
        end
}


function _init()
    cartdata("lickem_data")
    
	poke(0x5f5c, 255)
	game_state=0
    active_human=nil
    game_running=false
    user_high_score=nil
    sw_running=false
    title_choice=1
    showing_info=false
    title_options={"play", "info"}
    humans={}
    player_eat={146,148,150,152,154,152,154,150,148,146}
    player_move=156
    p_curr_frame=1
    p_anim_played=true
    p_anim_speed=1
    tick=0

    curr_human_slot=1

    future_slot = 6
    marker_y = 85
    m_delta = 0.2
    test_count=0
    slots={2,20,38,56,74,92,110}
    next_slot = 2
    
    p1 = {
        slot=3,
        x=slots[3],
        y=100,
        look_left=false,
        next_xpos=nil,
        dx=0,
        moving=false
    }
end

function start_game()
    test_count=0
    frame_total=0
    old_frame_total=dget(0)
    if old_frame_total==0 then 
        old_frame_total=8000000000
    end
    user_high_score=old_frame_total
    game_state=1
    timer_started=false
    licks_left=20
    failed_reason=nil
    active_human = spawn_human(slots[curr_human_slot])
    game_running=true
    p_curr_frame=1
end

function _update60()
	if game_state == 0 then
		u_main()
    elseif game_state == 1 then
            u_play()
            if sw_running then 
                frame_total+=(1/2)^16  --0.000015259 
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
end

function u_main()
    if btnp(⬅️) then title_choice-=1 end
    if title_choice==0 then title_choice=2 end
    if btnp(➡️) then title_choice+=1 end
    if title_choice==3 then title_choice=1 end
    
	if btnp(❎) then
        if title_choice==1 then start_game() end
        if title_choice==2 then show_info() end
    end

    if btnp(🅾️) and showing_info then showing_info=false end
        
end

function show_info()
    showing_info=true
end

function d_main()
	cls(1)
    if showing_info then
        cprint("how to play", 64, 20)
        cprint("- lick 20 guys", 64, 40)
        cprint("- 🅾️ to move", 64, 50)
        cprint("- ❎ to lick", 64, 60)
        cprint("how fast can you go?", 64, 75)
        cprint("🅾️ to go back", 64, 100)
    else
        sspr(0,32,8*8,4*8,26,30)
        print("⬅️", 42, 100, 7)
        print("➡️", 80, 100, 7)
        cprint(title_options[title_choice], 64, 100, 7)

    end
end

function draw_play()
	cls(0)
    rectfill(0,104,128,128,4)
	draw_spots()

    for h in all(humans) do
		h:draw()
	end

	draw_player()
	spr(17, slots[future_slot]+4, marker_y)
    print("⧗", 2, 2,10)
    print("⧗"..get_time_from_frames(tostr(frame_total,2)), 45, 35, 7)
    print(get_time_from_frames(tostr(user_high_score,2)), 10, 2,7)
    print("licks left:"..licks_left, 65, 2)
    draw_controls()
end


function draw_controls()
    
    if 1==1 then
        print("🅾️ move", 25, 120, 7)
	    print("❎ lick", 65, 120, 7)
    else
        print("🅾️ <--", 25, 120, 7)
	    print("❎  -->", 65, 120, 7)
    end

end

function draw_player()
    --print(get_time_from_frames(tostr(test_count, 2)), 60, 20, 7) --keep
	local px = slots[p1.slot]
    if p1.moving then
        p1.img = 156
    else
        p1.img = player_eat[p_curr_frame]
    end

    spr(p1.img,p1.x,83,2,3,not p1.look_left)

end


function u_play()
    update_player()
    for h in all(humans) do
		h:update()
	end

    marker_y += m_delta

    if marker_y <= 83 then 
        m_delta *=-1 
        
    elseif marker_y >= 89 then
        m_delta *=-1
    end

	if btnp(4) then move_p1() end 
	if btnp(5) then lick() end
end

function update_player()
    p1.look_left = curr_human_slot < p1.slot

    if flr(p1.x) ~= p1.next_xpos then
        p1.x+=p1.dx
    else
        p1.moving=false
    end

    if not p_anim_played then
        tick+=p_anim_speed
        -- move to the next frame
        if flr(tick)==1 then
            tick=0
            p_curr_frame = p_curr_frame + 1
        end
        -- check if animation is finished
        if p_curr_frame == #player_eat then
            p_anim_played = true
            p_curr_frame =1
            animationfinished() 
        end
      end 
	
end

function move_p1()
	if p1.look_left and p1.slot ~= curr_human_slot + 1 then
		p1.slot = p1.slot - 1
        p1.next_xpos = slots[p1.slot]
        p1.dx = -3
        p1.moving=true
        sfx(1)
	
    elseif not p1.look_left and p1.slot ~= curr_human_slot - 1 then
		p1.slot = p1.slot + 1
        p1.next_xpos = slots[p1.slot]
        p1.dx = 3
        p1.moving=true
        sfx(1)
	else
        --should have licked
        goto_gameover(1)
    end

end


function animationfinished()
    if game_running then
        active_human = spawn_human(slots[curr_human_slot])
        get_next()
    end
end

function goto_gameover(code)
    game_running=false
    p_anim_played = true
    for h in all(humans) do
        del(humans,h)
    end

    sw_running=false
    failed_reason=code
    if code==0 or code==1 then
        sfx(0)
    else
        sfx(3)
        --printh('saving: '..sw.f..", m"..sw.m..", s"..sw.m, 'save_time.txt')
        if frame_total < old_frame_total then
            dset(0, frame_total)
        end
    end

    game_state=2
end



function lick()
    
	if p1.slot == curr_human_slot - 1 or p1.slot == curr_human_slot + 1 then
        curr_human_slot = future_slot
		licks_left-=1
        p_anim_played=false
        if active_human then
            active_human.scared=true
        end
        active_human=nil
        sfx(4)
        if licks_left == 19 then
            sw_running=true -- wait until player has made one hit before starting timer
        elseif licks_left == 0 then
            goto_gameover(2)
        end
    else
        goto_gameover(0)
	end
end

function draw_spots()
	sspr(48,0,16,8,slots[1],106)
	sspr(48,0,16,8,slots[2],106)
	sspr(48,0,16,8,slots[3],106)
	sspr(48,0,16,8,slots[4],106)
	sspr(48,0,16,8,slots[5],106)
	sspr(48,0,16,8,slots[6],106)
	sspr(48,0,16,8,slots[7],106)
end

function u_gameover()
    if btnp(⬇️) then
        start_game()
    end
end

function d_gameover()
	cls(0)
    if failed_reason==0 then
        --should have licked
        spr(76, 45, 20, 4,4)
        print("bad lick", 30, 60,7)
    elseif failed_reason==1 then
        --should have moved
        spr(72, 45, 20, 4,4)
        print("bad move", 30, 60,7)
    elseif failed_reason==2 then
        print("you win", 30, 40,7)

        if frame_total < old_frame_total then 
            print("personal best!", 30, 52,7) --todo: make text flash 
        end
        
        print(get_time_from_frames(tostr(frame_total,2)), 30, 65, 7)
    end
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
function cprint(s, x, y)
    print(s, x - (((#s * 4) - 1) / 2), y)
  end


cols={8,9,10,11,}


human=obj:new({
	x,y=0,
	col=nil,
    img=38,
    peaked=false,
    scared=false,
    facing_l=true,
	
	update=function(self)
        if self.scared then 
            self.img=40
            self.y -=1
        end

        if self.y<=80 then 
            self.peaked=true
        end

        if self.peaked then 
            self.y+=4
        end

		if self.y >= 130 then
			del(humans,self)
		end

  	end,

	draw=function(self)
		pal(8,self.col)
        spr(self.img,self.x,self.y,2,2,self.facing_l)
        
		pal()
	end,
})

function spawn_human(x_pos)
	new_guy = human:new()
    new_guy.facing_l = p1.look_left
    new_guy.img =38
	new_guy.x=x_pos
	new_guy.y=91
	new_guy.col=rnd(cols)
	add(humans,new_guy)
    return new_guy
end


function get_time_from_frames(frame_total)
  local total_seconds = frame_total / 60  -- change to 30 is using _update()
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

function hcenter(s)
    -- screen center minus the
    -- string length times the
    -- pixels in a char's width,
    -- cut in half
    return 64 - #s * 2
end

function vcenter(s)
    -- screen center minus the
    -- string height in pixels,
    -- cut in half
    return 61
end

function shuffle(t)
    -- do a fisher-yates shuffle
    for i = #t, 1, -1 do
        local j = flr(rnd(i)) + 1
        t[i], t[j] = t[j], t[i]
    end
end
