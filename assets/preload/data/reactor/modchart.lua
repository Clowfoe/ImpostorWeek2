 -- this gets called starts when the level loads.
function start(song) -- arguments, the song name

end

-- this gets called every frame
function update(elapsed) -- arguments, how long it took to complete a frame

end

-- this gets called every beat
function beatHit(beat) -- arguments, the current beat of the song
    
end

-- this gets called every step
function stepHit(step) -- arguments, the current step of the song (4 steps are in a beat)
    if CurStep == 515 then
        showOnlyStrums = true
    end
end