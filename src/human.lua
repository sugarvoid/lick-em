

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

