SWEP.Author              = "Fire"
SWEP.Contact             = ""
SWEP.Purpose             = "RTS Mode"
SWEP.Instructions        = "Cry"
SWEP.Category = "Fire's SWEPs"
SWEP.PrintName = "RTS Mode"
SWEP.Spawnable                  = true

SWEP.ViewModel                  = ""
SWEP.HoldType                   = "normal"

SWEP.Primary.ClipSize           = -1
SWEP.Primary.DefaultClip        = -1
SWEP.Primary.Automatic          = false
SWEP.Primary.Ammo               = "none"

SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo             = "none"


if CLIENT then
    local posunits        = {}
    local originx,originy = 0,0
    local newx,newy       = 0,0
    local pass = false
    local secondPass = false
    local screenclicker = false
    local mouseX, mouseY = input.GetCursorPos()
    local units = {}
    local selUnits = {}
    local unitDests = {}
    local unitTargets = {}
    local unitSpacing = 100
    local mouseRestore = false
    function SWEP:DrawHUD()
        if input.IsMouseDown(MOUSE_RIGHT) then
            if screenclicker then
                mouseX, mouseY = input.GetCursorPos()
                screenclicker = false
                gui.EnableScreenClicker(false)
            end
        else
            if !screenclicker then
                screenclicker = true
                gui.EnableScreenClicker(true)
                mouseRestore = 5
                input.SetCursorPos(mouseX, mouseY)
            end
        end
        local cursorX,cursorY = input.GetCursorPos()
        
        -- This really sucks but the game keeps resetting the mouse to the middle of the screen
        if mouseRestore > 0 then
            input.SetCursorPos(mouseX, mouseY)
            mouseRestore = mouseRestore - 1
        end

        
        if input.IsMouseDown(MOUSE_FIRST) then	
            if !pass then
                pass = true 
                originx,originy = input.GetCursorPos()
            end

            newx,newy   = gui.MousePos()

            if math.abs(originx - newx) > 6 or math.abs(originy - newy) > 6 then

                surface.DisableClipping(true)
                surface.SetDrawColor(51, 153, 255, 255)

                surface.DrawOutlinedRect(originx, originy, newx - originx, newy - originy)

                surface.SetDrawColor(51, 153, 255, 50)

                surface.DrawRect(originx, originy, newx - originx, newy - originy)

                units = {}

                for k, v in pairs(ents.GetAll()) do
                    if !v:IsNextBot() then continue end
                    local entPos = v:LocalToWorld(v:OBBCenter()):ToScreen()
                    if ((originx < entPos.x and entPos.x < newx) or (originx > entPos.x and entPos.x > newx)) and ((originy < entPos.y and entPos.y < newy) or (originy > entPos.y and entPos.y > newy)) then
                        table.insert(units, v)
                    end
                end
            end
        else
            if pass then
                secondPass = false
                if math.abs(originx - newx) > 6 or math.abs(originy - newy) > 6 then
                    selUnits = units
                    pass = false
                else
                    pass = false

                    local movex,movey = input.GetCursorPos()
                    local gridSize = math.ceil(math.sqrt(table.Count(units)))
                    local movepos = util.QuickTrace(LocalPlayer():GetPos(), gui.ScreenToVector(movex,movey)*16384, self.Owner).HitPos
                    local movecornerpos = Vector(movepos[1] - (gridSize / 2 * unitSpacing), movepos[2] - (gridSize / 2 * unitSpacing), movepos[3])
                    local unitTargets = {}
                    if table.Count(units) > 0 then
                        for k, v in ipairs(selUnits) do
                            local toPosx = movecornerpos[1] + math.floor(k / gridSize) * unitSpacing
                            local toPosy = movecornerpos[2] + math.floor(k % gridSize) * unitSpacing
                            local toPos = Vector(toPosx, toPosy, movepos[3])
                            unitTargets[v:EntIndex()] = toPos
                        end

                        GoHere(unitTargets)
                    end
                end
            end

            if table.Count(units) > 0 then 
                for k, v in pairs(selUnits) do
                    local entPos = (v:GetPos() + v:OBBCenter()):ToScreen()
                    surface.DrawCircle(entPos.x, entPos.y, 8, 64, 128, 255, 255)
                end
            end
        end
    end
end
