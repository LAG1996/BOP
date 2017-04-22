local BulletHandler = {
}

local Handler = {}

--When a bullet is deflected, it will spin around for a while before it ultimately fades out.
--Each frame, the bullet will spin at the specified rotation speed and its deadTime timer will increment by delta time.
--Delta time may be a rather imprecise way of measuring the time, but that ultimately doesn't matter in this case since the bullet won't interact
--with the player anymore.
function Handler:Deflect(dt, rotateSpeed)
	self._deadTime = self.deadTime + dt
	self._rotation = self.rotation + dt*rotateSpeed
end

--Returns whether the bullet has been deflected or not
function Handler:isDeflected()
	return self.HP == 0
end

--If the bullet has been "dead" for at least 1.5 seconds.
function Handler:canFadeOut()
	return self._deadTime >= 1.5
end

function BulletHandler.new(facing, rotation, HP, x, y)
	local bulletHandler = setmetatable({
		_facing = facing or 1, --Sets which way a bullet is facing. This is just a convenience for when we're moving it.
		_rotation = rotation or 0 --Sets which way a bullet is rotated. This works as both a convenience for movement and also for when the bullet spins in rotation
		_deadTime = 0, --Initialize _deadTime timer
		_HP = HP or 1, --Initialize bullet durability. Some bullets such as rockets will have higher resistances. This also works as our check for whether a bullet has
						--been deflected
		--Store the positions of the bullet for convenience
		_x = x or 0,
		_y = y or 0,
		}, {__index = Handler})
	return bulletHandler
end

return BulletHandler