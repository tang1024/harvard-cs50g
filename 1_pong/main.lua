-- https://github.com/Ulydev/push
push = require("push")
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

require("paddle")
require("Ball")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
WINNING_SCORE = 2

MAIN_BALL_SPEED_Y = 10
MAIN_BALL_SPEED_X_MIN = 200
MAIN_BALL_SPEED_X_MAX = 300

function init_fonts()
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)
end

function init_sound()
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static')
    }
end

function init_gameplay()
    hit_flag_paddle = false
    hit_flag_wall   = false
    score_flag      = false

    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    servingPlayer = 1

    gameState = 'start'
end

function init_window()
    love.window.setTitle('Pong')
    push:setupScreen(
        VIRTUAL_WIDTH,
        VIRTUAL_HEIGHT,
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        {
            fullscreen = false,
            resizable = true,
            vsync = true
        }
    )
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    init_fonts()
    init_sound()
    init_gameplay()
    init_window()
end

function love.keypressed( key )
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end

            gameState = 'serve'
        end
    end
end

function update_serve()
    ball.dy = math.random(-MAIN_BALL_SPEED_Y, MAIN_BALL_SPEED_Y)
    if servingPlayer == 1 then
        ball.dx = math.random(MAIN_BALL_SPEED_X_MIN, MAIN_BALL_SPEED_X_MAX)
    else
        ball.dx = -math.random(MAIN_BALL_SPEED_X_MIN, MAIN_BALL_SPEED_X_MAX)
    end
end

function update_collision()
    hit_flag_paddle = false
    hit_flag_wall   = false

    if ball:collides(player1) then
        ball.dx = -ball.dx * 1.03
        ball.x = player1.x + 5

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        hit_flag_paddle = true
    end

    if ball:collides(player2) then
        ball.dx = -ball.dx * 1.03
        ball.x = player2.x - 4

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        hit_flag_paddle = true
    end

    if ball.y <= 0 then
        ball.y = 0
        ball.dy = -ball.dy

        hit_flag_wall = true
    end

    if ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.y = VIRTUAL_HEIGHT - 4
        ball.dy = -ball.dy

        hit_flag_wall = true
    end
end

function update_play()
    score_flag = false

    if ball.x < 0 then
        score_flag = true

        servingPlayer = 1
        player2Score = player2Score + 1
        
        if player2Score == WINNING_SCORE then
            winningPlayer = 2
            gameState = 'done'
        else
            gameState = 'serve'
            ball:reset()
        end
    end

    if ball.x > VIRTUAL_WIDTH then
        score_flag = true

        servingPlayer = 2
        player1Score = player1Score + 1

        if player1Score == WINNING_SCORE then
            winningPlayer = 1
            gameState = 'done'
        else
            gameState = 'serve'
            ball:reset()
        end
    end
end

function play_sound()
    if hit_flag_paddle then
        sounds['paddle_hit']:play()
    elseif hit_flag_wall then
        sounds['wall_hit']:play()
    elseif score_flag then
        sounds['score']:play()
    end
end

function love.update(dt)
    if gameState == 'serve' then
        update_serve()
    elseif gameState == 'play' then
        update_collision()
        update_play()
        play_sound()
    end

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 1)

    player1:render()
    player2:render()
    ball:render()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    displayScore()
    displayFPS()

    push:apply('end')
end
