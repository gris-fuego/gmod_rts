if CLIENT then return end

util.AddNetworkString("gohere")

net.Receive("gohere", function(vec,tbl)
    targets = net.ReadTable()
	for k, v in pairs(targets) do
        local target = Entity(k)
        if !target:IsNextBot() then print("error") end
        target:SetDestination(v)
    end
end)
