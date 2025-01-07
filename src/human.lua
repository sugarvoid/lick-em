humans={}

human={}
human.__index=human

-- function human:new()
--     local _h=setmetatable({},human)
--     _h.x=0
--     _h.y=0
-- 	_h.col=nil
--     _h.img=38
--     _h.peaked=false
--     _h.scared=false
--     _h.facing_l=true
--     return _h
-- end

function human:update()
    --sfx(1)
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
end

function human:draw()
    pal(8,self.col)
    spr(self.img,self.x,self.y,2,2,self.facing_l)
	pal()
end


function spawn_human(x_pos)
    local _h=setmetatable({},human)
    _h.x=x_pos
    _h.y=91
	_h.col=rnd(cols)
    _h.img=38
    _h.peaked=false
    _h.scared=false
    _h.facing_l=p1.look_left
    --active_human = _h
	add(humans,_h)
    return _h
end

