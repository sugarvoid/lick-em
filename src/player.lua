lick_frames = { 146, 148, 150, 152, 154, 152, 154, 150, 148, 146 }

player = {
    slot = 3,
    x = slots[3],
    y = 100,
    look_left = true,
    next_xpos = nil,
    dx = 0,
    moving = false,
    img_frame = 1,
    move = function(self)
        if self.look_left and self.slot ~= curr_human_slot + 1 then
            self.slot = self.slot - 1
            self.next_xpos = slots[self.slot]
            self.dx = -3
            self.moving = true
            sfx(1)
        elseif not self.look_left and self.slot ~= curr_human_slot - 1 then
            self.slot = self.slot + 1
            self.next_xpos = slots[self.slot]
            self.dx = 3
            self.moving = true
            sfx(1)
        else
            --should have licked
            goto_gameover(1)
        end
    end,
    lick = function (self)
        if self.slot == curr_human_slot - 1 or self.slot == curr_human_slot + 1 then
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
    end,
    update = function(self)
        self.look_left = curr_human_slot < self.slot

        if flr(self.x) ~= self.next_xpos then
            self.x += self.dx
        else
            self.moving = false
        end

        if not p_anim_played then
            tick += 1
            -- move to the next frame
            if flr(tick) == 1 then
                tick = 0
                self.img_frame = self.img_frame + 1
            end
            -- check if animation is finished
            if self.img_frame == #lick_frames then
                p_anim_played = true
                self.img_frame = 1
                animationfinished()
            end
        end
    end,
    draw = function(self)
        if self.moving then
            self.img = 156
        else
            self.img = lick_frames[self.img_frame]
        end

        spr(self.img, self.x, 83, 2, 3, not self.look_left)
    end,
    reset = function(self)
        self.img_frame = 1
    end,
}
