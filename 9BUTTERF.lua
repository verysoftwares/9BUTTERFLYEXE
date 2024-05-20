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
      circb(boards[1].cx-80+16+1,ty+6+1,6,13)
      print(mem,boards[1].cx-80-16-print(mem,0,-6,0,false,1,true)/2,ty-6-1-2,13,false,1,true)
      print(bn,boards[1].cx-80+16+1-1,ty+6+1-2,6,false,1,true)
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
    if (not hourglass) or (hourglass and hourglass_tick) then 
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
      if TIC==update and stage==2 then pal(0,7) end
      if TIC==update and stage==3 then pal(0,5) end
      if TIC==update and stage==4 then pal(0,9) end
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
  end
  ::endplr::
  if evade_act and not evade_act2 then evade=false; evade_act=false end
  
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
-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 032:88b88b888bb8bbb88b8bb8b88b8888b888b88b888b8888b88b8888b888b8bb88
-- 033:8bb88bb8b88b8b8bb88bb88bb888888b8b8888b8b888888bb888888b8bb88bb8
-- 034:8866888886646888664346886644668886666888886688888888888888888888
-- 035:999dd9999bd08db99d0088d9d000888dd888000d9d8800d99bd80db9999dd999
-- 036:8883388885355358835535383553355335553553835535388535535888833888
-- 037:8883388885355358835335383535535335553553835333388535535888833888
-- 038:8883388885355358835335383553555335553553835355388535535888833888
-- 039:8888853388883355888355558835555583555335535533353553333535555335
-- 040:3358888855338888555538885555538833333538335335353353355333533553
-- 041:8888853388883355888355558835555583553335535333333553353335555533
-- 042:3358888855338888555538885555538833333538335335353353355333533553
-- 043:8888853388883355888355558835555583533333535333333553355535533335
-- 044:3358888855338888555538885555538833333538335335353353355333533553
-- 055:3555533535555335535553358353333388355555888355558888335588888533
-- 056:3353355333533553335335353333353855555388555538885533888833588888
-- 057:3555533535553335535333558353333388355555888355558888335588888533
-- 058:3353355333533553335335353333353855555388555538885533888833588888
-- 059:3555533335555533535333338353333588355555888355558888335588888533
-- 060:3353355333533553335335353333353855555388555538885533888833588888
-- 064:888888888ddd888d8ddd8ddb88dddbbb88dbbbbb88dbbbbb88dbbbbb88dbbbbb
-- 065:8dddd888ddddddd8bbddbbbdbbbbbbbbbbbbbbbebb66bbbbb6666bbb666666bb
-- 066:8888888888ddd888d8ddd888bddd8888ebbd8888eebd8888eebd8888bebd8888
-- 067:8888888888888222888222228822228888211d8888801d8888810d88888118d8
-- 068:82332888323323223233232288888888888888e88888ee888888ee888888888d
-- 069:88888888288888882228888822228888d1128888d1088888d018888881188888
-- 070:8888888888888888888888888888888d888888da88888daa8888daaa888daaaa
-- 071:888888888888888888dddd88ddaa88ddaaaa8888aaaa8888aaaa8888aaaa8888
-- 072:888888888888888888888888d88888888d88888888d88888888d88888888d888
-- 073:8888888888888888888888888888888888888886888888868888888688888886
-- 074:8888888888888888888888888888888866666688444444684666668846888888
-- 075:8888888888888888888888888888888888888888888888888888888888888888
-- 076:6666666666666666666666666666666666666666666666666666666666666666
-- 080:88dbbbb688dbbb6688dbb666888db666888dbb66888dbbb6888dbbbb8888dbbb
-- 081:6666446b664434666644466666444666666666666666666b666666bbb6666bbb
-- 082:bbbd8888bbbd88886bbd88886bd88888bbd88888bbd88888bbd88888bd888888
-- 083:888018d88881088d888118888880188888810888888118888880188d888108d8
-- 084:8888888d888888d8d8888d888d88d8888d88d888d8888d88888888d888888e8d
-- 085:8108888880188888811888888108888880188888811888888108888880188888
-- 086:888daaaa888daaaa88daaaaa88daaaaa88d8888888d88888888d8888888d8888
-- 087:aaaa8888aaaa8888aaaa8888aaaa88888888aaaa8888aaaa8888aaaa8888aaaa
-- 088:8888d8888888d88888888d8888888d88aaaaad88aaaaad88aaaad888aaaad888
-- 089:8888888688888886888888888666688864444688866668888888888888888886
-- 090:4666688844444688666644688886646888886468888864688886646866664468
-- 091:8888888888888888888888888888888886666888864446886466668866444688
-- 092:6666666666666666666666666666666666666666666666666666666666666666
-- 096:8888dbbb8888dbbb88888dbe88888dbb888888db8888888d8888888888888888
-- 097:bb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdbbbbbbd8ddbbdd8888dd8888
-- 098:bd888888bd888888d8888888d888888888888888888888888888888888888888
-- 099:888118d888801d8888810d8888211d8488222244888222228888822288888888
-- 100:8844888d84444888444444884444444844444444323323223233232282332888
-- 101:81188888d1088888d0188888d112888822228888222888882888888888888888
-- 102:888d88888888d88888888d88888888d88888888d888888888888888888888888
-- 103:8888aaaa8888aaaa8888aaaa8888aaaadd88aadd88dddd888888888888888888
-- 104:aaaad888aaad8888aad88888ad888888d8888888888888888888888888888888
-- 105:8888888688888886888888888888888888888888888888888888888888888888
-- 106:4664468844446888666688888888888888888888888888888888888888888888
-- 107:8666646864444688666668888888888888888888888888888888888888888888
-- 108:6666666666666666666666666666666666666666666666666666666666666666
-- 112:6666666666666666666666666666666666666666666666666666666666666666
-- 113:6666666666666666666666666666666666666666666666666666666666666666
-- 114:6666666666666666666666666666666666666666666666666666666666666666
-- 115:6666666666666666666666666666666666666666666666666666666666666666
-- 116:6666666666666666666666666666666666666666666666666666666666666666
-- 117:6666666666666666666666666666666666666666666666666666666666666666
-- 118:6666666666666666666666666666666666666666666666666666666666666666
-- 119:6666666666666666666666666666666666666666666666666666666666666666
-- 120:6666666666666666666666666666666666666666666666666666666666666666
-- 121:6666666666666666666666666666666666666666666666666666666666666666
-- 122:6666666666666666666666666666666666666666666666666666666666666666
-- 123:6666666666666666666666666666666666666666666666666666666666666666
-- 124:6666666666666666666666666666666666666666666666666666666666666666
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 004:0000000ffffffff00000000000000000
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- 001:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300404000000000
-- 002:0400046004a0040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400409000000300
-- 004:0020006000a000d0008050005000500050005000a000a000a000a000a000e000e000e000e000e000f000f000f000f000f000f000f000f000f000f000364000000500
-- 005:000000f0300030006000600090009000c000c000e000e000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000454000000200
-- </SFX>

-- <PATTERNS>
-- 000:60001c00000000000000000060001600000000000000000060001c00000000000000000060001600000000000000000060001c00000000000000000060001600000000000000000060001600000000000000000060001800000060001a00000060001c00000000000000000060001600000000000000000060001c00000000000000000060001600000000000000000060001400000000000000000060001600000000000000000060001800000000000000000060001a00000060001c000000
-- 001:80001800000000000010000080001810000080001a10000080001c00000000000000000080001800000000000010000080001810000080001a10000080001c00000000000000000000000000000000000000000000000000000000000000000080001800000000000010000080001810000080001a10000080001c00000000000000000080001800000000000010000080001810000080001a10000080001c000000000000000000000000000000000000000000000000000000000000000000
-- 002:80001a00000000000010000080001a10000080001810000080001600000000000000000080001c00000000000010000080001c10000080001810000080001200000000000000000000000000000000000000000008050008050008050008050080001a00000000000010000080001a10000080001810000080001600000000000000000080001800000000000010000080001810000080001a10000080001c00000083721a83721a80001a10000080001a10000080001a10000080001a100000
-- 003:80001a00000000000010000080001a10000080001810000080001600000000000000000080001c00000000000010000080001c10000080001810000080001200000000000000000000000000000000000000000001050001050001050001050080001800000000000010000080001810000080001a10000080001c00000000000000000080001800000000000010000080001810000080001a10000080001c00000083721a83721a80001a10000080001a10000080001a10000080001a100000
-- 004:c00002100000c00002100000c00002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:800034000000000000000000000000000000000000000000100000000000000000000000800034000000000000000000a00034000000000000000000b00034000000000000000000e00034000000000000000000b00034000000000000000000000000000000000000000000e00034000000000000000000e00036000000000000000000000000000000000000000000e00034000000000000000000e00038000000000000000000900036000000000000000000e00036000000000000000000
-- 006:837238000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00038000000000000000000000000000000000000000000b5723800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065723a00000000000000000010000000000000000000000064723a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:800032000000000000000000000000000000000000000000100030000000000000000000800032000000000000000000b00032000000000000000000100000000000a00032000000000000000000100000000000800032000000000000100000800032000000000000000000000000000000000000000000000000000000100000000000800032100000800032100000b00032000000000000000000100000000000a00032000000000000000000100000000000400032000000000000000000
-- 008:400032000000000000000000000000000000000000000000100000000000000000000000400032100030400032100030400032000000100000000000700032000000000000000000000000000000600032100000100000000000000000000000e00030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600032000000000000000000000000000000000000000000
-- 009:4000320a85000a85000a85000a85000a85000a85000a85000885000885000885000885000885000885000885000885000885000000000885000000000885000000000000000885000000000000000885000000000a85000000000000000000000885000000000000000000000885000000000000000000000885000000000000000000000885000000000000000000000885000000000000000000000885000000000000000000000000000000000000000000000a8500000000088500088500
-- 010:87c234000000000000000000000000000000000000000000100000000000000000000000800034000000100000000000b00034000000000000000000100000000000a00034000000000000000000100000000000800034000000000000100000800034000000000000000000000000000000000000000000000000000000100000000000800034100000800034100000b00034000000000000000000100000000000a00034000000000000000000100000000000400034000000000000000000
-- 011:47c234000000000000000000000000000000000000000000100000000000000000000000400034100030400034100030400034000000100000000000700034000000000000000000000000000000600034100000100000000000000000000000600034000000000000000000000000000000000000000000100000000000000000000000700034100000700034100000700034000000000000000000100000000000b00034000000100000000000000000000000400034000000100000000000
-- 012:837238000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00038000000000000000000000000000000000000000000b5723800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000062723a00000000000000000010000000000000000000000064723a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:457234000000000000000000000000000000000000000000557232000000000000000000000000000000000000000000e57230000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000457234000000000000000000000000000000000000000000557232000000000000000000000000000000000000000000e57230000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000
-- 014:bff136000000400038000000700038000000b0003800000040003a00000070003a000000b44136000000400038000000700038000000b0003800000040003a00000070003a000000bff136000000400038000000700038000000b0003800000040003a00000070003a000000b44136000000400038000000700038000000b0003800000040003a00000070003a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400038000000
-- 015:4ff13a000000c00038000000900038000000c00038000000900038000000444038000000944138000000c000360000004ff038000000c00036000000900038000000c00038111100b372380221000331000441000661000881000cc1000ff1000000000000000000001270006111380221000331000441000661000881000cc1000ff100000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007ff138000000000000000000000000000000000000000000000000000000000000000000f44136000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:637238000000100000000000d57236000000100000000000d37238000000000000000000b572380000006372380000000cc1000000000aa1000000000881000000000661000000000441000000000221000000000441000000000881000ff100637238000000100000000000d57236000000100000000000d37238000000000000000000b572380000006372380000000cc1000000000aa1000000000881000000000661000000000441000000000221000000000441000000000881000ff100
-- 018:60001c00000010000000000060001610000060001c00000010000000000060001c00000010000000000000000000000060001c00000010000000000060001810000060001c00000010000000000060001c00000010000000000000000000000060001c00000010000000000060001610000060001c00000010000000000060001c00000010000000000000000000000060001c00000010000000000060001810000060001c00000010000000000060001c000000100000000000000000000000
-- 019:637038000000100000000000d57036000000100000000000d37038000000000000000000b570380000006370380000000cc1000000000aa1000000000881000000000661000000000441000000000221000000000441000000000881000ff100637038000000100000000000d57036000000100000000000d37038000000000000000000b570380000006370380000000cc1000000008aa138000000988138000000b661380000009441380000008221380000004441380000000881000ff100
-- 020:66611e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e10001060001e10000060001e100010
-- 021:637036000000100000000000d57034000000100000000000d37036000000000000000000b570360000006370360000000cc1000000000aa1000000000881000000000661000000000441000000000221000000000441000000000881000ff100637036000000100000000000d57034000000100000000000d37036000000000000000000b570360000006370360000000cc1000000008aa136000000988136000000b661360000009441360000008221360000004441360000000881000ff100
-- 022:637036000000100000000000d57034000000100000000000d37036000000000000000000b570360000006370360000000cc1000000000aa1000000000881000000000661000000000441000000000221000000000441000000000881000ff100637036000000100000000000d57034000000100000000000d370360000000000000000004570380000006370360000000cc100000000baa138000000988138000000e66138000000944138000000b22138000000e441380000000881000ff100
-- 023:b00038000000900038000000e00038000000900038000000b00038000000900038000000e00038000000900038000000c00038000000a00038000000f00038000000a00038000000c00038000000a00038000000f00038000000a00038000000d00038000000b0003800000040003a000000b00038000000d00038000000b0003800000040003a000000b0003800000040003c000000c0003a00000090003a00000040003a000000c0003a00000090003a00000040003a000000c0003a000000
-- 024:00000000000000000000000060001c00000010000000000000000000000000000000000060001c00000010000000000000000000000000000000000060001c00000010000000000060001a60001860001c10000060001c00000010000000000000000000000000000000000060001c00000010000000000000000000000000000000000060001c00000010000000000000000000000000000000000060001c00000010000000000060001a60001860001c10000060001a60001860001a60001c
-- 025:60003a00000000000000000010000000000060003a10000060003a00000080003a00000090003a00000080003a00000010003000000090003a00000010000000000000000000000080003c00000040003c000000d0003a00000000000000000060003c00000000000000000010000000000060003c10000060003c000000d0003a000000000000b0003a00000000000090003a100000b0003a00000000000090003a00000000000080003a00000000000010000040003a000000d00038000000
-- 026:6572380cc1000aa1006ff1380cc1000aa1000881000ff1004472380cc1000aa1004ff1380cc1000aa1000881000ff1004372380cc1000aa1004ff1380cc1000aa1000881000ff1006000380441000ff1000441000ff1000441000ff1000ff1006572380cc1000aa1006ff1380cc1000aa1000881000ff1004472380cc1000aa1004ff1380cc1000aa1000881000ff100e572360cc1000aa100eff1360cc1000aa1000881000ff1004000380441000ff1000441000ff1000441000ff1000ff100
-- 027:600036000000100000000000b00036000000400036000000600036000000100000000000b00036000000400036000000000000000000e0003600000090003800000070003800000040003a000000c0003a000000b0003a00000040003a0000006572380cc1000aa1006ff1380cc1000aa1000881000ff1004472380cc1000aa1004ff1380cc1000aa1000881000ff100e572360cc1000aa100eff1360cc1000aa1000881000ff1004000380441000ff1000441000ff1000441000ff1000ff100
-- 028:600036000000100000000000b00036000000400036000000600036000000100000000000b00036000000400036000000e00036000000100000000000900038000000700038000000b0003800000090003800000040003a0000001000000000006572380cc1000aa1006ff1380cc1000aa1000881000ff1004472380cc1000aa1004ff1380cc1000aa1000881000ff1004372380cc1000aa1004ff1380cc1000aa1000881000ff1006000380441000ff1000441000ff1000441000ff1000ff100
-- 029:40003a000000c0003a000000b0003a00000040003a00000000000000000004460000000000000000000000000010060040003a000000c0003a000000b0003a00000040003a000000c0003a000000b0003a00000040003c00000010003000000040003a000000c0003a000000b0003a00000040003a00000000000000000004460000000000000000000000000010060040003a000000c0003a000000b0003a00000040003a000000400038000000e00038000000b00038000000400038000000
-- 030:60001a10000000000060001810000000000060001610000060001a10000000000060001810000000000060001610000060001a10000000000060001810000000000060001610000060001a10000000000060001810000000000060001610000060001a10000000000060001810000000000060001610000060001a10000000000060001810000000000060001610000060001a10000000000060001810000000000060001610000060001a100000000000600018100000000000600016100000
-- 031:60001a10000000000060001810000000000060001610000060001c00000000000010000060001c00000000000010000060001a10000000000060001810000000000060001610000060001a10000060001a60001810000060001860001610000060001a10000000000060001810000000000060001610000060001a10000000000060001810000000000060001610000060001c10000000000060001c10000000000060001610000060001c10000000000060001c10000000000060001e000000
-- 032:60001060001260001460001660001800000060001660001460001060001260001460001660001800000060001660001460001060001260001460001660001800000060001660001460001060001260001460001660001800000060001660001460001460001660001860001a60001c00000060001a60001860001460001660001860001a60001c00000060001a60001860001800000000000000000000000000000000000000000060001460001660001860001a60001c00000060001a600018
-- 033:40003a000000c0003a000000b0003a00000040003a00000000000000000004460000000000000000000000000010060040003a000000c0003a000000b0003a00000040003a000000c0003a000000b0003a00000040003c00000010003000000040003a000000c0003a000000b0003a00000040003a00000000000000000004460000000000000000000000000010060040003a000000c0003a000000b0003a00000040003a000000e0003a000000c0003a000000b0003a000000c0003a000000
-- 034:60003c000000d0003a000000a0003a00000090003a000000d0003a000000a0003a00000090003a00000060003a000000a0003a00000090003a00000060003a00000090003a00000060003c000000d0003a000000a0003a00000090003a000000f0003a000000b0003a000000f0003a00000050003c00000000000000000004460000000000000000000008860000000000000000000010060000000060003c50003c40003cf0003ae0003ad0003ac0003ab0003aa0003a90003a80003a70003a
-- 035:b88134000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400036000000000000000000000000000000000000000000c00034000000000000000000c00036000000000000000000
-- 036:688134000000d00034000000000000000000b00034000000000000000000000000000000000000000000000000000000900034000000000000000000800034000000400034000000600034000000000000000000000000000000000000000000688134000000d00034000000000000000000b00034000000000000000000000000000000000000000000000000000000900034000000000000000000800034000000400034000000600034000000000000000000000000000000000000000000
-- 037:400004000000000000100000400004000000000000100000400004000000000000100000e00002000000b00002100000400004000000000000100000400004000000000000100000400004000000000000100000e00002000000b00002100000400004000000000000100000400004000000000000100000400004000000000000100000e00002000000b00002100000400004000000000000100000400004000000000000100000400004000000000000100000900004000000b00004100000
-- </PATTERNS>

-- <TRACKS>
-- 000:1810002008003009002008003009002430004c10002c20003030002c20003030002820004820000000000000000000000000df
-- 001:e000004d45104d4510656510756510819510ad4559ad4559000000000000000000000000000000000000000000000000000000
-- 002:f00000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100
-- 003:bd7000b18000d58000c58000ed7620228620328000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <SCREEN>
-- 000:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 001:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 002:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 003:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 004:888888888888888888888dddd88888888888888888888888888888888888888888888dddd88888888888888dddddddd88888888888888888888888888888888888888888888dddd88888888888888888888888888888888888888888888dddd88888888888888dddddddddd8888888888888888888888888
-- 005:888888888888888888888dddd88888888888888888888888888888888888888888888dddd88888888888888dddddddd88888888888888888888888888888888888888888888dddd88888888888888888888888888888888888888888888dddd88888888888888dddddddddd8888888888888888888888888
-- 006:888888888888888888888dddd8888888888dddddd8888dddd8888dd8888dddddd8888dddd88888888888888888888dddd888888888888888888888888888888888888888888dddd8888888888dddddd8888dddd8888dd8888dddddd8888dddd88888888888888888888dddd8888888888888888888888888
-- 007:888888888888888888888dddd8888888888dddddd8888dddd8888dd8888dddddd8888dddd88888888888888888888dddd888888888888888888888888888888888888888888dddd8888888888dddddd8888dddd8888dd8888dddddd8888dddd88888888888888888888dddd8888888888888888888888888
-- 008:888888888888888888888dddd88888888dddd88dddd88dddd8888dd88dddd88dddd88dddd8888888888888888dddddd88888888888888888888888888888888888888888888dddd88888888dddd88dddd88dddd8888dd88dddd88dddd88dddd888888888888888888dddd888888888888888888888888888
-- 009:888888888888888888888dddd88888888dddd88dddd88dddd8888dd88dddd88dddd88dddd8888888888888888dddddd88888888888888888888888888888888888888888888dddd88888888dddd88dddd88dddd8888dd88dddd88dddd88dddd888888888888888888dddd888888888888888888888888888
-- 010:888888888888888888888dddd88888888dddddd88888888dddddd8888dddddd888888dddd88888888888888dddd888888888888888888888888888888888888888888888888dddd88888888dddddd88888888dddddd8888dddddd888888dddd88888888888888dd8888dddd8888888888888888888888888
-- 011:888888888888888888888dddd88888888dddddd88888888dddddd8888dddddd888888dddd88888888888888dddd888888888888888888888888888888888888888888888888dddd88888888dddddd88888888dddddd8888dddddd888888dddd88888888888888dd8888dddd8888888888888888888888888
-- 012:888888888888888888888dddddddddd8888dddddd88888888dd88888888dddddd888888dddddd8888888888dddddddddd888888888888888888888888888888888888888888dddddddddd8888dddddd88888888dd88888888dddddd888888dddddd888888888888dddddd888888888888888888888888888
-- 013:888888888888888888888dddddddddd8888dddddd88888888dd88888888dddddd888888dddddd8888888888dddddddddd888888888888888888888888888888888888888888dddddddddd8888dddddd88888888dd88888888dddddd888888dddddd888888888888dddddd888888888888888888888888888
-- 014:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 015:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 016:888888888888888888888888888888888888bbbb8888bbbbbbbbbb88bbbb88bbbbbbbbbb88bbbbbbbbbb888888888888888888888888888888888888888888888888888888888888888888888bbbbbb8888bbbbbbbbbb88bbbb88bbbbbbbb8888bbbbbbbbbb8888888888888888888888888888888888888
-- 017:888888888888888888888888888888888888bbbb8888bbbbbbbbbb88bbbb88bbbbbbbbbb88bbbbbbbbbb888888888888888888888888888888888888888888888888888888888888888888888bbbbbb8888bbbbbbbbbb88bbbb88bbbbbbbb8888bbbbbbbbbb8888888888888888888888888888888888888
-- 018:8888888888888888888888888888888888bbbbbb8888888888bbbb88bbbb88bbbb88888888888888bbbb8888888888888888888888888888888888888888888888888888888888888888888bbbb88bbbb88888888bbbb88bbbb88888888bbbb88bbbb8888888888888888888888888888888888888888888
-- 019:8888888888888888888888888888888888bbbbbb8888888888bbbb88bbbb88bbbb88888888888888bbbb8888888888888888888888888888888888888888888888888888888888888888888bbbb88bbbb88888888bbbb88bbbb88888888bbbb88bbbb8888888888888888888888888888888888888888888
-- 020:888888888888888888888888888888888888bbbb88888888bbbb8888888888bbbbbbbb88888888bbbb888888888888888888888888888888888888888888888888888888888888888888888bbbbbb88bb888888bbbb888888888888bbbbbb8888bbbbbbbb888888888888888888888888888888888888888
-- 021:888888888888888888888888888888888888bbbb88888888bbbb8888888888bbbbbbbb88888888bbbb888888888888888888888888888888888888888888888888888888888888888888888bbbbbb88bb888888bbbb888888888888bbbbbb8888bbbbbbbb888888888888888888888888888888888888888
-- 022:888888888888888888888888888888888888bbbb888888bbbb888888bbbb88888888bbbb88bb8888bbbb8888888888888888888888888888888888888888888888888888888888888888888bbbb8888bb8888bbbb888888bbbb88bbbb88888888888888bbbb8888888888888888888888888888888888888
-- 023:888888888888888888888888888888888888bbbb888888bbbb888888bbbb88888888bbbb88bb8888bbbb8888888888888888888888888888888888888888888888888888888888888888888bbbb8888bb8888bbbb888888bbbb88bbbb88888888888888bbbb8888888888888888888888888888888888888
-- 024:8888888888888888888888888888888888bbbbbbbb88bbbb88888888bbbb88bbbbbbbb888888bbbbbb88888888888888888888888888888888888888888888888888888888888888888888888bbbbbb8888bbbb88888888bbbb88bbbbbbbbbb88bbbbbbbb888888888888888888888888888888888888888
-- 025:8888888888888888888888888888888888bbbbbbbb88bbbb88888888bbbb88bbbbbbbb888888bbbbbb88888888888888888888888888888888888888888888888888888888888888888888888bbbbbb8888bbbb88888888bbbb88bbbbbbbbbb88bbbbbbbb888888888888888888888888888888888888888
-- 026:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 027:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 028:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 029:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 030:888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- 031:88888888888888888888888888888888888888888888888888888ddddddddddddddd6888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888ddddddddddddddd000888888888888888888888888888888888888888888888888888
-- 032:888888888888888888888888888888888888888888888888ddddd888888888888866ddddd008888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888ddddd888888000000000ddddd0088888888888888888888888888888888888888888888888
-- 033:888888888888888888888888888888888888888888888ddd8888888888888888866434680ddd008888888888888888888888888888888888888888888888888888888888888888888888888888888888888ddd8888888888800000000000000ddd0088888888888888888888888888888888888888888888
-- 034:888888888888888888888888888888888888888888ddd8888888888888888888866446680000ddd668888888888888888888888888888888888888888888888888888888888888888888888888888888ddd8888888888888800000000000000000ddd0888888888888888888888888888888888888888888
-- 035:888888888888888888888888888888888888888ddd8888888888888888888888886666800000006ddd088888888888888888888888888888888888888888888888888888888888888888888888888ddd8888888888888888800000000000000000000ddd0888888888888888888888888888888888888888
-- 036:8888888888888888888888888888888888888dd8888888888888888888888888888668800000066434dd08888888888888888888888888888888888888888888888888888888888888888888888dd8888888888888888888800000000000000000000000dd08888888888888888888888888888888888888
-- 037:88888888888888888888888888888888888dd88888888888888888888888888888888880000006644660dd0888888888888888888888888888888888888888888888888888888888888888888dd88888888888888888888880000000000000000000000000dd088888888888888888888888888888888888
-- 038:8888888888888888888888888888888888d888888888888866888888888888888888888000000066660000d08888888888888888888888888888888888888888888888888888888888888888d888888888888888888888888000000000000000000000000006d08888888888888888888888888888888888
-- 039:88888888888888888888888888888888dd88888888888886646888888888888888888800000000066000000dd0888888888888888888888888888888888888888888888888888888888866dd88888888888888888888888880000000000000000000000000664dd088888888888888888888888888888888
-- 040:8888888888888888888888888888888d646888888888886643468888888888888888880000000000000000000d08888888888888888888888888888888888888888888888888888888866d688888888888888888888888888000000000000000000000000664346d08888888888888888888888888888888
-- 041:88888888888888888888888888888dd64346888888888866446688888888888888888800000000000000000000dd8888888888888888888888888888888888888888888888888888886dd34688888888888888888888888880000000000000000000000006644660dd888888888888888888888888888888
-- 042:8888888888888888888888888888d866446688888888888666688888888888888888880000000000000000000000d08888888888888888888888888888888888888888888888888888d644668888888888888888888888888000000000000000000000000066660000d08888888888888888888888888888
-- 043:888888888888888888888888888d88866668888888888886668888888888888888888000000000000000000000000d088888888888888888888888888888888888888888888888888d86666888888888888888888888888880000000000000000000000006666000000d0888888888888888888888888888
-- 044:88888888888888888888888888d8888866888888888888664688888888888888888880000000000000000000000000d0888888888888888888888888888888888888888888888888d8886646888888888888888888888888800000000000000000000000664346000000d088888888888888888888888888
-- 045:888888888888888888888888dd888888888888888888866434688888888888888888800000000000000000000000000dd888888888888888888888888888888888888888888888dd888664346888888888888888888888888000000000000000000000006644660000000dd8888888888888888888888888
-- 046:88888888888888888888888d8888888888888888888886644668888888888888888880000000000000000000000000000d8888888888888888888888888888888888888888888d8888866446688888888888888888888888800000000000000000000000066660000000000d888888888888888888888888
-- 047:8888888888888888888888d888888888888888888888886666888888888888886688000000000000000000000000000000d88888888888888888888888888888888888888888d888888866668888888888888888888888888000000000000000000000006646000000000000d88888888888888888888888
-- 048:8888888888888888888888d888888888888888888888888668888888888888866468000000000000000000000660000000d08888888888888888888888888888888888888888d888888886646888888888888888888888888000000000000000000000066434600000000000d08888888888888888888888
-- 049:888888888888888888888d88888888888888888888888888888888888888886643460660000000000000000066460000000d088888888888888888888888888888888888888d88888888664346888888888888888888888880000000000000000000000664466000000000000d0888888888888888888888
-- 050:88888888888888888888d8888888888888888888888888888888888888888866446666460000000000000006643460000000d8888888888888888888888888888888888888d8888888886644668888888888888888888888800000000000000000000000666600000000000000d888888888888888888888
-- 051:8888888888888888888d888888888888888888888888888888888888888888866666643460000000000000066446600000000d88888888888888888888888888888888888d888888888886666688888888888888888888888000000000000000000000066660000000000000000d88888888888888888888
-- 052:888888888888888888d88888888888888888888888888888888888888888888866866446600000000000000066660000000000d888888888888888888888888888888888d88888888888886664688888888888888888888880000000000000000000006643460000000000000000d8888888888888888888
-- 053:888888888888888888d88888888888888888888888888888888888888888888888806666000000000000000666600000000000d088888888888888888888888888888888d88888888888886643468888888888888888888880000000000000000000006644660000000000000000d0888888888888888888
-- 054:88888888888888888d8888888888888888888888888888888888888888888888888006600000000000000066460000000000000d8888888888888888888888888888888d8888888888888866446688888888888888888888800000000000000000000066666000000000000000000d888888888888888888
-- 055:8888888888888888d888888668888888888888888888888888888888888888888800000000000000000006643460000000000000d88888888888888888888888888888d888888888888888866666888888888888888888888000000000000000000006646600000000000000000000d88888888888888888
-- 056:8888888888888888d888886646888888888888888888886688888888dd8888888800000000000000000006644660000000000000d88888888888888888888888888888d888888888888888886664688888888888888888888000000000000000000066434600000000000000000000d88888888888888888
-- 057:888888888888888d88888664346886688888888888888664688888bd08db888888000000000000000000006666000000000000000d888888888888888888888888888d88888888888888888866434688888888888888888880000000000000000000664466000000000000000000000d8888888888888888
-- 058:88888888888888d888888664466866468888888888886643468888d0088d8888880000000000000000000006600000000000000000d8888888888888888888888888d8888888888888888888664466888888888888888888800000000000000000006666600000000000000000000000d888888888888888
-- 059:88888888888888d88888886666866434688888866888664466888d000888d888800000000000000000000000000000000000000000d8888888888888888888888888d8888888888888888888866664688888888888888888800000000000000000066466600000000000000000000000d888888888888888
-- 060:8888888888888d888888888668866446688888664688866668888d888000d8888000000dd0000000000000000000000000000000000d88888888888888888888888d888888888888888888888866434688888888888888888000000000000000000664466000000000000000000000000d88888888888888
-- 061:8888888888888d8888888888888866668888866434688866888888d8800d888880000bd08db00000000000000000000000000000000d88888888888888888888888d888888888888888888888866446688888888888888888000000000000000000666660000000000000000000000000d88888888888888
-- 062:888888888888d88888888888888886688888866446688888888888bd80db888880000d0088d000000000000000000000000000000000d888888888888888888888d88888888888888888888888866666888888888888888880000000000000000066466000000000000000000000000000d8888888888888
-- 063:888888888888d8888888888888888888888888666688888888888888dd8888880000d000888d00000000000000000000000000000000d888888888888888888888d88888888888888888888888886664688888888888888880000000000000000664346000000000000000000000000000d8888888888888
-- 064:888888888888d8888888888888888888888888866888888888888888886688880000d888000d00006600000000000000000000000000d888888888888888888888d88888888888888888888888886643468888888888888880000000000000006664466000000000000000000000000000d8888888888888
-- 065:88888888888d888888888888888888888888888888888888888888888664688800000d8800d0000664600000000000000000000000000d8888888888888888888d8888888888888888888888888866446688888888888888800000000000000664666600000000000000000000000000000d888888888888
-- 066:88888888888d888888888888888888888888888888888888888888886643468800066bd80db0006643460000000000000000000000000d8888888888888888888d8888888888888888888888888886666468888888888888800000000000006643466000000000000000000000000000000d888888888888
-- 067:88888888888d88888888888888888888888888888888888888888888664466800066460dd000006644660000000000000000000000000d8888888888888888888d8888888888888888888888888888664346888888888888800000000000006644660000000000000000000000000000000d888888888888
-- 068:8888888888d888888888888888888888888888888888888888888888866668800664346000000006666000000000000000000000000000d88888888888888888d888888888888888888888888888886644668888888888888000000000000666666000000000000000000000000000000000d88888888888
-- 069:8888888888d888888888888888888888888888888888888888888888886688800664466000000000660000000000000000000000000000d88888888888888888d888888888888888888888888888888666646888888888888000000000006643660000000000000000000000000000000000d88888888888
-- 070:8888888880d888668888888888888888888888888888888888886688888888800066660000000000000000000000000000000000000000d88888888888888888d888888888888888888888888888888866434688888888888000000000066644660000000000000000000000000000000000d88888888888
-- 071:888888888d00066468888888888888888888888866888888888664688888880000066000000000000000066000000000000000000000000d888888888888888d888888888888888888888888888888886644666888888888800000000066466660000000000000000000dd000000000000000d8888888888
-- 072:888888880d00664346088888888888888888888664688888886643468888880000000000000000000000664600000000000000000000000d888888888888888d88888888888888888888888888888888866666468888888880000000066434660000dd006600660066bd08db0000000000000d8888888888
-- 073:888888880d006644660000088dd888888888886643668888886644668888880000000000000000000006643460000006600000000000000d888888888888888d8888888888888dd88668866886688dd88866643466888888800000000664466066bd08d6646664666460088d6600000000000d8888888888
-- 074:888888880d0006666000000bd08db88888888866466468888d066668d886666000006600000000000006644660000066460000006600000d888888888888888d88888888888bd08d664666466646d08d668664466468888880000000666666066460086643464366434608866460660000000d8888888888
-- 075:888888880d0000660000000d0088d00888888886664346888d886600d866664600066460000000000000666600000664346000066460000d888888888888888d88886688866d0086643464366434608664686666434688888000000664366466434608664466446644668066434664606600dd8888888888
-- 076:88888888d0000000000000d000888d00000888886644668888d8800d86666434606643460000000000000660000006644660006643460000d8888888888888d8888664686646008664466446644660664346646644666d8880000d666446636644668006666666666668806644664346646d08db88888888
-- 077:88888888d0000000000000d888000d00000000008666688888bd80db86666446606644660000000000000000000000666600006644660000d888888888888dd86666434664346800666666666666886644664346666646db800bd664666644666668800d6600660066bd80d666664466434608dd88888888
-- 078:88888888d00000000000000d8800d00000000000006688888888dd88886666660d066668d000000000000000000000066000000666600000d8888888888bd0d66466446664466800d6688668866d88066666446666463466800666434666666066bd80db000000000000dd0066066666446608d8d8888888
-- 079:88888888d00000000000000bd80db000000000000000000088888886686666600d886600d000000000000000000000000000000066000000d8888888888d00d6434666686666d80db8888888888bd80d668666664466466660664644664666000000dd00000000000000000000006606666880d0d8888888
-- 080:88888888d0000000000000000dd066000000000000000000000066664666660000d8800d0000000660000000000000000000000000000000d888888888d000d64466668886688dd88888888888888dd8888866866666666646643466666600000000000000000000000000000000000066d880dd88888888
-- 081:88888888d000000000000000000664600000000000000000000664646666466600bd80db0000666646000000000000000000000000000000d888888888d888d6666888888888888888888888888888888888888866d6666466464666d66000000000000000000000000000000000000000bd80db88888888
-- 082:88888888d00006600000000000664346000000000000000000664346666434646000dd000006666434600000000000000000000000000000d8888888888d88d0668888888888888888888888888888888888888888bd86666434660db0000000000000000000000000000000000000008888ddd888888888
-- 083:88888888d0006646000000000066446600000000000066000066446666644663660000000066466446600000000000000000000000000000d8888888888bd8ddb8888000000000000000000000000000000000000000dd6664466dd88888888888888888888888888888888888888888888888d888888888
-- 084:88888888d0066434600000000006666000000000000664600006666666666646646000000066446666000000000000000000000000000000d888888888888dd0000000000000000000000000000000000000000000000006666688888888888888888888888888888888888888888888888888d888888888
-- 085:88888888d0066446600000000000660000000000006643460000660666466666434680000006666660000000000000000000000000000000d8888888888888d0000000000000000000000000000000000000000000000066666468888888888888888888888888888888888888888888888888d888888888
-- 086:88888888d0006666000000000000000000006600006644660000066066666866446688888000660000000000000000000000000000000000d8888888888888d0000000000000000000000000000000000000000000000066644668888888888888888888888888888888888888888888888888d888888888
-- 087:88888888d0000660000000000000000000066460000666600000664606668886666888888888800000000000000000000000000000000000d8888888888888d0000000000000000000000000000000000000000000000006666688888888888888888888888888888888888888888888888888d888888888
-- 088:88888888d0000000000000000000000000664346000066000666643460086688668888888888888880000000000000000000000000000000d8888888888888d0000000000000000000000000000000000000000000000006664688888888888888888888888888888888888888888888888888d888888888
-- 089:88888888d0000000000000000000000000664466000000006646644660066468888888668888888888888000000dd0000000000000000000d8888888888888d0000000000000000000000000000000000000000000000066643468888888888888888888888888888888888888888888888888d888888888
-- 090:88888888d00000000000000000000000000666600000000664346666006643468888866468888888888888888bd08db00000000000000000d8888888888888d0000000000000000000000000000000000000000000000066644668888888888888888888888888888888888888888888888888d888888888
-- 091:888888880d0000000000000000000000000066000000000664466660006644668888664346888888888888888d0088d0000000000000000d888888888888880d00000000000000000000000000000000000000000000000666668888888888888888888888888888888888888888888888888d8888888888
-- 092:888888880d000000000000000000000000000000000000006666000000866666688866446688888888888888d000888d800000000006600d888888888888880d00000000000000000000000000000000000000000000006666646888888888888888888888888888888888888888888888888d8888888888
-- 093:888888880d000000000000000000000000000000000000000660000000886666468886666888888888888888d888000d888880000066460d888888888888880d00000000000000000000000000000000000000000000066466434688888888888888888888888888888888888888888888888d8888888888
-- 094:888888888d0000000000000000000000000000000000000000000000008886643468886688888888888888668d8800d8888888888664346d888888888888888d00000000000000000000000000000000000000000000066466446688888888888888888888888888888888888888888888888d8888888888
-- 095:888888888d0000000000000000000000000000066000000000000000008886644668888888888888888886646bd80db8888888888664466d888888888888888d00000000000000000000000000000000000000000000006666666888888888888888888888888888888888888888888888888d8888888888
-- 096:8888888880d00000000000000000000000000066460000000000000008888866668888888888668888886643468dd88888888888886666d88888888888888880d000000000000000000000000000000000000000000006646066468888888888888888888888888888888888888888888888d88888888888
-- 097:8888888880d000000000006600000000000006643460000000000000088888866888888888866468888866446688888888888888888668d88888888888888880d000000000000000000000000000000000000000000066434664346888888888888888888888888888888888888888888888d88888888888
-- 098:8888888888d000000000066466000000000006644660000000000666688888888888888888664346888886666888888888888888888888d88888888888888888d000000000000000000000000000000000000000000066446664466888888888888888888888888888888888888888888888d88888888888
-- 099:88888888880d0000000066434660000000000066660000000000664646888888888888888866446688888866888888888888888888888d8888888888888888880d0000000000000000000000000000000000000000000666606666688888888888888888888888888888888888888888888d888888888888
-- 100:88888888880d0000000066446646000000000006600000000006643464688888888888888886666888888888888888888888888888888d8888888888888888880d0000000000000000000000000000000000000000006646000666468888888888888888888888888888888888888888888d888888888888
-- 101:88888888888d0000000006666466000000000000000000000006644666688888888888888888668888888888888888888888888888888d8888888888888888888d0000000000000000000000000000000000000000066434600664346888888888888888888888888888888888888888888d888888888888
-- 102:888888888880d00000000066666000000000000000000000000066666688888888888668888888888888888888888888888888888888d888888888888888888880d00000000000000000000000000000000000000006644660066446688888888888888888888888888888888888888888d8888888888888
-- 103:888888888888d00000000000660000000000000006600000000006666888888888886646888888888888888888888888888888888888d888888888888888888888d00000000000000000000000000000000000000006666600086666688888888888888888888888888888888888888888d8888888888888
-- 104:888888888888d00000000000000000000000000066460000000000088888888888866434688888888888888888888888888888888888d888888888888888888888d00000000000000000000000000000000000000066466600086663468888888888888888888888888888888888888888d8888888888888
-- 105:8888888888880d000000000000000000000000066434600000000008888888888886644668888888888888888888888888888888888d88888888888888888888880d000000000000000000000000000000000000006644660008664466888888888888888888888888888888888888888d88888888888888
-- 106:8888888888888d000000000000000000000000066446600000000008888888888888666688888888888888888888888888888888888d88888888888888888888888d000000000000000000000000000000000000006666600008866666888888888888888888888888888888888888888d88888888888888
-- 107:88888888888880d0000000000000000000000000666600000000000888888888888886688888888888888888888888888888888888d8888888888888888888888880d0000000000000000000000000000000000006646600000888666468888888888888888888888888888888888888d888888888888888
-- 108:88888888888888d0000000000000000000000000066000000000008888888888888888888888888888888888888888888888888888d8888888888888888888888888d0000000000000000000000000000000000066434600000888664346888888888888888888888888888888888888d888888888888888
-- 109:888888888888880d00000000000000000000000000000000000000888888888668888888888888888888888888888888888888888d888888888888888888888888880d00000000000000000000000000000000006644660000088866446688888888888888888888888888888888888d8888888888888888
-- 110:8888888888888880d000000000000000000000000000000000000088888888664688888888888888888888888888888888888888d88888888888888888888888888880d000000000000000000000000000000006646660000008888666646888888888888888888888888888888888d88888888888888888
-- 111:8888888888888888d000000000000000000000000066000000000088888886643468888888888888888888888888888888888888d88888888888888888888888888888d000000000000000000000000000000066434600000008888866434688888888888888888888888888888888d88888888888888888
-- 112:88888888888888880d0000000000000000000000066460000000088888888664466888888888888888668888888888888888888d8888888888888888888888888888880d0000000000000000000000000000006644660000000888886644666888888888888888888888888888888d888888888888888888
-- 113:888888888888888880d00000000000000000000066434600000008888888886666888888888888888664668888888888888888d888888888888888888888888888888880d00000000000000000000000000000666660000000088888866666468888888888888888888888888888d8888888888888888888
-- 114:888888888888888888d00000000000000000000066446600000008888888888668888888888888886646646888888888888888d888888888888888888888888888888888d00000000000000000000000000006646600000000088888886664346888888888888888888888888888d8888888888888888888
-- 115:8888888888888888888d000000000000000000000666600000000888888668888888888888888888666643468888888888888d88888888888888888888888888888888888d000000000000000000000000006643460000000008888888866446688888888888888888888888888d88888888888888888888
-- 116:88888888888888888880d0000000000000000000006600000000888888664688888888888888888886664466888888888888d8888888888888888888888888888888888880d0000000000000000000000006664466000000000888888888666668888888888888888888888888d888888888888888888888
-- 117:888888888888888888880d00000000000000000000000000000088888664346888888888888888888866666888888888888d888888888888888888888888888888888888880d00000000000000000000006646666000000000088888888886664688888888888888888888888d8888888888888888888888
-- 118:8888888888888888888880d000000000000000000000000000008888866446688888888888888888888866888888888888d88888888888888888888888888888888888888880d000000000000000000006643466000000000008888888888664346888888888888888888888d88888888888888888888888
-- 119:8888888888888888888888d000000006600000000000000000008888886666888888888888888888888888888888888888d88888888888888888888888888888888888888888d000000000000000000006644660000000000008888888888664466688888888888888888888d88888888888888888888888
-- 120:88888888888888888888888d00000066460000000dd000000008888888866888888888888888888888888888888888888d8888888888888888888888888888888888888888888d0000000000000000006666660000000000000888888888886666646888888888888888888d888888888888888888888888
-- 121:888888888888888888888888dd0006643460000bd08db00000088888888888888888888888888888888888888888888dd888888888888888888888888888888888888888888888dd000000000000000664366000000000000008888888888886664346888888888888888dd8888888888888888888888888
-- 122:88888888888888888888888880d006644660000d0088d0000008888888888888888888888888888888888888888888d8888888888888888888888888888888888888888888888880d0000000000000666446600000000000000888888888888866446668888888888888d888888888888888888888888888
-- 123:888888888888888888888888880d0066660000d000888d00000888888888888888888888888888888888888888888d888888888888888888888888888888888888888888888888880d00000000000664666600000000000000088888888888888666664688888888888d8888888888888888888888888888
-- 124:8888888888888888888888888888d006600000d888000d0000888888888888888888888888888888888888888888d88888888888888888888888888888888888888888888888888888d000000000664346600000000000000008888888888888886664346688888888d88888888888888888888888888888
-- 125:88888888888888888888888888888dd00000000d8800d000008888888888888888888888888888888888888888dd8888888888888888888888888888888888888888888888888888888dd00000066644660000000000000000088888888888888886644664688888dd888888888888888888888888888888
-- 126:8888888888888888888888888888880d0000000bd80db00000888888888888888888888888888888888888888d88888888888888888888888888888888888888888888888888888888880d000066466660000000000000000008888888888888888866664346888d88888888888888888888888888888888
-- 127:88888888888888888888888888888888dd0000000dd00000008888888888888888888888888888888888888dd8888888888888888888888888888888888888888888888888888888888888dd06643466000000000000000000088888888888888888866644668dd888888888888888888888888888888888
-- 128:8888888888888888888888888888888888d000000000000008888888888888888888888888888888888888d88888888888888888888888888888888888888888888888888888888888888888d664466000000000000000000b08b88888888888888888866668d88888888888888883388888888888888888
-- 129:88888888888888888888888888888888888dd00000000000088888888888888888888888888888888888dd8888888888888888888888888888888888888888888888888888888888888888888dd666000000000000000000bb0bbb88888888888888888866dd888888888888888535535888888888333888
-- 130:8888888888888888888888888888888888888dd0000000000888888888888888888888888888888888dd88888888888888888888888888888888888888888888888888888888888888888888888dd0000000000000000000b0bb8b888888888888888888dd88888888888888888355353883383383383388
-- 131:888888888888888888888888888888888888888ddd0000000888888888888888888888888888888ddd888888888888888888888888888888888888888888888888888888888888888888888888888ddd0000000000000000b0088b888888888888888ddd8888888888888888883553355388333883338388
-- 132:888888888888888888888888888888888888888888ddd0008888888888888888888888888888ddd888888888888888888888888888888888888888888888888888888888888888888888888888888888ddd00000000000000bddb8888888888888ddd8888888888888888888883555355388333883388388
-- 133:888888888888888888888888888888888888888888888ddd8888888888888888888888888ddd888888888888888888888888888888888888888888888888888888888888888888888888888888888888888ddd0000000000b0dd8b888888888ddd8888888888888888888888888355353883383388333888
-- 134:888888888888888888888888888888888888888888888888ddddd888888888888888ddddd888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888ddddd00000b0088b8888ddddd8888888888888888888888888888535535888888888888888
-- 135:88888888888888888888888888888888888888888888888888888ddddddddddddddd8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888ddddddddddddddd888888888888888888888888888888888883388888888888888888
-- </SCREEN>

-- <PALETTE>
-- 000:213b253a604a4f7754a19f7c77744f775c4f603b3a3b2137170e192f213b433a604f527765738c7c94a1a0b9bac0d1cc
-- </PALETTE>

