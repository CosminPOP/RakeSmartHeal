local RakeSmartHeal = CreateFrame("Frame")

RakeSmartHeal:RegisterEvent("CHAT_MSG_WHISPER")
RakeSmartHeal:RegisterEvent("UNIT_AURA")

local groupsFromTell = { false, false, false, false, false, false, false, false }

function eventHandler()
    if (event) then
        if (event == 'CHAT_MSG_WHISPER') then
            ssRes(arg1, arg2)
        end
    end
end

RakeSmartHeal:SetScript("OnEvent", eventHandler)

function ssRes(arg1, arg2)
    if arg1 == "sstime" then
        SendChatMessage("--- Soulstone time left " .. ssResponder() .. " --- ", "WHISPER", "Common", arg2);
    end
end

function SmartFort()

    if (not UnitExists("target")) then
        TargetUnit("player")
    end

    local Sp = { 1, 2, 14, 26, 38, 50 }
    if (UnitLevel("target") ~= nil and UnitIsFriend("player", "target")) then
        for i = 6, 1, -1 do
            if (UnitLevel("target") >= Sp[i]) then
                CastSpellByName("Power Word: Fortitude(Rank " .. i .. ")")
                return
            end
        end
    end
end

function SmartSpirit()

    if (not UnitExists("target")) then
        TargetUnit("player");
    end

    local Sp = { 20, 28, 38, 48 }

    if (UnitLevel("target") ~= nil and UnitIsFriend("player", "target")) then
        for i = 4, 1, -1 do
            if (UnitLevel("target") >= Sp[i]) then
                CastSpellByName("Divine Spirit(Rank " .. i .. ")")
                return
            end
        end
    end
end

function R_FindSpell(spellName, caseinsensitive)

    -- caseinsensitive not used, so we lower spellName
    spellName = string.lower(spellName);

    local maxSpells = 500;

    -- init id, 1st spell in book
    local id = 0;

    -- init spellname and rank
    local searchName;
    local subName;

    -- search for spells, from 1 to a max of 500
    while (id <= maxSpells) do
        id = id + 1;

        -- get spell i from book
        searchName, subName = GetSpellName(id, BOOKTYPE_SPELL);

        -- if the spellName exists
        if (searchName) then

            -- check spell i from the book is the spell we're looking for
            if (string.lower(searchName) == string.lower(spellName)) then

                -- if it is, get next(i+1) spell from the book, to see if the spell has higher ranks

                local nextName, nextSubName = GetSpellName(id + 1, BOOKTYPE_SPELL); -- next rank

                -- if next spell spell i+1 has a different name then it means we found original's spell max rank
                -- otherwise we'll continue the loop to get to the next rank
                if (string.lower(nextName) ~= string.lower(searchName)) then

                    -- then we can break the while loop
                    break ;
                end
            end
        end
    end

    -- if id got the maxSpells then it means it didnt find a spell with name spellName,
    -- which probably means there was a typo somewhere, we return `nil`
    if (id == maxSpells) then
        id = nil;
    end

    -- otherwise we return the last id
    return id;
end

function CastFW()

    local start, duration, enabled = GetSpellCooldown(R_FindSpell("Fear Ward"), BOOKTYPE_SPELL);
    local FearWard = "Interface\\Icons\\Spell_Holy_Excorcism";
    local hasFearWard = false

    if not UnitExists("target") then
        TargetUnit("player");
    end ;

    for j = 1, 40 do
        local B = UnitBuff("target", j);
        if B then
            if B == FearWard then
                hasFearWard = true
            end
        end
    end

    if (duration > 0) then

        if (hasFearWard) then
            SendChatMessage("--- You have Fear Ward --- ", "WHISPER", "Common", GetUnitName("target"));
        else
            SendChatMessage("--- Fear Ward is on Cooldown " .. math.floor(start + duration - GetTime()) .. "s --- ", "WHISPER", "Common", GetUnitName("target"));
        end

    else

        if (hasFearWard) then
            SendChatMessage("--- You have Fear Ward --- ", "WHISPER", "Common", GetUnitName("target"));
        else
            CastSpellByName("Fear Ward");
            SendChatMessage("--- Fresh Fear Ward cast on you ! --- ", "WHISPER", "Common", GetUnitName("target"));
        end
    end
end

function ssResponder()
    local timeInMinutes = 0
    for j = 0, 31 do
        local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(j, "HELPFUL"))
        local texture = GetPlayerBuffTexture(GetPlayerBuff(j, "HELPFUL"))

        if texture then

            if (string.find(string.lower(texture), "spell_shadow_soulgem", 1)) then
                timeInMinutes = math.floor(timeleft / 60) -- mins
            end
        end
    end

    if (timeInMinutes == 0) then
        return " -i don't have ss- "
    else
        return timeInMinutes .. ' minutes'
    end
end

function RenewOrSWP()
    if (not UnitExists("target")) then
        TargetUnit('player')
    end
    if UnitIsFriend("player", "target") then
        --CastSpellByName("Renew")
        local Sp = { 1, 10, 15, 20, 25, 30, 35, 40, 45, 50 }
        if UnitLevel("target") ~= nil then
            for i = 10, 1, -1 do
                if (UnitLevel("target") >= Sp[i]) then
                    CastSpellByName("Renew(Rank " .. i .. ")")
                    return
                end
            end
        end
    else

        local baseStack = 0

        for i = 1, 40 do
            if (string.find(tostring(UnitDebuff("target", i)), "Spell_Shadow_BlackPlague")) then
                local _, stack = UnitDebuff("target", i)
                baseStack = stack
            end
        end

        for i = 1, 40 do
            if (string.find(tostring(UnitDebuff("target", i)), "Spell_Shadow_ShadowWordPain")) then
                if baseStack < 4 then
                    CastSpellByName("Shadow Word: Pain(Rank 1)")
                    return true
                end
            end
        end
        CastSpellByName("Shadow Word: Pain")

    end
end

function pws()

    if (not UnitExists("target")) then
        TargetUnit('player')
    end
    if UnitIsFriend("player", "target") then
        --CastSpellByName("Renew")
        local Sp = { 1, 10, 15, 20, 25, 30, 35, 40, 45, 50 }
        if UnitLevel("target") ~= nil then
            for i = 10, 1, -1 do
                if (UnitLevel("target") >= Sp[i]) then
                    CastSpellByName("Power Word: Shield(Rank " .. i .. ")")
                    return
                end
            end
        end
    else
        CastSpellByName("Power Word: Shield")
    end

end

function RaidBuff(p1, p2, p3, p4, p5, p6, p7, p8)

    local g = { false, false, false, false, false, false, false, false }

    local withShadow = false
    local withSpirit = true

    local groupsString = ''

    if p1 then
        for i = 1, 8 do
            if (p1 == i) then
                g[i] = true
                groupsString = groupsString .. i .. ' '
            end
        end
    end
    if p2 then
        for i = 1, 8 do
            if (p2 == i) then
                g[i] = true
                groupsString = groupsString .. i .. ' '
            end
        end
    end
    if p3 then
        for i = 1, 8 do
            if (p3 == i) then
                g[i] = true
                groupsString = groupsString .. i .. ' '
            end
        end
    end
    if p4 then
        for i = 1, 8 do
            if (p4 == i) then
                g[i] = true
                groupsString = groupsString .. i .. ' '
            end
        end
    end
    if p5 then
        for i = 1, 8 do
            if (p5 == i) then
                g[i] = true
                groupsString = groupsString .. i .. ' '
            end
        end
    end
    if p6 then
        for i = 1, 8 do
            if (p6 == i) then
                g[i] = true
                groupsString = groupsString .. i .. ' '
            end
        end
    end
    if p7 then
        for i = 1, 8 do
            if (p7 == i) then
                g[i] = true
                groupsString = groupsString .. i .. ' '
            end
        end
    end
    if p8 then
        for i = 1, 8 do
            if (p8 == i) then
                g[i] = true
                groupsString = groupsString .. i .. ' '
            end
        end
    end

    local buffOricare = true

    for i = 1, 8 do
        if (g[i]) then
            buffOricare = false -- nu oricare, doar unele grupuri.
        else
        end
    end

    local GFort = "Interface\\Icons\\Spell_Holy_PrayerOfFortitude";
    local Fort = "Interface\\Icons\\Spell_Holy_WordFortitude";

    local GSpirit = "Interface\\Icons\\Spell_Holy_PrayerofSpirit";
    local Spirit = "Interface\\Icons\\Spell_Holy_DivineSpirit";

    local GShadow = "Interface\\Icons\\Spell_Holy_PrayerofShadowProtection";
    local Shadow = "Interface\\Icons\\Spell_Shadow_AntiShadow";

    local InnerFire = "Interface\\Icons\\Spell_Holy_InnerFire";
    local FearWard = "Interface\\Icons\\Spell_Holy_Excorcism";

    local inRaid = GetNumRaidMembers() > 0;
    local inGroup = not inRaid and GetNumPartyMembers() > 0;
    local isSolo = not inRaid and not inGroup;

    local hasFort = false;
    local hasSpirit = false;
    local hasShadow = false;
    local hasFearWard = false;
    local hasInnerFire = false;

    local target = "none";

    if isSolo then

        if not UnitExists("target") then
            TargetUnit("player");
        end

        hasFort = false;
        hasSpirit = false;
        hasShadow = false;
        hasInnerFire = false;
        hasFearWard = false;

        for j = 1, 40 do
            local B = UnitBuff("target", j);
            if B then
                if B == GFort or B == Fort then
                    hasFort = true
                end
                if B == GSpirit or B == Spirit then
                    hasSpirit = true
                end
                if B == GShadow or B == Shadow then
                    hasShadow = true
                end
                if B == InnerFire then
                    hasInnerFire = true
                end
                if B == FearWard then
                    hasFearWard = true
                end
            end
        end

        if not hasFort then
            CastSpellByName("Power Word: Fortitude")
            return nil
        end
        if not hasSpirit then
            CastSpellByName("Divine Spirit")
            return nil
        end
        if not hasShadow then
            CastSpellByName("Shadow Protection")
            return nil
        end

        if not hasInnerFire then
            CastSpellByName("Inner Fire")
            return nil
        end

        if not hasFearWard then
            CastSpellByName("Fear Ward")
            return nil
        end

        if hasFort and hasSpirit and hasShadow then
            DEFAULT_CHAT_FRAME:AddMessage("[SmartBuff]: buffed ", 0, 1, 0)
        end
    end ;

    if inGroup then
        local members = GetNumPartyMembers()

        for i = 1, members do

            if not UnitIsDead("party" .. i) and UnitIsConnected("party" .. i) and
                    UnitIsVisible("party" .. i) and CheckInteractDistance("party" .. i, 4) and
                    UnitLevel("party" .. i) == 60 and UnitExists("party" .. i) then

                hasFort = false;
                hasSpirit = false;
                hasShadow = false;

                for j = 1, 40 do
                    local B = UnitBuff("party" .. i, j);

                    if B then
                        if B == GFort then
                            hasFort = true
                        end
                        if B == GSpirit then
                            hasSpirit = true
                        end
                        if B == GShadow or not withShadow then
                            hasShadow = true
                        end
                    end
                end

                if not hasFort or not hasSpirit or not hasShadow then
                    target = "party" .. i
                    TargetUnit(target)
                end

                if not hasFort then
                    CastSpellByName("Prayer of Fortitude(Rank 2)")
                    break ;
                end
                if not hasSpirit then
                    CastSpellByName("Prayer of Spirit")
                    break ;
                end
                if not hasShadow then
                    CastSpellByName("Prayer of Shadow Protection")
                    break ;
                end
            end
        end

        if target == "none" then
            SendChatMessage("Everyone is buffed ", "party");
        end
    end

    if inRaid then
        local members = GetNumRaidMembers()

        if buffOricare then

            for i = 1, members do

                if not UnitIsDead("raid" .. i) and UnitIsConnected("raid" .. i) and
                        UnitIsVisible("raid" .. i) and CheckInteractDistance("raid" .. i, 4) and
                        UnitLevel("raid" .. i) == 60 and UnitExists("raid" .. i) then

                    hasFort = false;
                    hasSpirit = false;
                    hasShadow = false;

                    local _, unitClass = UnitClass('raid' .. i) --standard
                    unitClass = string.lower(unitClass)
                    hasSpirit = unitClass == 'warrior' or unitClass == 'rogue' or unitClass == 'shaman' or
                            unitClass == 'hunter' or unitClass == 'warlock' or unitClass == 'paladin'

                    for j = 1, 40 do
                        local B = UnitBuff("raid" .. i, j);

                        if B then
                            if B == GFort then
                                hasFort = true
                            end
                            if B == GSpirit or not withSpirit then
                                hasSpirit = true
                            end
                            if B == GShadow or not withShadow then
                                hasShadow = true
                            end
                        end
                    end

                    if not hasFort or not hasSpirit or not hasShadow then
                        target = "raid" .. i
                        TargetUnit(target)
                    end

                    if not hasFort then
                        CastSpellByName("Prayer of Fortitude(Rank 2)")
                        break
                    end
                    if not hasSpirit then
                        CastSpellByName("Prayer of Spirit")
                        break
                    end
                    if not hasShadow then
                        CastSpellByName("Prayer of Shadow Protection")
                        break
                    end
                end
            end
        else

            for i = 1, members do

                local name, rank, subgroup = GetRaidRosterInfo(i)

                if (g[1] and subgroup == 1) or
                        (g[2] and subgroup == 2) or
                        (g[3] and subgroup == 3) or
                        (g[4] and subgroup == 4) or
                        (g[5] and subgroup == 5) or
                        (g[6] and subgroup == 6) or
                        (g[7] and subgroup == 7) or
                        (g[8] and subgroup == 8) then

                    if not UnitIsDead("raid" .. i) and UnitIsConnected("raid" .. i) and
                            UnitIsVisible("raid" .. i) and CheckInteractDistance("raid" .. i, 4) and
                            UnitLevel("raid" .. i) == 60 and UnitExists("raid" .. i) then

                        hasFort = false;
                        hasSpirit = false;
                        hasShadow = false;

                        for j = 1, 40 do
                            local B = UnitBuff("raid" .. i, j);

                            if B then
                                if B == GFort then
                                    hasFort = true
                                end
                                if B == GSpirit or not withSpirit then
                                    hasSpirit = true
                                end
                                if B == GShadow or not withShadow then
                                    hasShadow = true
                                end
                            end
                        end

                        if not hasFort or not hasSpirit or not hasShadow then
                            target = "raid" .. i
                            TargetUnit(target)
                        end

                        if not hasFort then
                            CastSpellByName("Prayer of Fortitude(Rank 2)")
                            break ;
                        end
                        if not hasSpirit then
                            CastSpellByName("Prayer of Spirit")
                            break ;
                        end
                        if not hasShadow then
                            CastSpellByName("Prayer of Shadow Protection")
                            break ;
                        end
                    end
                end
            end
        end

        if target == "none" then
            local buff_string = 'FORT';
            if withSpirit then
                buff_string = buff_string .. '/SPIRIT'
            end ;
            if withShadow then
                buff_string = buff_string .. '/SHADOW'
            end ;

            local mana = UnitMana("player");
            local maxmana = UnitManaMax("player");
            local mana_percent = math.floor(mana * 100 / maxmana)

            local groups = ''
            if groupsString == '' then
                --
            else
                groups = " in group(s) " .. groupsString
            end

            SendChatMessage("Everyone" .. groups .. " is buffed with [" .. buff_string .. "] and my mana is at " .. mana_percent .. "%", "raid");
        end
    end
end

function castRez()

    CastSpellByName("Resurrection");

    local classOrder = { "SHAMAN", "PALADIN", "PRIEST", "DRUID", "MAGE", "HUNTER", "WARLOCK", "WARRIOR", "ROGUE" };

    for c = 1, table.getn(classOrder) do
        for r = 1, GetNumRaidMembers() do
            local raidId = "raid" .. r;

            local _, raidClass = UnitClass(raidId);

            if UnitIsDead(raidId)
                    and not UnitIsGhost(raidId)
                    and raidClass == classOrder[c] then
                if SpellIsTargeting() and SpellCanTargetUnit(raidId) then
                    SpellTargetUnit(raidId);
                    SendChatMessage("rezzing " .. UnitName(raidId), "say");
                end
            end
        end
    end
end

DEFAULT_CHAT_FRAME:AddMessage(" Smart Heal Loaded - - ", 1, 0, 0);

function rprint(a)
    DEFAULT_CHAT_FRAME:AddMessage(a, 0, 1, 0)
end

function string:split(delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end
