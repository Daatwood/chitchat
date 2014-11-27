-- To get the Boss kills for a player:
-- Cycle through the party or raid doing:
  -- self:RegisterEvent("INSPECT_ACHIEVEMENT_READY");
	-- SetAchievementComparisonUnit(self.unit);
    -- self.unit = "RaidN" or "PartyN" or "Target" etc..

-- Upon event "INSPECT_ACHIEVEMENT_READY" the data is ready
  -- self:UnregisterEvent("INSPECT_ACHIEVEMENT_READY");
  -- For each Boss we want to record perform a GetComparisonStatistic(id); 
    -- Get the ID from below.
    

-- For caching maybe record as:
-- [ACH_ID] {[Tag] = NUMBER_OF_KILLS} -- ON ENCOUNTER TABLE
-- [TAG_KEY] = { [ACH_ID] } -- ON PERSONAL NOTE TABLE


-- WARLORDS OF DRAENOR CategoryId = 14807
-- * MAY WANT TO INCLUDE OTHER EXPANSIONS AS OPTIONS THAT CAN BE CHECKED-ON *
    
--FOLLOWING WILL PRINT OUT THE WARLORD DUNGEONS AND RAID KILLS IDS
--5MANS ONLY TRACK LAST BOSS KILL. RAIDS TRACK EACH BOSS.
--[[
function GetStatisticId(CategoryTitle, StatisticTitle)
   local str = ""
   for _, CategoryId in pairs(GetStatisticsCategoryList()) do
      local Title, ParentCategoryId, Something
      Title, ParentCategoryId, Something = GetCategoryInfo(CategoryId)
      
      if Title == CategoryTitle then
         local i
         local statisticCount = GetCategoryNumAchievements(CategoryId) -- THIS WILL ALWAYS 14807, No need to find it if we are just going after warlords.
         for i = 1, statisticCount do
            local IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText
            IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText = GetAchievementInfo(CategoryId, i)
            if Name == StatisticTitle then
               return IDNumber
            else
               print(Name.." - "..IDNumber)
            end
         end
         return -1
      end
   end
end
GetStatisticId("Warlords of Draenor","")
--]]


---------------------------------------------------------------
-- BOSS_ENCOUNTER # is a collection of bosses with collection of tags and timestamps
-- Usage:
-- CreateMessageEntry -- Returns message_entry id

-- Returns the ordered array of the messages entries

-- function Chitchat:GetEncounters()
  -- return self.encounters
-- end
-- function Chitchat:GetEncounter(index)
  -- return self.encounters[index]
-- end
-- function Chitchat:AddEncounter(bossname, tag, )
  -- local i = self:GetMessageIndex()
  -- while self.messages[i] ~= nil do
    -- i = i + 1
  -- end
  -- message[ID_KEY] = i
  -- self.messages[tostring(i)] = message
  -- self.messages[INDEX_KEY] = i + 1
  -- return message
-- end
-- function Chitchat:GetMessageIndex()
  -- return self.messages[INDEX_KEY]
-- end

-- function Chitchat:CreateBossEncounter(bossname)
  -- local message_entry = {}

  -- if type(player)~="string" then
    -- error(("CreateMessageEntry: 'player' - string expected got '%s'."):format(type(player)),2)
  -- end
  -- if type(message)~="string" then
    -- error(("CreateMessageEntry: 'message' - string expected got '%s'."):format(type(message)),2)
  -- end
  -- if type(incoming)~= "number" then
    -- error(("CreateMessageEntry: 'incoming' - number expected got '%s'."):format(type(incoming)),2)
  -- end
  
  -- if incoming == 0 then
    -- local name = UnitName("player")
    -- local realm = GetRealmName()
    -- player = name.."-"..realm
  -- end

  -- message_entry[SENDER_KEY] = player
  -- message_entry[MESSAGE_KEY] = message
  -- message_entry[TIMESTAMP_KEY] = timestamp
  -- message_entry[INCOMING_KEY] = incoming
  -- self:AddMessage(message_entry)
  -- self:SendMessage("CHITCHAT_MESSAGE_CREATED", message_entry[ID_KEY])
  -- return message_entry
-- end