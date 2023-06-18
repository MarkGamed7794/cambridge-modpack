require 'funcs'

-- This is the ORIGINAL Score Drain mode by MarkGamed. The other one in the modpack is a recreation by Milla, and was not officially endorsed by me.

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls_35bag'

local ScoreDrainGame = GameMode:extend()

ScoreDrainGame.name = "Score Drain (Original)"
ScoreDrainGame.hash = "ScoreDrainGame"
ScoreDrainGame.tagline = "Your score has a leak! Try to keep it up for as long as you can!"

local last_frame_time = 0


function ScoreDrainGame:new()
    ScoreDrainGame.super:new()
	self.score = 2500
    self.level = 0
	self.roll_frames = 0
    self.combo = 1
	self.grade = 0
	self.grade_points = 0
	self.roll_points = 0
	self.grade_point_decay_counter = 0
    
	self.randomizer = History6RollsRandomizer()
	
    self.lock_drop = true
    self.lock_hard_drop = true
	self.enable_hold = true
	self.next_queue_length = 3
	self.score_text = 0
	self.score_text_timer = 0
	
	self.drain_speed = 50
	
	last_frame_time = self.frames
end

function ScoreDrainGame:getARE()
        if self.level < 700 then return 27
    elseif self.level < 800 then return 18
    elseif self.level < 1000 then return 14
    elseif self.level < 1100 then return 8
    elseif self.level < 1200 then return 7
    else return 6 end
end

function ScoreDrainGame:getLineARE()
        if self.level < 600 then return 27
    elseif self.level < 700 then return 18
    elseif self.level < 800 then return 14
    elseif self.level < 1100 then return 8
    elseif self.level < 1200 then return 7
    else return 6 end
end

function ScoreDrainGame:getDasLimit()
        if self.level < 500 then return 15
    elseif self.level < 900 then return 9
    else return 7 end
end

function ScoreDrainGame:getLineClearDelay()
        if self.level < 500 then return 40
    elseif self.level < 600 then return 25
    elseif self.level < 700 then return 16
    elseif self.level < 800 then return 12
    elseif self.level < 1100 then return 6
    elseif self.level < 1200 then return 5
    else return 4 end
end

function ScoreDrainGame:getLockDelay()
        if self.level < 900 then return 30
    elseif self.level < 1100 then return 17
    else return 15 end
end

function ScoreDrainGame:getGravity()
        if (self.level < 30)  then return 4/256
    elseif (self.level < 35)  then return 6/256
    elseif (self.level < 40)  then return 8/256
    elseif (self.level < 50)  then return 10/256
    elseif (self.level < 60)  then return 12/256
    elseif (self.level < 70)  then return 16/256
    elseif (self.level < 80)  then return 32/256
    elseif (self.level < 90)  then return 48/256
    elseif (self.level < 100) then return 64/256
    elseif (self.level < 120) then return 80/256
    elseif (self.level < 140) then return 96/256
    elseif (self.level < 160) then return 112/256
    elseif (self.level < 170) then return 128/256
    elseif (self.level < 200) then return 144/256
    elseif (self.level < 220) then return 4/256
    elseif (self.level < 230) then return 32/256
    elseif (self.level < 233) then return 64/256
    elseif (self.level < 236) then return 96/256
    elseif (self.level < 239) then return 128/256
    elseif (self.level < 243) then return 160/256
    elseif (self.level < 247) then return 192/256
    elseif (self.level < 251) then return 224/256
    elseif (self.level < 300) then return 1
    elseif (self.level < 330) then return 2
    elseif (self.level < 360) then return 3
    elseif (self.level < 400) then return 4
    elseif (self.level < 420) then return 5
    elseif (self.level < 450) then return 4
    elseif (self.level < 500) then return 3
    else return 20
    end
end

function ScoreDrainGame:advanceOneFrame()
	if self.ready_frames == 0 then
		self.frames = self.frames + 1
	end
	return true
end

function ScoreDrainGame:onPieceEnter()
	if (self.level % 100 ~= 99) and self.frames ~= 0 then
        self.level = self.level + 1
    end
end

function ScoreDrainGame:onLineClear(cleared_row_count)
    self.level = self.level + cleared_row_count
    self.level = self.level + cleared_row_count
end

scoreNums = {0,100,200,500,800}

function ScoreDrainGame:updateScore(level, drop_bonus, cleared_lines)
	if cleared_lines > 0 then
		local addScore = (
			(math.ceil((level + cleared_lines) / 4) + drop_bonus) *
			cleared_lines * (cleared_lines * 2 - 1) * (self.combo * 2 - 1)
		)
		self.score = self.score + addScore
		self.lines = self.lines + cleared_lines
		self.combo = self.combo + cleared_lines - 1
		self.score_text = addScore
		self.score_text_timer = 120
	else
		self.drop_bonus = 0
		self.combo = 1
	end
end

function ScoreDrainGame:drawGrid()
	self.grid:draw()
	if self.piece ~= nil and self.level < 100 then
		self:drawGhostPiece(ruleset)
	end
end

ScoreDrainGame.rollOpacityFunction = function(age)
	if age < 240 then return 1
	elseif age > 300 then return 0
	else return 1 - (age - 240) / 60 end
end

ScoreDrainGame.mRollOpacityFunction = function(age)
	if age > 4 then return 0
	else return 1 - age / 4 end
end

function ScoreDrainGame:drawScoringInfo()
	if(self.score <= 0 and not self.game_over) then
		self.game_over = true
		self.score = 0
	end
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_3x5_2)
	love.graphics.print(
		self.das.direction .. " " ..
		self.das.frames .. " " ..
		strTrueValues(self.prev_inputs)
	)
	self.drain_speed = 50*(1.5^math.floor(self.level/100))
	love.graphics.printf("NEXT", 64, 40, 40, "left")
	love.graphics.printf("DRAIN SPEED", 240, 90, 120, "left")
	love.graphics.printf("SCORE", 240, 160, 40, "left")
	love.graphics.printf("UNTIL DEPLETION", 240, 250, 160, "left")
	love.graphics.printf("LEVEL", 240, 320, 40, "left")
	local sg = self.grid:checkSecretGrade()
    if sg >= 5 then
        love.graphics.printf("SECRET GRADE", 240, 430, 180, "left")
    end
	
	love.graphics.setFont(font_3x5_3)
	if not self.game_over and self.score < self.drain_speed*10 and self.frames % 4 < 2 then
		love.graphics.setColor(1, 0.3, 0.3, 1)
	end
	love.graphics.printf(math.floor(self.score), 240, 180, 90, "left")
	if self.score_text_timer > 0 then
		love.graphics.setColor(1, 1, 0.3, 1)
		self.score_text_timer = self.score_text_timer-1
		love.graphics.printf("(+"..(self.score_text)..")", 240, 205, 160, "left")
	end
	love.graphics.setColor(1,1,1,1)
	love.graphics.printf(math.floor(self.drain_speed).."/s", 240, 110, 90, "left")
	love.graphics.printf(formatTime(self.score/self.drain_speed*60), 240, 270, 180, "left")
	love.graphics.printf(self.level, 240, 340, 50, "right")
	love.graphics.printf(self:getSectionEndLevel(), 240, 370, 50, "right")

	love.graphics.setFont(font_8x11)
	love.graphics.printf(formatTime(self.frames), 64, 420, 160, "center")
	
	if(self.frames > 0) then
		self.score = self.score - (self.frames-last_frame_time)/60*self.drain_speed
		last_frame_time = self.frames*1
	end
end

function ScoreDrainGame:getHighscoreData()
	return {
		level = self.level,
		frames = self.frames,
	}
end

function ScoreDrainGame:getSectionEndLevel()
	 return math.floor(self.level / 100 + 1) * 100
end

function ScoreDrainGame:getBackground()
	return math.floor(self.level / 100)%10
end

return ScoreDrainGame
