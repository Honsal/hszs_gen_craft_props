GenerateZSJunks = {}

local this = GenerateZSJunks
this.MinSearchRange = 120
this.MaxSearchRange = 1000
this.SearchRange = this.MinSearchRange
this.maxRepeat = 100

local startoffset = Vector(0, 0, 20)

function this.RandomizeDirection(dir)
    local ang = dir:Angle()
    ang.pitch = math.Rand(ang.pitch - 90, ang.pitch + 90)
    ang.yaw = math.Rand(ang.yaw - 90, ang.yaw + 90)
    return ang:Forward()
end

local cr = coroutine.create(function()
	for _, v in pairs(team.GetSpawnPoint(TEAM_HUMAN)) do 
		local start = v:GetPos() + startoffset // 추적 시작 지점은 스폰지점에서 위로 20만큼 떨어진 지점
		local td = {}
		td.start = start
		td.filter = {}
		local dir = Angle(math.Rand(-30, 30), math.Rand(-90, 90), 0):Forward()
		for i = 1, this.maxRepeat * 2 do
			coroutine.yield()
			local repeated = 0
			repeat
				dir = this.RandomizeDirection(dir)
				td.endpos = td.start + dir * this.SearchRange
				tr = util.TraceLine(td)
				-- this.SearchRange = math.Clamp(this.SearchRange + (this.MaxSearchRange * (tr.HitPos - tr.StartPos):Length()), this.MinSearchRange, this.MaxSearchRange)
				this.SearchRange = math.Rand(this.MinSearchRange, this.MaxSearchRange)
				repeated = repeated + 1
			until (!tr.Hit or repeated >= this.maxRepeat) and !tr.HitSky and (tr.Entity and tr.Entity ~= NULL)
			td.start = tr.HitPos
			table.insert(td.filter, table.Count(td.filter) + 1, this.SpawnJunkBox(tr.HitPos))
			coroutine.yield()
		end
	end
	
	hook.Remove("Think", "HSZSGenCraftProps")
end)

function this.Init()
	if string.find(game.GetMap(), "_obj") or string.find(game.GetMap(), "objective") then
		return false
	end
	hook.Add("Think", "HSZSGenCraftProps", function()
		coroutine.resume(cr)
	end)
end

// 위치에 정크박스 생성
function this.SpawnJunkBox(pos)
    local num = math.random(1000)
    if num < 500 or num >= 505 then
        return
    end
    local ent = ents.Create("prop_physics")
    for _, items in pairs(GAMEMODE.Crafts) do
        ent:SetModel(
            table.Random({
				"models/props_junk/wood_crate001a.mdl", 
				"models/props_junk/wood_crate001a_damaged.mdl", 
				"models/props_junk/wood_crate001a_damagedmax.mdl",
				"models/props_junk/wood_crate001a.mdl",
				"models/props_junk/wood_crate001a_damaged.mdl",
				"models/props_junk/wood_crate001a_damagedmax.mdl",
				"models/props_combine/breenbust.mdl",
				"models/props_junk/gascan001a.mdl",
				"models/props_c17/oildrum001.mdl",
				"models/props_junk/sawblade001a.mdl",
				"models/props_c17/oildrum001_explosive.mdl",
				"models/items/car_battery01.mdl",
				"models/props_junk/sawblade001a.mdl",
				"models/mine/floodlight.mdl",
				"models/mine/floodlight.mdl",
				"models/mine/floodlight.mdl",
			})
        )
    end
    ent:SetPos(pos + Vector(0, 0, 30))
    ent:Spawn()
    return ent
end

hook.Add("InitPostEntityMap", "GenerateZSJunks", GenerateZSJunks.Init)