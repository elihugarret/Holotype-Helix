--Moonlet
--Lua/MoonScript experimental module for audio livecoding
--Written by Elihu Garret, Mexico 2015

local Gen = require "gen"
local allen = require "allen"
local midi = require "luamidi"
local moont = {}

math.randomseed(os.clock())

moont.openout = midi.openout
moont.send_message = midi.sendMessage
local soundPlay = proAudio.soundPlay
local fromFile = proAudio.sampleFromFile
local remove = table.remove
local insert = table.insert
local tonumber = tonumber
local tono = 1 --change to 0.5 if you are on linux
local noteOn, noteOff = midi.noteOn, midi.noteOff
local dir = "../Samples/Techno/"
local kic = fromFile(dir.."kick.ogg")
local sna = fromFile(dir.."snare.ogg") 
local ope = fromFile(dir.."openhat.ogg")
local hat = fromFile(dir.."hat.ogg")
local rob = fromFile(dir.."robot.ogg") 
local vel = fromFile(dir.."velcro.ogg")
local iro = fromFile(dir.."iron.ogg")
local exh = fromFile(dir.."exhale.ogg")
local air = fromFile(dir.."air.ogg")
local ice = fromFile(dir.."ice.ogg")
local kit = fromFile(dir.."kitkick.ogg")
local met = fromFile(dir.."metal.ogg")
local tin = fromFile(dir.."tin.ogg")
local tam = fromFile(dir.."tam.ogg")
local mar = fromFile(dir.."mar.ogg")
local cab = fromFile(dir.."cab.ogg")
local req = fromFile(dir.."req.ogg")
local pan = fromFile(dir.."pan.ogg")
local woo = fromFile(dir.."woo.ogg")
local snap = fromFile(dir.."sna.ogg")

local bank = {
  x = kic,
  o = sna,
  h = hat,
  p = ope,
  m = rob,
  v = vel,
  c = iro,
  l = exh,
  a = air,
  i = ice,
  k = kit,
  t = met,   
  b = tin,
  A = tam,
  B = mar,
  C = cab,
  D = req,
  E = pan,
  F = woo,
  G = snap,
  _ = function (dur) moont.sleep(dur) end,
}
------[[Gen.play(1,Gen.vR(1,1,1,1),1,dur,0,0)--]]

local clock = os.clock
function moont.sleep(n) 
  local t0 = clock()
  while clock() - t0 <= n do end
end

function string:n()
  local tabla = {}
  local it = 1
  for y in self:gmatch'%g+' do
    tabla[it] = y
    it = it + 1
  end
  return tabla
end

function string:r(b)
  b = b or 1
  local t = {}
  local i = 1
  for c in self:gmatch'%g+' do
    if not tonumber(c) then t[i] = 0 
      else  t[i] = b/c    
    end
    i = i + 1
  end
  return t
end

local function isTable(t)
  return type(t) == 'table'
end

local function each(list, f, ...)
  if not isTable(list) then return end
  for index,value in pairs(list) do
    f(index,value,...)
  end
end

function moont.init(file)
	while true do
		local luna = xpcall(function () return require(file) end,
      function () print("error"); moont.sleep(1) end)
		package.loaded.luna = nil
	end
end

--y[moont.w(_, #y)]
function moont.w(counter, lenght)
  local var = counter % lenght
  if var == 0 then return lenght
    else return var 
  end
end

function moont.rev(tab)
  local a = {}
  for i = #tab,1,-1 do
    insert(a,tab[i])
  end
  return a
end

function moont.shift(tab,pl)
  pl = pl or 1
  local x
  if pl >= 1 then x = 1 else x = -1 end
  for i = 1,pl,x do
    insert(tab,1,tab[#tab])
    remove(tab,#tab)
  end
  return tab
end

function moont.clear(time)
  local destroy = proAudio.destroy
  sleep(time)
  destroy()
  os.exit()
end
-- .ogg player  [proAudioRt can't handle high quality .wav files]
function moont.sample(tipo)
  tipo.disparity = tipo.disparity or 0
  tipo.pitch = tipo.pitch or tono 
  local direc = "../Samples/Sounds/"
  local sample = fromFile(direc..tipo.file..".ogg")
  sonido = soundPlay(sample,tipo.L,tipo.R,tipo.disparity,tipo.pitch)
end

function moont.choose(...)
  local var = {...}
  return var[math.random(#var)]
end

function moont.shuffle(list)
   local shuffled = {}
  each(list,function(index,value)
    local randPos = math.floor(math.random()*index)+1
    shuffled[index] = shuffled[randPos]
    shuffled[randPos] = value
    end)
  return shuffled
end

function moont.range(...)
  local arg = {...}
  local start,stop,step
  if #arg==0 then return {}
  elseif #arg==1 then stop,start,step = arg[1],0,1
  elseif #arg==2 then start,stop,step = arg[1],arg[2],1
  elseif #arg == 3 then start,stop,step = arg[1],arg[2],arg[3]
  end
  if (step and step==0) then return {} end
  local ranged = {}
  local steps = math.max(math.floor((stop-start)/step),0)
  for i=1,steps do ranged[#ranged+1] = start+step*i end
  if #ranged>0 then insert(ranged,1,start) end
  return ranged
end

function moont.l_seq(v)
  v.pitch = v.pitch or tono
  v.disparity = v.disparity or 0
  v.dur = v.dur or 1/4
  v.scale = v.scale or 24
  v.gen = v.gen or Gen.vR(1,1,100,1,1)
  v.L = v.L or 0.5
  v.R = v.R or v.L
  do
    if type(moont.bank[v.seq]) == "function" then moont.bank[v.seq](v.dur)
      elseif type(moont.bank[v.seq]) == "nil" then Gen.play(v.scale,v.gen,v.seq,v.dur,v.L/10,v.R/10,v.disparity)
      else moont.soundPlay(moont.bank[v.seq],v.Ls,v.Rs,v.disparity,v.pitch)
    end
  end
end

function moont.midi_notes()
  local a = "c c# d d# e f f# g g# a a# b"
  local t = {}
  local c = 0
  for i = -1, 8 do
    for _ in a:gmatch'%g+' do
      t[_..i] = c
      c = c + 1
    end
  end
  return t
end

local notes = moont.midi_notes()

function moont.chord(t, c, i, f, v, p, ch)
  v = v or 77
  p = p or 0
  ch = ch or 1
  if c == i then
    for _, q in ipairs(t) do
      noteOn(p, notes[q] or q, v, ch)
    end
  elseif c == f then
    for _, q in ipairs(t) do
      noteOff(p, notes[q] or q, v, ch)
    end
  end
end

function moont.play_midi(port,note,vel,ch,dur)
  port = port or 1
  ch = ch or 1
  vel = vel or 70
  dur = dur or 0
  do
    noteOn(port,note,vel,ch)  
    moont.sleep(dur)
    noteOff(port,note,vel,ch)
  end
end

function moont.m_seq(foo)
  foo.port = foo.port or 1
  foo.dur = foo.dur or 0.5
  foo.L = foo.L or 0.5
  foo.R = foo.R or foo.L
  foo.disparity = foo.disparity or 0
  foo.pitch = foo.pitch or tone
  do
    if type(bank[foo.seq]) == "function" then bank[foo.seq](foo.dur)
    elseif type(foo.seq) == "number" then
      moont.play_midi(foo.port,foo.seq,foo.vel,foo.channel,foo.dur)
    elseif #foo.seq > 1 then moont.play_midi(foo.port,notes[foo.seq],foo.vel,foo.channel,foo.dur)
    else
      soundPlay(bank[foo.seq],foo.L,foo.R,foo.disparity,foo.pitch)
    end
  end
end

return moont