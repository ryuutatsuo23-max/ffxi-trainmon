-- Standalone offline regression checks; never read or write player settings.
assert(addon == nil, 'Run this test outside Ashita.')
local path = debug.getinfo(1, 'S').source:sub(2)
local root = path:gsub('[\\/]test[\\/]test_progress%.lua$', '')
package.path = root .. '/?.lua;' .. package.path
T = function(t) return t end
LogManager = { Log = function() end }
package.loaded.chat = {}
package.loaded.settings = {
    register = function() end,
    load = function() return {} end,
    save = function() end,
}
package.loaded['gdifonts.encoding'] = {}
AshitaCore = { GetMemoryManager = function()
    return { GetParty = function()
        return { GetMemberName = function(_, i) return i == 0 and 'Player' or '' end }
    end }
end }

local monitor = require('monitor')
local modes = require('chat_modes')
local function fixture(total, lang)
    local mon = monitor:new(lang or 'en')
    mon._target_monsters = {
        { name = 'Witchtetty Grub', count = 2, total = total or 4 },
        { name = 'Goblin Headsman', count = 1, total = 2 },
    }
    return mon
end
local function progress(mon, count, total)
    mon:process_input(modes.battle,
        ('You defeated a designated target. (Progress: %d/%d)'):format(count, total))
end

local mon = fixture()
mon:process_input(modes.others, 'The Goblin Headsman falls to the ground.')
assert(mon._target_monsters[2].count == 1, 'Death alone must not grant credit')
progress(mon, 2, 2)
assert(mon._target_monsters[2].count == 2, 'Reported Headsman death must receive server credit')
assert(mon._target_monsters[1].count == 2, 'Grub count must be unchanged')
assert(mon._data.target_monsters[2].count == 2, 'Updated count must be saved')
progress(mon, 2, 2)
assert(mon._target_monsters[2].count == 2, 'Duplicate progress must not increment')
mon:process_input(modes.player, 'Player defeats the Goblin Headsman.')
assert(mon._target_monsters[2].count == 2, 'Late named death must not add another kill')

mon = fixture()
mon:process_input(modes.player, 'Player defeats the Goblin Headsman.')
assert(mon._target_monsters[2].count == 1, 'Named death must wait for server credit')
progress(mon, 2, 2)
assert(mon._target_monsters[2].count == 2, 'Normal unique-total kill must still count')
assert(#mon._monster_kills == 0, 'Matched named evidence must be consumed')

mon = fixture()
progress(mon, 4, 4)
assert(mon._target_monsters[1].count == 4, 'Server count must recover missed progress')
progress(mon, 3, 4)
assert(mon._target_monsters[1].count == 4, 'Older progress must not reduce the count')
progress(mon, 5, 4)
assert(mon._target_monsters[1].count == 4, 'Count must not exceed the objective total')

-- Equal totals stay ambiguous even when only one row has the expected prior count.
for _, death_first in ipairs({ true, false }) do
    mon = fixture(2)
    if death_first then
        mon:process_input(modes.player, 'Player defeats the Goblin Headsman.')
    end
    progress(mon, 2, 2)
    if not death_first then
        assert(mon._target_monsters[2].count == 1, 'Ambiguous progress must wait for a name')
        mon:process_input(modes.player, 'Player defeats the Goblin Headsman.')
    end
    assert(mon._target_monsters[2].count == 2, 'Named matching must work in either order')
end

mon = fixture(2)
mon:process_input(modes.others, 'Stranger defeats the Goblin Headsman.')
progress(mon, 2, 2)
assert(mon._target_monsters[2].count == 1, 'Non-party kills must not resolve ambiguous credit')

mon = fixture()
progress(mon, 2, 2)
progress(mon, 4, 4)
mon:process_input(modes.battle, 'You have successfully completed the training regime.')
assert(#mon._target_monsters == 0, 'Completion must clear the active regime')
mon:process_input(modes.battle, 'Your current training regime will begin anew!')
assert(#mon._target_monsters == 2, 'Repeat must restore both objectives')
assert(mon._target_monsters[1].count == 0 and mon._target_monsters[2].count == 0,
    'Repeat must reset both counts')

mon = fixture(nil, 'ja')
mon:process_input(require('test.testdata_ja').target_monster_killed(2, 2))
assert(mon._target_monsters[2].count == 2, 'Japanese server progress must also work')
print('Server progress regression checks passed.')
