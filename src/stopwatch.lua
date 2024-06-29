
-- stopwatch={

--     new=function(self,tbl)
--           tbl=tbl or {}
--           setmetatable(tbl,{
--               __index=self
--           })
--       tbl.running = false
--       tbl.m = 0
--       tbl.s = 0
--       tbl.f = 0
--       return tbl
--       end,
--     update=function(self)
--       if self.running then
--         self.f += 1
--         if self.f >= 60 then
--           self.f -= 60
--           self.s += 1
--         end
--         if self.s >= 60 then
--           self.s -= 60
--           self.m += 1
--         end
--       end
--     end,
--     draw=function(self,x,y,c)
--       print(self:get_string(), x, y,c)
--     end,
--     start=function(self)
--       self.running=true
--     end,
--     stop=function(self)
--       self.running=false
--     end,
--     reset=function(self)
--       self:stop()
--       self.m=0
--       self.s=0
--       self.f=0
--     end,
--     get_string=function(self)
--         -- convert frames into centiseconds
--         s_ss = sub(tostr(self.f/60), 3, 4)
      
--         -- grab strings for min, sec
--         s_s = tostr(self.s)
--         s_m = tostr(self.m)
      
--         -- two-zero pad all the above
--         if (#s_ss == 0) s_ss = "0"
--         if (#s_ss < 2) s_ss = s_ss.."0"
--         if (#s_s < 2) s_s = "0"..s_s
--         if (#s_m < 2) s_m = "0"..s_m
      
--         -- return a mm:ss.cc string
--         return s_m..":"..s_s.."."..s_ss
--     end
--   }

--   --old_f=0
--   --old_s=0
--   --old_m=0

--   get_string_sw=function(f,s,m)
--     -- convert frames into centiseconds
--     s_ss = sub(tostr(f/60), 3, 4)
  
--     -- grab strings for min, sec
--     s_s = tostr(s)
--     s_m = tostr(m)
  
--     -- two-zero pad all the above
--     if (#s_ss == 0) s_ss = "0"
--     if (#s_ss < 2) s_ss = s_ss.."0"
--     if (#s_s < 2) s_s = "0"..s_s
--     if (#s_m < 2) s_m = "0"..s_m
  
--     -- return a mm:ss.cc string
--     return s_m..":"..s_s.."."..s_ss
-- end

-- get_string_sw=function(f,s,m)
--   -- convert frames into centiseconds
--   s_ss = sub(tostr(f/60), 3, 4)

--   -- grab strings for min, sec
--   s_s = tostr(s)
--   s_m = tostr(m)

--   -- two-zero pad all the above
--   if (#s_ss == 0) s_ss = "0"
--   if (#s_ss < 2) s_ss = s_ss.."0"
--   if (#s_s < 2) s_s = "0"..s_s
--   if (#s_m < 2) s_m = "0"..s_m

--   -- return a mm:ss.cc string
--   return s_m..":"..s_s.."."..s_ss
-- end



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


