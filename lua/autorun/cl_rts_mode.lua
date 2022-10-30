if SERVER then return end

function GoHere(unitTargets)
	net.Start("gohere")
	net.WriteTable(unitTargets)
	net.SendToServer()
end

list.Set("DesktopWindows", "RTS", {
	title = "RTS Mode",
	icon = "icon64/playermodel.png",
	init = function( icon, window )
		RTS:OpenMenu()
	end
})