local Version = 1.0

TargetRange = {}
if not EnemyTarget then EnemyTarget = {} end
if not EnemyTarget.LatestGuardName then EnemyTarget.LatestGuardName = nil end
if not EnemyTarget.GuarderData then EnemyTarget.GuarderData = {Name=L"",IsGuarding = false,XGuard = false,ID=0,Career=0,distance= -1,XGuard=false} end

local MAX_MAP_POINTS = 511
local DISTANCE_FIX_COEFFICIENT = 1 / 1.06
local MapPointTypeFilter = {
	[SystemData.MapPips.PLAYER] = true,
	[SystemData.MapPips.GROUP_MEMBER] = true,
	[SystemData.MapPips.WARBAND_MEMBER] = true,
	[SystemData.MapPips.DESTRUCTION_ARMY] = true,
	[SystemData.MapPips.ORDER_ARMY] = true
}

local SEND_BEGIN = 1
local SEND_FINISH = 2
TargetRange.ShieldIcons = {[1]=4515,[5]=2558,[10]=8078,[13]=5172,[17]=13373,[21]=11018}
TargetRange.StateTimer = 0.1

TargetRange.DefaultColor = {R=255,G=255,B=255}
TargetRange.CloseColor = {R=50,G=255,B=50}
TargetRange.MidColor = {R=100,G=100,B=255}
TargetRange.FarColor = {R=255,G=50,B=50}
TargetRange.Distant = {R=125,G=125,B=125}

if not EnemyTarget.TargetData then EnemyTarget.TargetData = {Name=L"",IsGuarding = false,XGuard = false,ID=0,Career=0,distance= -1,XGuard=false} end


function TargetRange.Initialize()

RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "TargetRange.UpdateTargets")
CreateWindow("TargetRange_Window0", true)
LayoutEditor.RegisterWindow( "TargetRange_Window0", L"Target List", L"Target List", true, true, false)
CircleImageSetTexture("TargetRange_Window0ShieldIcon","TargetIcon", 32, 32)
LabelSetText("TargetRange_Window0Label",L"--")
LabelSetText("TargetRange_Window0LabelBG",L"--")
TargetRange.stateMachineName = "TargetRange"
TargetRange.state = {[SEND_BEGIN] = { handler=nil,time=TargetRange.StateTimer,nextState=SEND_FINISH } , [SEND_FINISH] = { handler=TargetRange.UpdateStateMachine,time=TargetRange.StateTimer,nextState=SEND_BEGIN, } , }
TargetRange.StartMachine()
AnimatedImageStartAnimation ("TargetRange_Window0Glow", 0, true, true, 0)


	for i=1,5 do
		CreateWindowFromTemplate("TargetRange_Window"..i, "TargetRange_Window0", "Root")
		WindowClearAnchors("TargetRange_Window"..i)
		WindowAddAnchor( "TargetRange_Window"..i , "bottom", "TargetRange_Window"..(i-1), "top", 0,7)
		WindowSetMovable( "TargetRange_Window"..i, false )
	end

end

function TargetRange.StartMachine()
	local stateMachine = TimedStateMachine.New( TargetRange.state,SEND_BEGIN)
	TimedStateMachineManager.AddStateMachine( TargetRange.stateMachineName, stateMachine )
end

function TargetRange.ComparePlayers( index,tablename )
    table.sort(index, function (a,b)
    return (a.distance < b.distance)
	end)

end

function TargetRange.SortPlayers(array)
if array == nil then return end
	local Index = 0
	local sortedPlayers = {};
	for k, v in pairs(array)
	do
		table.insert(sortedPlayers,v);
		Index = Index+1
	end
	if Index > 1 then
	table.sort(sortedPlayers, function(a,b) return a.distance < b.distance end);
	end
	return sortedPlayers;
end

function TargetRange.UpdateTargets()
for i=1,5 do
WindowSetShowing("TargetRange_Window"..i,false)
WindowSetScale("TargetRange_Window"..i,(WindowGetScale("TargetRange_Window0")*0.8))
end

local eid = TargetInfo:UnitEntityId("selfhostiletarget")

--If there is an enemy target, then find the distance
if (eid ~= nil) then
	for i = 1, MAX_MAP_POINTS do
		local mpd = GetMapPointData ("EA_Window_OverheadMapMapDisplay", i)
		if (not mpd or not mpd.name) then continue end
		--or not MapPointTypeFilter[mpd.pointType]
		local name = EnemyTarget.FixString((mpd.name))
		if name == EnemyTarget.TargetData.Name then
			EnemyTarget.TargetData.distance = math.floor (mpd.distance * DISTANCE_FIX_COEFFICIENT)
			EnemyTarget.TargetData.ID = EnemyTarget.GetIdFromName(name,1)
			EnemyTarget.TargetData.career = EnemyTarget.GetIdFromName(name,2)
			EnemyTarget.TargetData.Info = EnemyTarget.GetIdFromName(name,3)
			return
		end
	end

	WindowSetShowing("TargetRange_Window"..Index,true)

	local color = TargetRange.DefaultColor
	local Distance = TargetListdata[k].distance
	local Distance_Label = towstring(Distance)


	local function toggleText(state)
		if not state then
			return L" ft"
		else
			return L""
		end
	end

	local IsDistant = true
	if TargetListdata[k].Info ~= nil then
			IsDistant = TargetListdata[k].Info.isDistant
	end

	if Distance <= 30 and Distance >= 0 then
		color = TargetRange.CloseColor
	elseif Distance > 30 and Distance <= 50 then
		color = TargetRange.MidColor
	elseif Distance > 50 then
		color = TargetRange.FarColor
	else
		Distance_Label = L" Distant"
		color = TargetRange.Distant
	end

	LabelSetText("TargetRange_Window"..Index.."Label",towstring(TargetListdata[k].Name)..L" "..towstring(CreateHyperLink(L"Distance",Distance_Label, {color.R, color.G, color.B},{}))..toggleText(IsDistant))
	LabelSetText("TargetRange_Window"..Index.."LabelBG",LabelGetText("TargetRange_Window"..Index.."Label"))

	WindowSetTintColor("TargetRange_Window"..Index.."Shield", color.R, color.G, color.B )
	WindowSetTintColor("TargetRange_Window"..Index.."ShieldIcon",255, 255, 255 )
else
	LabelSetText("TargetRange_Window"..Index.."Label",towstring(TargetListdata[k].Name)..towstring(CreateHyperLink(L"Distance",L" Distant", {TargetRange.Distant.R, TargetRange.Distant.G, TargetRange.Distant.B},{})))
	LabelSetText("TargetRange_Window"..Index.."LabelBG",LabelGetText("TargetRange_Window"..Index.."Label"))

	WindowSetTintColor("TargetRange_Window"..Index.."Shield", TargetRange.Distant.R, TargetRange.Distant.G, TargetRange.Distant.B )
	WindowSetTintColor("TargetRange_Window"..Index.."ShieldIcon",155, 155, 155 )
end

return
end

--Returns a corrected formated player name
function EnemyTarget.FixString (str)
	if (str == nil) then return nil end
	local str = str
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end
	return str
end


function TargetRange.LG_Update(state,GuardedName,GuardedID)
TargetRange.UpdateStateMachine()
end

--Function for getting Player Information from name in the party / warband / scenario
--State Returns: 1)- Player Object ID , 2)- Player Career Line , 3)- Player Data table
function EnemyTarget.GetIdFromName(GName,state)
local Gname = GName
local state = tonumber(state)

	--get Warband Data
	if IsWarBandActive() and (not GameData.Player.isInScenario) and (not GameData.Player.isInSiege) then
	local warband = PartyUtils.GetWarbandData()
		for _, party in ipairs( warband ) do
			for _, member in ipairs( party.players ) do
				if tostring(Gname) == tostring(LibEnemyTarget.FixString (member.name)) then
					if state == 1 then
						if member.name ~= L"" then
							return (member.worldObjNum)
						else
							break
						end
					elseif state == 2 then
						if member.name ~= L"" then
							return (member.careerLine)
						else
							break
						end
					elseif state == 3 then
						if member.name ~= L"" then
							if member ~= nil then
							return (member)
							else
							return {}
							end
						else
							break
						end
					end
				end
			end
		end
	end

	--get Party/Scenario data
	if ((not IsWarBandActive() and PartyUtils.IsPartyActive()) or (GameData.Player.isInScenario) or (GameData.Player.isInSiege))then
	local groupData=PartyUtils.GetPartyData()
		for index,memberData in ipairs(groupData) do
			if tostring(Gname) == tostring(LibEnemyTarget.FixString(memberData.name)) then
				if state == 1 then
					if memberData.name ~= L"" then
						return (memberData.worldObjNum)
					else
						break
					end
				elseif state == 2 then
					if memberData.name ~= L"" then
						return (memberData.careerLine)
					else
						break
					end
				elseif state == 3 then
					if memberData.name ~= L"" then
						return (memberData)
					else
						break
					end
				end
			end
		end
	end
return 0
end
