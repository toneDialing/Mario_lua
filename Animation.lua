Animation = Class{}

function Animation:init(parameters) -- 'parameters' is a table
    self.texture = parameters.texture
    self.frames = parameters.frames
    self.interval = parameters.interval or 0.05
        -- if parameters.interval doesn't exist, default to 0.05
    self.timer = 0
    self.current_frame = 1 -- index value for self.frames
end

function Animation:get_current_frame()
    return self.frames[self.current_frame]
end

function Animation:restart()
    self.timer = 0
    self.current_frame = 1
end

function Animation:update(dt)
    self.timer = self.timer + dt

    if #self.frames==1 then
        return self.current_frame
    else
        while self.timer > self.interval do
            self.timer = self.timer - self.interval
            
            self.current_frame = (self.current_frame + 1) % (#self.frames + 1)
            if self.current_frame==0 then self.current_frame=1 end
        end
    end
end