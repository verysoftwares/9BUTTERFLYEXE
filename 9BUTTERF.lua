-- title:   9BUTTERF.EXE
-- author:  verysoftwares
-- desc:    recursive bullet hell
-- site:    https://verysoftwares.itch.io
-- script:  lua
-- saveid:  9BUTTERF

stage=1

t=0
x=240/2-1
y=96
cx,cy=240/2,136/2+16-1
x,y=cx+1,cy+1
sin=math.sin
cos=math.cos
pi=math.pi
atan2=math.atan2
r=136/2-16-2
coins=0

function update()
  if stage==1 then poke(0x3FF8,0)
  elseif stage==2 then poke(0x3FF8,7)
  elseif stage==3 then poke(0x3FF8,5)
  end
  cls(8)

  local act=cur_board.active2
  if hourglass then hourglass_tick=false end
  if btn(0) and not holdkey and cur_board.active then cur_board.active2=true; if hourglass then hourglass_tick=true end; if r>0 then r=r-1 end end
  if btn(1) and not holdkey and cur_board.active then cur_board.active2=true; if hourglass then hourglass_tick=true end; if r<136/2-16-2 then r=r+1 end end
  if btn(2) and not holdkey and cur_board.active then cur_board.active2=true; if hourglass then hourglass_tick=true end; for i,b in ipairs(cur_board.bullets) do if b.a then b.a=b.a-0.02 end; if b.a2 then b.a2=b.a2-0.02 end; if b.a3 then local ba=atan2(b.y-cur_board.cy,b.x-cur_board.cx); local bd=math.sqrt((b.y-cur_board.cy)^2+(b.x-cur_board.cx)^2); ba=ba-0.02; b.x=cur_board.cx+cos(ba)*bd; b.y=cur_board.cy+sin(ba)*bd; b.a3=b.a3-0.02 end end; cur_board.a=cur_board.a-0.02 end
  if btn(3) and not holdkey and cur_board.active then cur_board.active2=true; if hourglass then hourglass_tick=true end; for i,b in ipairs(cur_board.bullets) do if b.a then b.a=b.a+0.02 end; if b.a2 then b.a2=b.a2+0.02 end; if b.a3 then local ba=atan2(b.y-cur_board.cy,b.x-cur_board.cx); local bd=math.sqrt((b.y-cur_board.cy)^2+(b.x-cur_board.cx)^2); ba=ba+0.02; b.x=cur_board.cx+cos(ba)*bd; b.y=cur_board.cy+sin(ba)*bd; b.a3=b.a3+0.02 end end; cur_board.a=cur_board.a+0.02 end
  if btnp(4) and pmem(5)>0 and not evade then
    evade=true
    pmem(5,pmem(5)-1)
  end
  if btnp(5) and pmem(7)>0 then
    if (stage==1 and #boards<4) or
       (stage==2 and #boards<5) or
       (stage==3 and #boards<7) then
    push_board()
    hourglass=false
    pmem(7,pmem(7)-1)
    end
  end
  if btnp(6) and pmem(8)>0 then
    cur_board.t=cur_board.t-5*60
    if cur_board.t>0 then
      drip_coin()
    else
      cur_board.t=0
      pop_board(true)
      hourglass=false    
    end
    pmem(8,pmem(8)-1)
  end
  if btnp(7) and pmem(6)>0 and not hourglass then
    hourglass=true
    pmem(6,pmem(6)-1)
  end
  if not act and cur_board.active2 then 
    -- first frame of player action
    sc_t=t 
    if stage==1 and #boards==1 and peek(0x13FFC)~=0 then music(0) end
    if stage==2 and #boards==1 and peek(0x13FFC)~=1 then music(1) end
    if stage==3 and #boards==1 and peek(0x13FFC)~=3 then music(3) end
  end
  if holdkey then
    local press=false 
    for i=0,3 do if btn(i) then press=true; break end end 
    if not press then holdkey=false end
  end
 
  for i=#boards,1,-1 do
    local bd=boards[i]
    render_board(i,bd)
  end
    
  --[[table.sort(bullets,function(a,b) return a.y<b.y end)
  for i,b in ipairs(bullets) do
    local s=(b.y-48)*0.3
    ttri(b.x-s/2,16-s/2,b.x+s/2,16-s/2,b.x-s/2,16+s/2,
         2*8,2*8,2*8+6,2*8,2*8,2*8+6,0,8
        )
    ttri(b.x+s/2,16-s/2,b.x+s/2,16+s/2,b.x-s/2,16+s/2,
         2*8+6,2*8,2*8+6,2*8+6,2*8,2*8+6,0,8
        )
  end]]
  
  local ty=16
  for i=0,3 do
    local sp
    if i==0 then sp=64 end
    if i==1 then sp=70 end
    if i==2 then sp=73 end
    if i==3 then sp=67 end
    local mem
    if i==0 then mem=pmem(5) end
    if i==1 then mem=pmem(7) end
    if i==2 then mem=pmem(8) end
    if i==3 then mem=pmem(6) end
    local bn
    if i==0 then bn='Z' end
    if i==1 then bn='X' end
    if i==2 then bn='A' end
    if i==3 then bn='S' end
    if mem>0 then
      circb(boards[1].cx-80,ty,16,13)
      spr(sp,boards[1].cx-80-12+1,ty-12+1,8,1,0,0,3,3)
      circ(boards[1].cx-80-16-1,ty-6-1,6,8)
      circb(boards[1].cx-80-16-1,ty-6-1,6,13)
      circ(boards[1].cx-80+16+1,ty+6+1,6,8)
      circb(boards[1].cx-80+16+1,ty+6+1,6,6)
      print(mem,boards[1].cx-80-16-print(mem,0,-6,0,false,1,true)/2,ty-6-1-2,13,false,1,true)
      print(bn,boards[1].cx-80+16+1-1,ty+6+1-2,12,false,1,true)
      ty=ty+32+2
    end
  end
  
  local tw=print(string.format('x%d',coins),0,-6)
  print(string.format('x%d',coins),240-1-tw,136-7,3)
  spr(36,240-1-tw-8-1,136-8,8)
  
  if cur_board.active and not cur_board.active2 then
    local tw=print('Press arrow keys to start.',0,-6,0,false,1,true)
    print('Press arrow keys to start.',cur_board.cx-tw/2,cur_board.cy-3,13,false,1,true)
  end
  
  t=t+1
end

function render_board(index,bd)
  local diff=(bd.tcx-bd.cx)*0.1
  if TIC==update or TIC==gameover then  
  bd.cx=bd.cx+diff
  for i2,b in ipairs(bd.bullets) do b.x=b.x+diff end
  end
  
  if lup_trans and math.abs(diff)<0.1 then
  local msg='LEVEL UP'
  for i=1,#msg do
    local char=string.sub(msg,i,i)
    print(char,240/2-6,2+(i-1)*12,t*0.4%16,false,2,false)
  end
  end
    
  if bd==cur_board and math.abs(diff)<0.1 then bd.active=true end
  if bd.active2 then lup_trans=false; ldn_trans=false; 
    if TIC==update and (not hourglass) or (hourglass and hourglass_tick) then 
    bd.algo(bd) 
    end
  end
  
  if TIC==update and bd==cur_board and bd.active2 then 
    if (not hourglass) or (hourglass and hourglass_tick) then
    bd.t=bd.t-1 
    if bd.t>0 and bd.t%(5*60)==0 then drip_coin() end
    if bd.t<=0 then
      pop_board(true)
      hourglass=false
    end
    end
  end

  local lc=0
  if stage==2 then lc=7 end
  if stage==3 then lc=5 end
  if stage==4 then lc=9 end
  if TIC==stagesel then lc=10 end
  for i=0,360-1,0.25 do
    local i2=(i-bd.a*180/pi)%360
    if i2<90 or (i2>=180 and i2<270) then
    line(bd.cx,bd.cy,bd.cx+cos(i*pi/180)*(136/2-16),bd.cy+sin(i*pi/180)*(136/2-16),lc)
    end
  end

  circb(bd.cx,bd.cy,136/2-16,13)

  if bd==cur_board and bd.active2 then table.sort(bd.bullets,function(a,b) return a.id<b.id end) end
  for i=#bd.bullets,1,-1 do
    local b=bd.bullets[i]
    if bd==cur_board and bd.active2 and ((not hourglass) or (hourglass and hourglass_tick)) then 
    if not b.a3 then
    b.x=b.cx+cos(b.a)*b.r; b.y=b.cy+sin(b.a)*b.r
    if b.a2 then
    b.x=b.x+cos(b.a2)*b.r2; b.y=b.y+sin(b.a2)*b.r2
    end
    end
    if b.id~=36 and b.id~=37 and b.id~=38 and b.id~=39 and b.id~=41 and b.id~=43 then 
      if not b.a2 and not b.a3 then
      b.r=b.r+b.spd 
      end
      if b.a2 then b.r2=b.r2-b.spd end
      if b.a3 then b.x=b.x+cos(b.a3)*(-b.spd); b.y=b.y+sin(b.a3)*(-b.spd) end
    end    
    end

    if b.id==34 then spr(b.id,b.x-3,b.y-3,8) end
    if b.id==35 then 
      if (TIC==update or TIC==ldown or TIC==spawn_coins) and stage==2 then pal(0,7) end
      if (TIC==update or TIC==ldown or TIC==spawn_coins) and stage==3 then pal(0,5) end
      if (TIC==update or TIC==ldown or TIC==spawn_coins) and stage==4 then pal(0,9) end
      if TIC==stagesel and b.label=='Stage 1' then pal(0,0) end
      if TIC==stagesel and b.label=='Stage 2' then pal(0,7) end
      if TIC==stagesel and b.label=='Stage 3' then pal(0,4) end
      if TIC==stagesel and b.label=='Stage 4' then pal(0,9) end
      if TIC==stagesel and b.label=='Shoppe' then pal(0,10) end
      spr(b.id,b.x-4,b.y-4,9) 
      pal()
      if b.label then
        local txc=13
        if b.label=='Stage 2' and pmem(0)<1 then txc=6 end
        if b.label=='Stage 3' and pmem(1)<10 then txc=6 end
        if b.label=='Stage 4' and pmem(4)<100 then txc=6 end
        local tw=print(b.label,0,-6,0,false,1,true)
        print(b.label,b.x-tw/2,b.y-12,txc,false,1,true)
      end
      if bd==cur_board and math.sqrt((bd.cx+cos(pi/2)*r-b.x)^2+(bd.cy+sin(pi/2)*r-b.y)^2)<=4 then
        if TIC==update then 
        push_board()
        hourglass=false
        table.remove(bd.bullets,i)
        elseif TIC==stagesel then
          if b.label=='Stage 1' then
            init_board(1)
          elseif b.label=='Stage 2' then
            init_board(2)
          elseif b.label=='Stage 3' then
            init_board(3)
          elseif b.label=='Stage 4' then
            init_board(4)
          elseif b.label=='Shoppe' then
            TIC=shoppe
          else
            local msg=string.format('%s not available in demo.',b.label)
            local tw=print(msg,0,-6,0,false,1,true)
            print(msg,240/2-tw/2+1,cur_board.cy-3,13,false,1,true)
          end
          
        end
      end
    end
    if b.id==36 then 
      spr(b.id,b.x-4,b.y-4,8) 
      if bd==cur_board and math.sqrt((bd.cx+cos(pi/2)*r-b.x)^2+(bd.cy+sin(pi/2)*r-b.y)^2)<=4 then
        coins=coins+1
        sfx(5,'E-5',64,3)
        table.remove(bd.bullets,i)
      end
    end
    if b.id==37 then 
      spr(b.id,b.x-4,b.y-4,8) 
      if bd==cur_board and math.sqrt((bd.cx+cos(pi/2)*r-b.x)^2+(bd.cy+sin(pi/2)*r-b.y)^2)<=4 then
        coins=coins+2
        sfx(5,'E-5',64,3)
        table.remove(bd.bullets,i)
      end
    end
    if b.id==38 then 
      spr(b.id,b.x-4,b.y-4,8) 
      if bd==cur_board and math.sqrt((bd.cx+cos(pi/2)*r-b.x)^2+(bd.cy+sin(pi/2)*r-b.y)^2)<=4 then
        coins=coins+5
        sfx(5,'E-5',64,3)
        table.remove(bd.bullets,i)
      end
    end
    if b.id==39 then 
      spr(b.id,b.x-8,b.y-8,8,1,0,0,2,2) 
      if bd==cur_board and math.sqrt((bd.cx+cos(pi/2)*r-b.x)^2+(bd.cy+sin(pi/2)*r-b.y)^2)<=8 then
        coins=coins+10
        sfx(5,'E-5',64,3)
        table.remove(bd.bullets,i)
      end
    end
    if b.id==41 then 
      spr(b.id,b.x-8,b.y-8,8,1,0,0,2,2) 
      if bd==cur_board and math.sqrt((bd.cx+cos(pi/2)*r-b.x)^2+(bd.cy+sin(pi/2)*r-b.y)^2)<=8 then
        coins=coins+20
        sfx(5,'E-5',64,3)
        table.remove(bd.bullets,i)
      end
    end
    if b.id==43 then 
      spr(b.id,b.x-8,b.y-8,8,1,0,0,2,2) 
      if bd==cur_board and math.sqrt((bd.cx+cos(pi/2)*r-b.x)^2+(bd.cy+sin(pi/2)*r-b.y)^2)<=8 then
        coins=coins+50
        sfx(5,'E-5',64,3)
        table.remove(bd.bullets,i)
      end
    end
    if math.sqrt((b.x-bd.cx)^2+(b.y-bd.cy)^2)>=136/2-16 then table.remove(bd.bullets,i) end
  end
  
  local evade_act2=false
  if bd==cur_board then
  if evade then pal(11,2) end
  spr(32+(t*0.1)%2,bd.cx+cos(pi/2)*r-3,bd.cy+sin(pi/2)*r-5,8)
  pal()
  for sx=1,2 do for sy=1,2 do
    local p=pix(bd.cx+cos(pi/2)*r-3+sx+2,bd.cy+sin(pi/2)*r-5+sy+3)
    if (p==6 or p==4) and TIC==update and bd.active2 then
      if evade then
        if not evade_act then evade_act=true end
        evade_act2=true
        trace(p,10)
        goto endplr
      else
        pop_board(false)
        hourglass=false
        ldn_trans=true
        goto endplr
      end
    end
    pix(bd.cx+cos(pi/2)*r-3+sx+2,bd.cy+sin(pi/2)*r-5+sy+3,13)
  end end
  ::endplr::
  if evade_act and not evade_act2 then evade=false; evade_act=false end
  end
  
  if TIC==update or TIC==ldown or TIC==spawn_coins then
  local tw=print(string.format('Level %d',index),0,-12,0,false,2,false)
  print(string.format('Level %d',index),bd.cx-tw/2,4,13,false,2,false)
  local tw=print(string.format('%.2d:%.2d',math.floor(bd.t/60),math.floor(bd.t%60*100/60)),0,-12,0,false,2,false)
  print(string.format('%.2d:%.2d',math.floor(bd.t/60),math.floor(bd.t%60*100/60)),bd.cx-tw/2,16,11,false,2,false)
  elseif TIC==stagesel then
  local msg='Select stage'
  local tw=print(msg,0,-12,0,false,2,false)
  local tx=0
  for i=1,#msg do
  tx=tx+print(string.sub(msg,i,i),bd.cx-tw/2+tx,8+sin(i+t*0.2)*2+sin(i+t*0.07)*3,13,false,2,false)
  end
  end
end

function push_board()
  --for i2,bd2 in ipairs(boards) do bd2.tcx=bd2.tcx-60 end
  local tt=math.random(10,100)*0.1
  local ti
  local bt
  local spd
  if stage==1 then 
    ti=math.max(3-#boards+1,1)
    if #boards==1 then bt=20*60 end
    if #boards==2 then bt=10*60 end
    if #boards==3 then bt=5*60 end
    if #boards==1 then spd=0.5 end
    if #boards==2 then spd=0.65 end
    if #boards==3 then spd=0.8 end
  elseif stage==2 then 
    ti=math.max(4-#boards+1,1) 
    if #boards==1 then bt=40*60 end
    if #boards==2 then bt=20*60 end
    if #boards==3 then bt=10*60 end
    if #boards==4 then bt=5*60 end
    if #boards==1 then spd=0.5 end
    if #boards==2 then spd=0.6 end
    if #boards==3 then spd=0.7 end
    if #boards==4 then spd=0.8 end
  elseif stage==3 then 
    ti=math.max(6-#boards+1,1)
    if #boards==1 then bt=60*60 end
    if #boards==2 then bt=40*60 end
    if #boards==3 then bt=20*60 end
    if #boards==4 then bt=10*60 end
    if #boards==5 then bt=5*60 end
    if #boards==6 then bt=40 end
    if #boards==1 then spd=0.5 end
    if #boards==2 then spd=0.75 end
    if #boards==3 then spd=0.25 end
    if #boards==4 then spd=0.85 end
    if #boards==5 then spd=1.0 end
    if #boards==6 then spd=1.25 end
  elseif stage==4 then 
    ti=math.max(11-#boards+1,1)
    if #boards==1 then bt=60*60 end
    if #boards==2 then bt=40*60 end
    if #boards==3 then bt=20*60 end
    if #boards==4 then bt=10*60 end
    if #boards==5 then bt=5*60 end
    if #boards==6 then bt=40 end
    if #boards==1 then spd=0.5 end
    if #boards==2 then spd=0.75 end
    if #boards==3 then spd=0.25 end
    if #boards==4 then spd=0.85 end
    if #boards==5 then spd=1.0 end
    if #boards==6 then spd=1.25 end
  end
  boards[#boards].pr=r
  boards[#boards].tt=t+1
  if stage==1 then
  table.insert(boards,{cx=240,cy=cy,tcx=240/2+136/2-10,a=pi/2,bullets={},t=bt,px=x,py=y,algo=function(bd) 
  if cur_board.t%ti==0 then 
  local id=34
  if ti>1 and cur_board.t%24==0 then id=35 end
  table.insert(cur_board.bullets,{x=cur_board.cx,y=cur_board.cy,cx=cur_board.cx,cy=cur_board.cy,r=0,a=t*tt+cur_board.a,spd=spd,id=id}) 
  table.insert(cur_board.bullets,{x=cur_board.cx,y=cur_board.cy,cx=cur_board.cx,cy=cur_board.cy,r=0,a=-(t*tt)+cur_board.a,spd=spd,id=id}) 
  end
  end})
  elseif stage==2 then
  table.insert(boards,{cx=240,cy=cy,tcx=240/2+136/2-10,a=pi/2,bullets={},t=bt,px=x,py=y,algo=function(bd) 
  if cur_board.t%ti==0 then 
  local id=34
  if ti>1 and cur_board.t%24==0 then id=35 end
  for i=0,2 do
  table.insert(cur_board.bullets,{x=cur_board.cx,y=cur_board.cy,cx=cur_board.cx,cy=cur_board.cy,r=i*4/3,a=t*tt+cur_board.a+i*0.05*4/3,spd=spd,id=id}) 
  table.insert(cur_board.bullets,{x=cur_board.cx,y=cur_board.cy,cx=cur_board.cx,cy=cur_board.cy,r=i*4/3,a=-(t*tt+i*0.05*4/3)+cur_board.a,spd=spd,id=id}) 
  end
  end
  end})
  elseif stage==3 then
  table.insert(boards,{cx=240,cy=cy,tcx=240/2+136/2-10,a=pi/2,bullets={},t=bt,px=x,py=y,algo=function(bd) 
  if cur_board.t%(ti*4)==0 then 
  local id=34
  if (#boards~=4 and #boards~=2 and ti>1 and cur_board.t%24==0) or (#boards==4 and t%(24*3)==0) or (#boards==2 and t%28==0) then id=35 end
  for i=0,8-1 do
  table.insert(cur_board.bullets,{x=cur_board.cx,y=cur_board.cy,cx=cur_board.cx,cy=cur_board.cy,r=42-2,a=(t-sc_t)*tt*(0.006+(#boards-2)*0.001)+cur_board.a+i/8*2*pi*pi/180+pi,a2=t*tt+i/8*2*pi,r2=10,spd=spd,id=id}) 
  if #boards>3 then
  table.insert(cur_board.bullets,{x=cur_board.cx,y=cur_board.cy,cx=cur_board.cx,cy=cur_board.cy,r=42-2,a=-((t-sc_t)*tt*(0.006+(#boards-2)*0.001)+cur_board.a+i/8*2*pi*pi/180+pi),a2=-(t*tt+i/8*2*pi),r2=10,spd=spd,id=id}) 
  end
  end
  end
  end})
  elseif stage==4 then
  table.insert(boards,{cx=240,cy=cy,tcx=240/2+136/2-10,a=pi/2,bullets={},t=bt,px=x,py=y,algo=function(bd) 
  if cur_board.t%(ti)==0 then 
  local id=34
  local a=cur_board.t*tt
  table.insert(cur_board.bullets,{x=cur_board.cx+cos(a+cur_board.a)*48,y=cur_board.cy+sin(a+cur_board.a)*48,a3=atan2(cur_board.cy+sin(pi/2)*r-5-(cur_board.cy+sin(a+cur_board.a)*48),cur_board.cx+cos(pi/2)*r-3-(cur_board.cx+cos(a+cur_board.a)*48)),spd=-spd,id=id})
  end
  end})
  end
  boards[#boards-1].tcx=240/2-60
  boards[#boards-1].active=false
  boards[#boards-1].active2=false
  if boards[#boards-2] then boards[#boards-2].tcx=-80 end
  cur_board=boards[#boards]
  --table.remove(boards[#boards-1].bullets,bulindex)
  lup_trans=true
end

function pop_board(win)
  if #boards>2 then
    boards[#boards-1].tcx=240/2+60
    if boards[#boards-2] then boards[#boards-2].tcx=240/2-60 end
  elseif #boards>1 then
    boards[#boards-1].tcx=240/2
  else
    boards[#boards].active=false
    boards[#boards].active2=false
    TIC=gameover
    music()
    return
  end  
  if win then 
    cur_board=boards[#boards-1]
    cur_board.active=false
    cur_board.active2=false
    TIC=spawn_coins 
  else
    cur_board.active=false
    cur_board.active2=false
    TIC=ldown
  end
end

function init_board(n)
  if n==1 then
  boards={
  {cx=cx,cy=cy,tcx=cx,a=pi/2,bullets={},t=60*60,algo=function(bd)
  megati= megati or 16
  if t>0 and t%240==0 and megati>3 then megati=megati-1 end
  if t%megati==0 then 
  local id=34
  if t%24==0 then id=35 end
  table.insert(cur_board.bullets,{x=bd.cx,y=bd.cy,cx=bd.cx,cy=bd.cy,r=0,a=t*6.1+cur_board.a,spd=0.5,id=id}) 
  table.insert(cur_board.bullets,{x=bd.cx,y=bd.cy,cx=bd.cx,cy=bd.cy,r=0,a=-(t*6.1)+cur_board.a,spd=0.5,id=id}) 
  end
  end},
  }
  cur_board=boards[#boards]
  TIC=update
  stage=1
  holdkey=true
  music()
  elseif n==2 then
  if pmem(0)>=1 then
  boards={
  {cx=cx,cy=cy,tcx=cx,a=pi/2,bullets={},t=90*60,algo=function(bd)
  megati= megati or 12
  if t>0 and t%240==0 and megati>3 then megati=megati-1 end
  if t%megati==0 then 
  local id=34
  if t%24==0 then id=35 end
  for i=0,2 do
  table.insert(cur_board.bullets,{x=bd.cx,y=bd.cy,cx=bd.cx,cy=bd.cy,r=i*4/3,a=t*6.1+cur_board.a,spd=0.5,id=id}) 
  table.insert(cur_board.bullets,{x=bd.cx,y=bd.cy,cx=bd.cx,cy=bd.cy,r=i*4/3,a=-(t*6.1)+cur_board.a,spd=0.5,id=id}) 
  end
  end
  end},
  }
  cur_board=boards[#boards]
  TIC=update
  stage=2
  holdkey=true
  music()
  else
    local msg='Earn $1 in Stage 1 to unlock!'
    local tw=print(msg,0,-6,0,false,1,true)
    print(msg,240/2-tw/2+1,cur_board.cy-3,13,false,1,true)
  end
  elseif n==3 then
  if pmem(1)>=10 then
  boards={
  {cx=cx,cy=cy,tcx=cx,a=pi/2,bullets={},t=100*60,algo=function(bd)
  megati= megati or 18
  if t>0 and t%240==0 and megati>3 then megati=megati-1 end
  if cur_board.t<30*60 then megati=12 end
  if t%megati==0 then 
  local id=34
  if (cur_board.t>=30*60 and t%24==0) or (cur_board.t<30*60 and t%(24*3)==0) then id=35 end
  if cur_board.t>=60*60 then
  for i=0,8-1 do
  table.insert(cur_board.bullets,{x=bd.cx,y=bd.cy,cx=bd.cx,cy=bd.cy,r=1,a=t*6.1+cur_board.a,a2=i/8*2*pi,r2=10,spd=-0.5,id=id}) 
  end
  elseif cur_board.t>=30*60 then
  for i=0,8-1 do
  table.insert(cur_board.bullets,{x=bd.cx,y=bd.cy,cx=bd.cx,cy=bd.cy,r=1,a=t*16.1+i/8*2*pi,a2=t*16.1+i/8*2*pi,r2=10,spd=0.5,id=id}) 
  end
  else
  for i=0,8-1 do
  table.insert(cur_board.bullets,{x=bd.cx+cos(t*0.02)*20,y=bd.cy,cx=bd.cx+cos(t*0.02)*20,cy=bd.cy,r=1,a=t*6.1+cur_board.a,a2=i/8*2*pi,r2=10,spd=0.5,id=id}) 
  table.insert(cur_board.bullets,{x=bd.cx-cos(t*0.02)*20,y=bd.cy,cx=bd.cx-cos(t*0.02)*20,cy=bd.cy,r=1,a=-t*6.1+cur_board.a,a2=i/8*2*pi,r2=10,spd=0.5,id=id}) 
  end
  end
  end
  end},
  }
  cur_board=boards[#boards]
  TIC=update
  stage=3
  holdkey=true
  music()
  else
    local msg='Earn $10 in Stage 2 to unlock!'
    local tw=print(msg,0,-6,0,false,1,true)
    print(msg,240/2-tw/2+1,cur_board.cy-3,13,false,1,true)
  end
  elseif n==4 then
  if pmem(4)>=100 then
  boards={
  {cx=cx,cy=cy,tcx=cx,a=pi/2,bullets={},t=100*60,algo=function(bd)
  shutter=shutter or 4
  if t%180==0 then shutter=shutter+1 end
  if t%120==0 then
  for i=0,shutter-1 do
    local a=2*pi/(shutter)*i
    local id=34
    if (t+i)%6==0 then id=35 end
    table.insert(cur_board.bullets,{x=cur_board.cx+cos(a+cur_board.a)*48,y=cur_board.cy+sin(a+cur_board.a)*48,cx=cur_board.cx,cy=cur_board.cy,a3=atan2(cur_board.cy+sin(pi/2)*r-5-(cur_board.cy+sin(a+cur_board.a)*48),cur_board.cx+cos(pi/2)*r-3-(cur_board.cx+cos(a+cur_board.a)*48)),spd=-0.5,id=id})
  end
  end
  end},
  }
  cur_board=boards[#boards]
  TIC=update
  stage=4
  holdkey=true
  music()
  r=16
  else
    local msg='Earn $100 total to unlock!'
    local tw=print(msg,0,-6,0,false,1,true)
    print(msg,240/2-tw/2+1,cur_board.cy-3,13,false,1,true)
  end
  end
end

function spawn_coins()
  cls(8)
  for i,bd in ipairs(boards) do
    render_board(i,bd)
  end

  local msg='LEVEL CLEAR'
  for i=1,#msg do
    local char=string.sub(msg,i,i)
    print(char,240/2-6,2+(i-1)*12,t*0.4%16,false,2,false)
  end
   
  t=t+1
  local tbid=36
  if #boards==3 then tbid=37 end
  if #boards==4 then tbid=38 end
  if #boards==5 then tbid=39 end
  if #boards==6 then tbid=41 end
  if #boards==7 then tbid=43 end
  local hit=0
  for i,b in ipairs(cur_board.bullets) do
    if b.id~=tbid then 
      b.id=tbid
      hit=hit+1
      -- there's something funky happening here.
      -- the game seems to hang and hit every frame
      trace(hit)
      trace(i,3)
      if hit>=6 then
        sfx(5,'E-5',64,3)
        return
      end
    end
  end
  for i=0,3 do if btn(i) then
    TIC=update
    table.remove(boards,#boards)
    r=cur_board.pr
    t=cur_board.tt
    return
  end end
end

function drip_coin()
  if #boards==1 then return end
  
  local bd=boards[#boards-1]
  local tbid=36
  if #boards==3 then tbid=37 end
  if #boards==4 then tbid=38 end
  if #boards==5 then tbid=39 end
  if #boards==6 then tbid=41 end
  if #boards==7 then tbid=43 end
  
  for i,b in ipairs(bd.bullets) do
    if b.id~=tbid then
      b.id=tbid
      sfx(5,'E-5',64,3)
      return
    end
  end
end

function ldown()
  cls(8)

  for i,bd in ipairs(boards) do
    render_board(i,bd)
  end

  local msg='LEVEL DOWN'
  for i=1,#msg do
    local char=string.sub(msg,i,i)
    print(char,240/2-6,2+(i-1)*12,t*0.4%16,false,2,false)
  end

  local tw=print(string.format('x%d',coins),0,-6)
  print(string.format('x%d',coins),240-1-tw,136-7,3)
  spr(36,240-1-tw-8-1,136-8,8)  

  t=t+1

  for i=0,3 do if btnp(i) then
    TIC=update
    table.remove(boards,#boards)
    cur_board=boards[#boards]
    cur_board.active=false
    cur_board.active2=false
    r=cur_board.pr
    t=cur_board.tt
    return
  end end
end

function gameover()
  cls(8)
  for i,bd in ipairs(boards) do
    render_board(i,bd)
  end
  if boards[#boards].tcx>0 then
    local msg='GAME'
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      print(char,240/2-60-6,62-6+(i-1)*12,t*0.4%16,false,2,false)
    end    
    local msg='OVER'
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      print(char,240/2+60-6,62-6+(i-1)*12,t*0.4%16,false,2,false)
    end    
  end
  for i=0,3 do if btnp(i) and not xresults then
    boards[#boards].tcx=-80
    xresults=240
    if pmem(0)<1 and stage==1 and coins>=1 then pmem(100,1) end
    if pmem(1)<10 and stage==2 and coins>=10 then pmem(101,1) end
    local total=pmem(4)
    pmem(4,pmem(4)+coins)
    if total<100 and pmem(4)>=100 then pmem(102,1) end
    if coins>pmem(stage-1) then hiscore=true; pmem(stage-1,coins) end
  end end
  
  if xresults then
    xresults=xresults+(76-xresults)*0.1
    spr(36,xresults,24,8,4)
    print(string.format('x%d',coins),xresults+8*4+4,24+4,13,false,4,false)
    if hiscore then print('New high score!',xresults,64,t*0.4%16) end
    print('Press R to reset.',xresults,64+16,13)
    if keyp(18) then reset() end
  end
  t=t+1
end

sel=1
function stagesel()
  cls(8)
  if btnp(0) then sel=sel-1; if sel<1 then sel=4 end end
  if btnp(1) then sel=sel+1; if sel>4 then sel=1 end end
  for i=1,4 do
    local msg=string.format('Stage %d',i)
    if i==sel then msg='>'..msg..'<' end
    print(msg,4+(i-1)*20,48+(i-1)*20,i,false,4,true)
  end
  t=t+1
end

function stagesel()
  cls(8)
  poke(0x3FF8,10)
  
  if btn(0) and cur_board.active then cur_board.active2=true; if r>0 then r=r-1 end end
  if btn(1) and cur_board.active then cur_board.active2=true; if r<136/2-16-2 then r=r+1 end end
  if btn(2) and cur_board.active then cur_board.active2=true; for i,b in ipairs(cur_board.bullets) do b.a=b.a-0.02 end; cur_board.a=cur_board.a-0.02 end
  if btn(3) and cur_board.active then cur_board.active2=true; for i,b in ipairs(cur_board.bullets) do b.a=b.a+0.02 end; cur_board.a=cur_board.a+0.02 end

  for i,bd in ipairs(boards) do
    render_board(i,bd)
  end

  if cur_board.active and not cur_board.active2 then
    local tw=print('Arrow keys to',0,-6,0,false,1,true)
    print('Arrow keys to',cur_board.cx-tw/2,cur_board.cy-6,13,false,1,true)
    local tw=print('control the butterfly.',0,-6,0,false,1,true)
    print('control the butterfly.',cur_board.cx-tw/2,cur_board.cy,13,false,1,true)
  end

  local tw=print(string.format('x%d',pmem(4)),0,-6)
  print(string.format('x%d',pmem(4)),240-1-tw,136-7,3)
  spr(36,240-1-tw-8-1,136-8,8)

  print('Press C for credits.',0,136-6,9+t*0.1%5,false,1,true)
  if keyp(03) then TIC=credits end

  t=t+1
end

-- palette swapping by BORB
  function pal(c0,c1)
    if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i) end
    else poke4(0x3FF0*2+c0,c1) end
  end

TIC=update
poke(0x3FF8,0)

--poke(0x3FF8,7)

TIC=stagesel

boards={
{cx=cx,cy=cy,tcx=cx,a=pi/2,bullets={
},t=999*60,algo=function(bd) end},
}
cur_board=boards[#boards]
for i=1,4 do
  local r,a=136/2-16-2-2,-pi*(i-1)/3
  local label=string.format('Stage %d',i)
  if i==4 then label='Shoppe' end
  table.insert(cur_board.bullets,{
    id=35,label=label,
    r=r,a=a,spd=0,
    x=cur_board.cx+cos(a)*r,y=cur_board.cy+sin(a)*r,
    cx=cur_board.cx,cy=cur_board.cy
  })
end
--pmem(0,0)
--pmem(0,1)
--pmem(0,1)
--pmem(1,10)
--pmem(2,0)

function unlock_modal()
  cls(8)
  local msg='UNLOCKED'
  for i=1,#msg do
    local char=string.sub(msg,i,i)
    print(char,240/2-6-12,2+(i-1)*12,t*0.4%16,false,2,false)
  end
  local msg=string.format('STAGE %d',ul-100+2)
  for i=1,#msg do
    local char=string.sub(msg,i,i)
    print(char,240/2+6,52+(i-1)*12,t*0.4%16,false,2,false)
  end
  for i=0,3 do if btnp(i) then unlock() end end
  t=t+1
end

function unlock()
  for i=100,101 do
    if pmem(i)>0 then
      pmem(i,0)
      ul=i
      TIC=unlock_modal
      sfx(4,'E-4',64,0)
      return
    end
  end
  TIC=stagesel
  music(2)
end

unlock()
--TIC=unlock

function shoppe()
  cls(8)
  
  --rect(0,0,240/2,136/2,8)
  --rect(240/2,136/2,240/2,136/2,8)
  
  for i=0,3 do
  local c=13
  if i==1 or i==2 then c=11 end
  rect(i%2*240/2,i//2*136/2,240/2,8,c)
  rectb(i%2*240/2,i//2*136/2,240/2,136/2,c)
  end
  spr(64,240/4-12,8+4,8,1,0,0,3,3)
  print('Shield',240/4-print('Shield',0,-6)/2-1,1,8)
  print('Z to buy/use',240/4-16-print('Z to buy/use',0,-6,0,false,1,true)+2,24-4,13,false,1,true)
  if pmem(5)>0 then print(string.format('In stock: %d',pmem(5)),240/4-16-print(string.format('In stock: %d',pmem(5)),0,-6,0,false,1,true),24-4+6,13,false,1,true) end
  print('Cost:',240/4+12,24-4,13,false,1,true)
  spr(36,240/4+12+print('Cost:',0,-6,0,false,1,true)+1,24-4-1,8)
  print('x1',240/4+12+print('Cost:',0,-6,0,false,1,true)+8+1+1,24-4,13)
  local msg='Allows you to safely\ntouch a bullet.'
  local tw=print(msg,0,-12,0,false,1,true)
  print(msg,240/4-tw/2,48-4,13,false,1,true)

  spr(64+6,240/2+240/4-12,8+4,8,1,0,0,3,3)
  print('Insta-level',240/2+240/4-print('Insta-level',0,-6)/2-1,1,8)
  print('X to buy/use',240/2+240/4-16-print('X to buy/use',0,-6,0,false,1,true)+2,24-4,11,false,1,true)
  if pmem(7)>0 then print(string.format('In stock: %d',pmem(7)),240/2+240/4-16-print(string.format('In stock: %d',pmem(6)),0,-6,0,false,1,true),24-4+6,11,false,1,true) end
  print('Cost:',240/2+240/4+12,24-4,11,false,1,true)
  spr(36,240/2+240/4+12+print('Cost:',0,-6,0,false,1,true)+1,24-4-1,8)
  print('x2',240/2+240/4+12+print('Cost:',0,-6,0,false,1,true)+8+1+1,24-4,11)
  local msg='Instantly levels up board.'
  local tw=print(msg,0,-12,0,false,1,true)
  print(msg,240/2+240/4-tw/2,48-4,11,false,1,true)

  spr(64+9,240/4-12,8+4+136/2,8,1,0,0,3,3)
  print('Timer -5s',240/4-print('Timer -5s',0,-6)/2-1,1+136/2,8)
  print('A to buy/use',240/4-16-print('A to buy/use',0,-6,0,false,1,true)+2,24-4+136/2,11,false,1,true)
  if pmem(8)>0 then print(string.format('In stock: %d',pmem(8)),240/4-16-print(string.format('In stock: %d',pmem(5)),0,-6,0,false,1,true),24-4+6+136/2,11,false,1,true) end
  print('Cost:',240/4+12,24-4+136/2,11,false,1,true)
  spr(36,240/4+12+print('Cost:',0,-6,0,false,1,true)+1,24-4-1+136/2,8)
  print('x3',240/4+12+print('Cost:',0,-6,0,false,1,true)+8+1+1,24-4+136/2,11)
  local msg='Boards pass by faster.'
  local tw=print(msg,0,-12,0,false,1,true)
  print(msg,240/4-tw/2,48-4+136/2,11,false,1,true)

  spr(64+3,240/2+240/4-12,8+4+136/2,8,1,0,0,3,3)
  print('Hourglass',240/2+240/4-print('Hourglass',0,-6)/2-1,1+136/2,8)
  print('S to buy/use',240/2+240/4-16-print('S to buy/use',0,-6,0,false,1,true)+2,24-4+136/2,13,false,1,true)
  if pmem(6)>0 then print(string.format('In stock: %d',pmem(6)),240/2+240/4-16-print(string.format('In stock: %d',pmem(6)),0,-6,0,false,1,true),24-4+6+136/2,13,false,1,true) end
  print('Cost:',240/2+240/4+12,24-4+136/2,13,false,1,true)
  spr(36,240/2+240/4+12+print('Cost:',0,-6,0,false,1,true)+1,24-4-1+136/2,8)
  print('x10',240/2+240/4+12+print('Cost:',0,-6,0,false,1,true)+8+1+1,24-4+136/2,13)
  local msg='Time only moves when\nyou move.'
  local tw=print(msg,0,-12,0,false,1,true)
  print(msg,240/2+240/4-tw/2,48-4+136/2,13,false,1,true)

  local tw=print(string.format('x%d',pmem(4)),0,-6)
  print(string.format('x%d',pmem(4)),240-1-tw,136-7,3)
  spr(36,240-1-tw-8-1,136-8,8)

  if btnp(4) and pmem(4)>=1 then pmem(4,pmem(4)-1); pmem(5,pmem(5)+1) end
  if btnp(7) and pmem(4)>=10 then pmem(4,pmem(4)-10); pmem(6,pmem(6)+1) end
  if btnp(5) and pmem(4)>=2 then pmem(4,pmem(4)-2); pmem(7,pmem(7)+1) end
  if btnp(6) and pmem(4)>=3 then pmem(4,pmem(4)-3); pmem(8,pmem(8)+1) end
  for i=0,3 do if btnp(i) then TIC=stagesel; local diff=boards[#boards].a-pi/2; boards[#boards].a=pi/2; for i,b in ipairs(cur_board.bullets) do b.a=b.a-diff end; return end end
end

function credits()
  cls(10)
  poke(0x3FF8,0)
  
  local msg
  msg='Game by Leonard Somero'
  do
    local tx
    tx=0
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      tx=tx+print(char,48+tx,136/2-32+sin(t+i)*18,(t+i)*0.2%16,false,1,true)
    end
    tx=0
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      tx=tx+print(char,48+tx,136/2-32-18,(t+i)*0.2%16,false,1,true)
    end
    tx=0
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      tx=tx+print(char,48+tx,136/2-32+18,(t+i)*0.2%16,false,1,true)
    end
  end
  msg='Made with TIC-80'
  do
    local tx
    tx=0
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      tx=tx+print(char,48+48*2+tx,136/2+24*2-32+sin(t+i)*18,(t+i)*0.2%16,false,1,true)
    end
    tx=0
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      tx=tx+print(char,48+48*2+tx,136/2+24*2-32+18,(t+i)*0.2%16,false,1,true)
    end
    tx=0
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      tx=tx+print(char,48+48*2+tx,136/2+24*2-32-18,(t+i)*0.2%16,false,1,true)
    end
  end
  msg='http://tic80.com'
  do
    local tx
    tx=0
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      tx=tx+print(char,48+48*2+tx,136/2+24*2-12+32-18,(t+i)*0.2%16,false,1,true)
    end
  end
  msg='https://github.com\n/verysoftwares\n/9BUTTERFEXE'
  do
    local tx,ty
    tx=0
    ty=0
    for i=1,#msg do
      local char=string.sub(msg,i,i)
      if char=='\n' then
        ty=ty+6
        tx=0
      else
      tx=tx+print(char,48+tx,136/2-32+18+18+ty,(t+i)*0.2%16,false,1,true)
      end
    end
  end
  dx=dx or 0
  if btn(2) then nice=true; dx=dx-0.95 end
  if btn(3) then nice=true; dx=dx+0.95 end
  x=x+dx
  dx=dx*0.95

  dy=dy or 0
  if btn(0) then nice=true; dy=dy-0.95 end
  if btn(1) then nice=true; dy=dy+0.95 end
  y=y+dy
  dy=dy*0.95

  exes=exes or {}
  if #exes==0 then for i=0,100-1 do table.insert(exes,{x=x,y=y}) end end
  table.insert(exes,{x=x,y=y})
  for i,e in ipairs(exes) do
    for j=0,15 do pal((j+i)%16,(15+i)%16) end
    spr(1+t%60//30*2,e.x+24+64,e.y-24+18,14,1,0,0,2,2)
    pal()
  end
  if #exes>100 then
    table.remove(exes,1)
  end

  spr(1+t%60//30*2,x+24+64,y-24+18,14,1,0,0,2,2)

  local msg='Press C to return to title.'
  if nice then msg='Nice :D' end
  print(msg,0,136-6,9+t*0.1%5,false,1,true)
  if keyp(03) then TIC=stagesel; local diff=boards[#boards].a-pi/2; boards[#boards].a=pi/2; for i,b in ipairs(cur_board.bullets) do b.a=b.a-diff end end

  t=t+1
end
--TIC=credits
--pmem(7,10)
--pmem(8,10)
--pmem(5,10)