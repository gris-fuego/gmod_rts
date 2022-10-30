AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Spawnable = true

function ENT:Initialize()

	self:SetModel("models/mossman.mdl")
    self:StartActivity( ACT_IDLE )
	
	-- self.LoseTargetDist	= 2000	-- How far the enemy has to be before we lose them
	-- self.SearchRadius 	= 1000	-- How far to search for enemies
    self.Destination = nil
	
end

function ENT:SetDestination(dest)
    self.Destination = dest
end
function ENT:GetDestinationy()
	return self.Destination
end

function ENT:HandleStuck()
    -- this helps, but need to improve it
    self.loco:Jump()
	self.loco:ClearStuck();
end

function ENT:MoveToPos2( pos, options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() ) do

        if self.Destination then
            --path:Invalidate
            return "interrupted"
        end

		path:Update( self )

		-- Draw the path (only visible on listen servers or single player)
		if ( options.draw ) then
			path:Draw()
		end

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then

			self:HandleStuck()

			return "stuck"

		end

		--
		-- If they set maxage on options then make sure the path is younger than it
		--
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		--
		-- If they set repath then rebuild the path every x seconds
		--
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end

		coroutine.yield()

	end

	return "ok"

end

function ENT:RunBehaviour()
	while (true) do
        if self.Destination then
            self:StartActivity(ACT_RUN)
            self.loco:SetDesiredSpeed(450)
            local dest = self.Destination
            self.Destination = nil
            self:MoveToPos2(dest)
            self:StartActivity(ACT_IDLE)
        end
		coroutine.yield()
	end

end

list.Set( "NPC", "test_bot", {
	Name = "Test Bot",
	Class = "test_bot",
	Category = "Nextbot"
} )