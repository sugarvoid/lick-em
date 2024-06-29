--From paloblancogames
function oprint(str,x,y,c,co) --outline print
    for xx=-1,1,1 do
        for yy=-1,1,1 do
            print(str,x+xx,y+yy,co)
        end
    end
    print(str,x,y,c)
end