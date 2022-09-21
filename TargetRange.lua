local Version = 1.0

GuardRange = {}

local SEND_BEGIN = 1
local SEND_FINISH = 2
GuardRange.ShieldIcons = {[1]=4515,[5]=2558,[10]=8078,[13]=5172,[17]=13373,[21]=11018}
GuardRange.StateTimer = 0.1
	
GuardRange.DefaultColor = {R=255,G=255,B=255}
GuardRange.CloseColor = {R=50,G=255,B=50}
GuardRange.MidColor = {R=100,G=100,B=255}
GuardRange.FarColor = {R=255,G=50,B=50}
GuardRange.Distant = {R=125,G=125,B=125}


function GuardRange.Initialize()

CreateWindow("GuardRange_Window0", true)
LayoutEditor.RegisterWindow( "GuardRange_Window0", L"Guard List", L"Guard List", true, true, false)
CircleImageSetTexture("GuardRange_Window0ShieldIcon","GuardIcon", 32, 32)
LabelSetText("GuardRange_Window0Label",L"--")
LabelSetText("GuardRange_Window0LabelBG",L"--")
GuardRange.stateMachineName = "GuardRange"
GuardRange.state = {[SEND_BEGIN] = { handler=nil,time=GuardRange.StateTimer,nextState=SEND_FINISH } , [SEND_FINISH] = { handler=GuardRange.UpdateStateMachine,time=GuardRange.StateTimer,nextState=SEND_BEGIN, } , }
GuardRange.StartMachine()
AnimatedImageStartAnimation ("GuardRange_Window0Glow", 0, true, true, 0)	


	for i=1,5 do
		CreateWindowFromTemplate("GuardRange_Window"..i, "GuardRange_Window0", "Root")
		WindowClearAnchors("GuardRange_Window"..i)
		WindowAddAnchor( "GuardRange_Window"..i , "bottom", "GuardRange_Window"..(i-1), "top", 0,7)	
		WindowSetMovable( "GuardRange_Window"..i, false )			
	end

LibGuard.Register_Callback(GuardRange.LG_Update)
end

function GuardRange.StartMachine()
	local stateMachine = TimedStateMachine.New( GuardRange.state,SEND_BEGIN)
	TimedStateMachineManager.AddStateMachine( GuardRange.stateMachineName, stateMachine )
end

function GuardRange.ComparePlayers( index,tablename )
    table.sort(index, function (a,b)
    return (a.distance < b.distance)
	end)

end

function GuardRange.SortPlayers(array)
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


function GuardRange.UpdateStateMachine()

	if  LibGuard.registeredGuards then
		Guard_DisplayOrder = {}
		local IndexCount = 0
			for k, v in pairs (LibGuard.registeredGuards) do
				IndexCount = IndexCount+1
				if LibGuard.registeredGuards[k].Info ~= nil and type(LibGuard.registeredGuards[k].Info) ~= "number" and LibGuard.registeredGuards[k].Info.isDistant == true then
					LibGuard.registeredGuards[k].distance = 90000 + IndexCount
				end					
			end
			GuardListdata = GuardRange.SortPlayers(LibGuard.registeredGuards)			
	end

for i=1,5 do
WindowSetShowing("GuardRange_Window"..i,false)
WindowSetScale("GuardRange_Window"..i,(WindowGetScale("GuardRange_Window0")*0.8))
end
	if  GuardListdata then

		local function Offset(state)
		if state then
			return 35
			else
			return 3
			end
		end			
		
		WindowClearAnchors("GuardRange_Window1")
		WindowAddAnchor( "GuardRange_Window1" , "top", "GuardRange_Window0", "top", 0,Offset(WindowGetShowing("GuardRange_Window0")))	
	
		local Index = 0
		for k, v in ipairs( GuardListdata ) do
			if ((LibGuard.GuarderData.XGuard == true) and (LibGuard.GuarderData.Name == GuardListdata[k].Name)) == false then
				Index = Index + 1
				WindowSetShowing("GuardRange_Window"..Index,true)
				if (GuardListdata[k].Info ~= nil and type(GuardListdata[k].Info) ~= "number" and GuardListdata[k].Info.isDistant ~= nil) and (GuardListdata[k].Info.isDistant == false) then
				local color = GuardRange.DefaultColor
					local Distance = GuardListdata[k].distance
					local Distance_Label = towstring(Distance)				


						local function toggleText(state)
							if not state then
								return L" ft"
							else
								return L""
							end
						end			

						local IsDistant = true
						if GuardListdata[k].Info ~= nil then
						IsDistant = GuardListdata[k].Info.isDistant
						end
					
					if Distance <= 30 and Distance >= 0 then
						color = GuardRange.CloseColor
					elseif Distance > 30 and Distance <= 50 then
						color = GuardRange.MidColor
					elseif Distance > 50 then
						color = GuardRange.FarColor
					else
						Distance_Label = L" Distant"
						color = GuardRange.Distant
					end
				
					LabelSetText("GuardRange_Window"..Index.."Label",towstring(GuardListdata[k].Name)..L" "..towstring(CreateHyperLink(L"Distance",Distance_Label, {color.R, color.G, color.B},{}))..toggleText(IsDistant))
					LabelSetText("GuardRange_Window"..Index.."LabelBG",LabelGetText("GuardRange_Window"..Index.."Label"))				
					
					WindowSetTintColor("GuardRange_Window"..Index.."Shield", color.R, color.G, color.B )
					WindowSetTintColor("GuardRange_Window"..Index.."ShieldIcon",255, 255, 255 )				
					
				else
					LabelSetText("GuardRange_Window"..Index.."Label",towstring(GuardListdata[k].Name)..towstring(CreateHyperLink(L"Distance",L" Distant", {GuardRange.Distant.R, GuardRange.Distant.G, GuardRange.Distant.B},{})))
					LabelSetText("GuardRange_Window"..Index.."LabelBG",LabelGetText("GuardRange_Window"..Index.."Label"))
					
					WindowSetTintColor("GuardRange_Window"..Index.."Shield", GuardRange.Distant.R, GuardRange.Distant.G, GuardRange.Distant.B )
					WindowSetTintColor("GuardRange_Window"..Index.."ShieldIcon",155, 155, 155 )				
				end
				local Guard_Icon = GuardRange.ShieldIcons[GuardListdata[k].career] or 0
				--local Guard_Icon = GetIconData( Icons.GetCareerIconIDFromCareerLine(GuardListdata[k].career ) )
				local texture, x, y, disabledTexture = GetIconData(tonumber(Guard_Icon))
				CircleImageSetTexture("GuardRange_Window"..Index.."ShieldIcon",texture, 32, 32)	
				
				local Fontwidth,FontHeight = LabelGetTextDimensions("GuardRange_Window"..Index.."Label")
				WindowSetDimensions("GuardRange_Window"..Index, Fontwidth, FontHeight)
				
			end
		end

	end	
	
	if LibGuard.GuarderData.IsGuarding then
	
				local color = GuardRange.DefaultColor
				local Distance = LibGuard.GuarderData.distance
				
			if (LibGuard.GuarderData.Info ~= nil and type(LibGuard.GuarderData.Info) ~= "number" and LibGuard.GuarderData.Info.isDistant ~= nil) and (LibGuard.GuarderData.Info.isDistant == false) then	
				if Distance <= 30 and Distance >= 0 then
					color = GuardRange.CloseColor
				elseif Distance > 30 and Distance <= 50 then
					color = GuardRange.MidColor
				elseif Distance > 50 then
					color = GuardRange.FarColor
				else
					color = GuardRange.DefaultColor
				end
			else
				Distance = L"Distant "
				color = GuardRange.Distant
			end
			
						local function toggleText(state)
							if not state then
								return L" ft"
							else
								return L""
							end
						end			
			
				local IsDistant = true
				if LibGuard.GuarderData.Info ~= nil and LibGuard.GuarderData.Info ~= 0 then
				IsDistant = LibGuard.GuarderData.Info.isDistant
				end
			local Distance_Label = towstring(Distance)
				WindowSetTintColor("GuardRange_Window0Shield", color.R, color.G, color.B )
				WindowSetTintColor("GuardRange_Window0ShieldIcon", color.R, color.G, color.B )				
		
				WindowSetShowing("GuardRange_Window0",true)
				WindowSetShowing("GuardRange_Window0Glow",LibGuard.GuarderData.XGuard or false)
				WindowSetTintColor("GuardRange_Window0Glow", color.R, color.G, color.B )
				
				LabelSetText("GuardRange_Window0Label",towstring(LibGuard.GuarderData.Name)..L" "..towstring(CreateHyperLink(L"Distance",Distance_Label, {color.R, color.G, color.B},{}))..toggleText(IsDistant))
				LabelSetText("GuardRange_Window0LabelBG",LabelGetText("GuardRange_Window0Label"))			
				
	else
	WindowSetShowing("GuardRange_Window0",false)
	WindowSetShowing("GuardRange_Window0Glow",false)
	LabelSetText("GuardRange_Window0Label",L"--")
	LabelSetText("GuardRange_Window0LabelBG",L"--")
	end	
return		
end


function GuardRange.LG_Update(state,GuardedName,GuardedID)
GuardRange.UpdateStateMachine()
end
