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


function TargetRange.UpdateTargets()
for i=1,5 do
WindowSetShowing("TargetRange_Window"..i,false)
WindowSetScale("TargetRange_Window"..i,(WindowGetScale("TargetRange_Window0")*0.8))
end

local eid = TargetInfo:UnitEntityId("selfhostiletarget")
print(eid)
--If there is an enemy target, then find the distance
if (eid ~= nil) then
	for i = 1, MAX_MAP_POINTS do
		local mpd = GetMapPointData ("EA_Window_OverheadMapMapDisplay", i)
		print("mpd")
		print(mpd)
		if (not mpd or not mpd.name) then continue end
		--or not MapPointTypeFilter[mpd.pointType]

		EnemyTarget.TargetData.distance = math.floor (mpd.distance * DISTANCE_FIX_COEFFICIENT)
		return

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



function TargetRange.LG_Update(state,GuardedName,GuardedID)
TargetRange.UpdateStateMachine()
end

local function print(text)
    ChatWindow.Print(towstring(tostring(text)), ChatSettings.Channels[SystemData.ChatLogFilters.SAY].id);
end

local function mysort(alpha, bravo)
    if type(alpha) ~= type(bravo) then
        return type(alpha) < type(bravo)
    end
    if alpha == bravo then
        return false
    end
    if type(alpha) == "string" or type(alpha) == "wstring" then
        return alpha:lower() < bravo:lower()
    end
    if type(alpha) == "number" then
        return alpha < bravo
    end
    return false
end

local recursions = {}
local function better_toString(data, depth)
    if type(data) == "string" then
        return ("%q"):format(data)
    elseif type(data) == "wstring" then
        return ("L%q"):format(WStringToString(data))
    elseif type(data) ~= "table" then
        return ("%s"):format(tostring(data))
    else
        if recursions[data] then
            return "{<recursive table>}"
        end
        recursions[data] = true
        if next(data) == nil then
            return "{}"
        elseif next(data, next(data)) == nil then
            return "{ [" .. better_toString(next(data), depth) .. "] = " .. better_toString(select(2, next(data)), depth) .. " }"
        else
            local t = {}
            t[#t+1] = "{\n"
            local keys = {}
            for k in pairs(data) do
                keys[#keys+1] = k
            end
            table.sort(keys, mysort)
            for _, k in ipairs(keys) do
                local v = data[k]
                for i = 1, depth do
                    t[#t+1] = "    "
                end
                t[#t+1] = "["
                t[#t+1] = better_toString(k, depth+1)
                t[#t+1] = "] = "
                t[#t+1] = better_toString(v, depth+1)
                t[#t+1] = ",\n"
            end

            for i = 1, depth do
                t[#t+1] = "    "
            end
            t[#t+1] = "}"
            return table.concat(t)
        end
    end
end

function pprint(...)
    local n = select('#', ...)
    local t = {n, ': '}
    for i = 1, n do
        if i > 1 then
            t[#t+1] = ", "
        end
        t[#t+1] = better_toString((select(i, ...)), 0)
    end
    for k in pairs(recursions) do
        recursions[k] = nil
    end
    print(table.concat(t))
end
