local anim8
local boi_image
local button_image
local explosion_image
local money_image
local moneyMaker_image
local ending_image
local coffinDance_image
local boi_grid
local boi_anim
local boi
local text
local button
local drawExplosion
local gamestate
local objects
local world
local coffinDance
local explosion_sfx
local step_sfx
local coffinDance_mus

function love.load()
  anim8 = require('anim8')
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setFont(love.graphics.newFont(60))
  boi_image = love.graphics.newImage('images/boi.png')
  button_image = love.graphics.newImage('images/button.png')
  explosion_image = love.graphics.newImage('images/boom.png')
  money_image = love.graphics.newImage('images/money.png')
  moneyMaker_image = love.graphics.newImage('images/money button.png')
  ending_image = love.graphics.newImage('images/ending.png')
  coffinDance_image = love.graphics.newImage('images/coffin dance.png')
  boi_grid = anim8.newGrid(100, 100, boi_image:getWidth(), boi_image:getHeight())
  boi_anim = anim8.newAnimation(boi_grid('1-2',1), 0.1)
  boi = {}
  boi.x = love.graphics.getWidth() / 2
  boi.y = love.graphics.getHeight() / 2
  boi.r = 0
  boi.speed = 350
  boi.xscale = 1
  boi.yscale = 1
  text = 'press arrow keys to move'
  button = {}
  button.x, button.y = love.graphics.getWidth() - 400, 200
  moneyMaker = {}
  moneyMaker.x, moneyMaker.y = 400, 200
  explosion_grid = anim8.newGrid(400, 564, explosion_image:getWidth(), explosion_image:getHeight())
  explosion_anim = anim8.newAnimation(explosion_grid('1-9',1), 0.1)
  drawExplosion = false
  gamestate = 0
  world = love.physics.newWorld(0, 100, true)
  objects = {}
  objects.dollars = {}
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, love.graphics.getWidth() / 2, love.graphics.getHeight() + 15)
  objects.ground.shape = love.physics.newRectangleShape(love.graphics.getWidth(), 30)
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
  objects.wall1 = {}
  objects.wall1.body = love.physics.newBody(world, -15, love.graphics.getHeight() / 2)
  objects.wall1.shape = love.physics.newRectangleShape(30, love.graphics.getHeight())
  objects.wall1.fixture = love.physics.newFixture(objects.wall1.body, objects.wall1.shape)
  objects.wall2 = {}
  objects.wall2.body = love.physics.newBody(world, love.graphics.getWidth() + 15, love.graphics.getHeight() / 2)
  objects.wall2.shape = love.physics.newRectangleShape(30, love.graphics.getHeight())
  objects.wall2.fixture = love.physics.newFixture(objects.wall2.body, objects.wall2.shape)
  coffinDance_grid = anim8.newGrid(200, 200, coffinDance_image:getWidth(), coffinDance_image:getHeight())
  coffinDance_anim = anim8.newAnimation(coffinDance_grid('1-2',1), 0.5)
  coffinDance = {}
  coffinDance.x, coffinDance.y = love.graphics.getWidth() * 0.75, love.graphics.getHeight() * 0.75
  coffinDance.direction = 'left'
  coffinDance.Xscale = 1
  coffinDance.Yscale = 1
  explosion_sfx = love.audio.newSource('audio/explosion.ogg', 'static')
  step_sfx = love.audio.newSource('audio/step.ogg', 'static')
  coffinDance_mus = love.audio.newSource('audio/coffin dance 8 bit.ogg', 'stream')
end


function love.update(dt)
  world:update(dt)
  if gamestate == 0 then
    local velocity = {x=0, y=0}
    local iswalking = false
    text = 'press arrow keys to move'
    if drawExplosion == false then
      if love.keyboard.isDown('left') then
        velocity.x = -1
        boi.xscale = -1
        iswalking = true
      elseif love.keyboard.isDown('right') then
        velocity.x = 1
        boi.xscale = 1
        iswalking = true
      end
      if love.keyboard.isDown('up') then
        velocity.y = -1
        iswalking = true
      elseif love.keyboard.isDown('down') then
        velocity.y = 1
        iswalking = true
      end
    end
    velocity.x, velocity.y = normalize(velocity.x, velocity.y)
    boi.x = boi.x + velocity.x * boi.speed * dt
    boi.y = boi.y + velocity.y * boi.speed * dt
    if iswalking then
      boi_anim:update(dt)
      step_sfx:play()
    end
    
    if boi.x > love.graphics.getWidth() + 50 then
      boi.x = -50
    end
    if boi.x < -50 then
      boi.x = love.graphics.getWidth() + 50
    end
    if boi.y > love.graphics.getHeight() + 50 then
      boi.y = -50
    end
    if boi.y < -50 then
      boi.y = love.graphics.getHeight() + 50
    end
    
    if distance(boi.x, boi.y, button.x, button.y) <= 80 then
      text = 'press "z" to die'
    end
    if distance(boi.x, boi.y, moneyMaker.x, moneyMaker.y) <= 80 then
      text = 'press "z" to make money'
      if love.keyboard.isDown('z') then
        makeMoney()
      end
    end
    if drawExplosion == true then
      explosion_anim:update(dt)
    end
    
    if #objects.dollars > 1000 then
      objects.dollars[1].fixture:destroy()
      table.remove(objects.dollars, 1)
    end
    if explosion_anim.position == 9 then
      gamestate = 1
    end
  end
  if gamestate == 1 then
    coffinDance_mus:play()
    coffinDance_anim:update(dt)
    if coffinDance.x <= love.graphics.getWidth() * 0.25 then
      coffinDance.direction = 'right'
    elseif coffinDance.x >= love.graphics.getWidth() * 0.75 then
      coffinDance.direction = 'left'
    end
    local xVelocity
    if coffinDance.direction == 'right' then
      xVelocity = 80
      coffinDance.Xscale = -1
    else
      xVelocity = -80
      coffinDance.Xscale = 1
    end
    coffinDance.x = coffinDance.x + xVelocity * dt
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    love.event.quit()
  end
  if gamestate == 0 then
    if distance(boi.x, boi.y, button.x, button.y) <= 80 and key == 'z' then
      drawExplosion = true
      explosion_sfx:play()
    end
  end
end


function love.draw()
  love.graphics.setBackgroundColor(0, 1, 0)
  if gamestate == 0 then
    love.graphics.draw(
      button_image, button.x, button.y,
      0, 1, 1,
      50, 50)
    love.graphics.draw(
      moneyMaker_image, moneyMaker.x, moneyMaker.y,
      0, 1, 1,
      50, 50)
    boi_anim:draw(
      boi_image,
      boi.x, boi.y,
      boi.r, boi.xscale, boi.yscale,
      50, 50)
    if drawExplosion then
      explosion_anim:draw(
        explosion_image,
        boi.x, boi.y,
        0, 1, 1,
        explosion_image:getWidth() / 18, explosion_image:getHeight() / 2)
    end
    for i, dollar in ipairs(objects.dollars) do
      love.graphics.draw(money_image, dollar.body:getX(), dollar.body:getY())
    end
    love.graphics.printf(text, 0, love.graphics.getHeight() - 250, love.graphics.getWidth(), 'center')
  end
  if gamestate == 1 then
    love.graphics.draw(ending_image)
    coffinDance_anim:draw(
      coffinDance_image,
      coffinDance.x, coffinDance.y,
      0, coffinDance.Xscale, coffinDance.Yscale,
      100, 100)
  end
end


function makeMoney()
  local dollar = {}
  dollar.body = love.physics.newBody(world, math.random(30, love.graphics.getWidth() - 30), 0, 'dynamic')
  dollar.shape = love.physics.newRectangleShape(40, 20)
  dollar.fixture = love.physics.newFixture(dollar.body, dollar.shape)
  dollar.fixture:setRestitution(1)
  table.insert(objects.dollars, dollar)
end


function normalize(x,y)
  local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end


function distance(x1,y1,x2,y2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end
