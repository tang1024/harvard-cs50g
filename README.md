# harvard-cs50g

## pong

test environment: love-11.3-win64

- issue: love 0.11.1 'love.window.getPixelScale()' is replaced with 'love.window.getDPIScale()'.

solution: open up push.lua in IDE and replace 'love.window.getPixelScale()' with 'love.window.getDPIScale()'.

reference: https://github.com/cs50/mario-demo/issues/2

- issue: white screen

solution: replaced ``love.graphics.clear(40, 45, 52, 255)`` with ``love.graphics.clear(40/255, 45/255, 52/255, 255/255)``
