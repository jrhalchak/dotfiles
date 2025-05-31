hs.hotkey.bind({"cmd", "shift", "alt"}, "c", function()
  -- Run the AppleScript file to clear notifications
  local scriptPath = os.getenv("HOME") .. "/dotfiles/clearnot.applescript"
  hs.execute(string.format('osascript "%s"', scriptPath))
end)

-- Notification tester
hs.hotkey.bind({"cmd", "shift", "alt"}, "n", function()
  local count = math.random(3, 9)
  for i = 1, count do
    hs.notify.new({
      title = "Hammerspoon Test",
      informativeText = "Test notification " .. i
    }):send()
  end
  hs.alert.show("Sent " .. count .. " test notifications")
end)

-- TODO: this is hacky
-- hs.hotkey.bind({"cmd"}, "space", function()
--     hs.application.launchOrFocus("Sol")
-- end)

-- I'd like hammerspoon to send sigals to be received by MacOS' mouse keys setting. Give me a lua function that will map these keys to the numpad (not the actual numbers listed):
-- - some modifier + `h` = `4`
-- - some modifier + `j` = `2`
-- - some modifier + `k` = `8`
-- - some modifier + `l` = `6`
-- - some modifier + `hj` = `1`
-- - some modifier + `hk` = `7`
-- - some modifier + `lj` = `3`
-- - some modifier + `lk` = `9`
-- - some modifier + `spacebar` = `5`
-- - some modifier + `shift` + `spacebar` = `0`
-- - some modifier + `ctrl` + `spacebar` = `ctrl+5`
--
-- The modifier is preferably the `fn` key.

-- Mouse keys test
-- local modifier = "" -- Change to your preferred modifier
--
-- local keymap = {
--   h = "pad4",
--   j = "pad2",
--   k = "pad8",
--   l = "pad6",
--   space = "pad5"
-- }
--
-- local combos = {
--   ["h+j"] = "pad1",
--   ["h+k"] = "pad7",
--   ["l+j"] = "pad3",
--   ["l+k"] = "pad9"
-- }
--
-- local pressed = {}
-- local timers = {}
-- local combo_timeout = 0.08 -- seconds to detect combos
-- local repeat_interval = 0.02 -- fast repeat
--
-- local function sendNumpadKey(pad, mods)
--   hs.eventtap.keyStroke(mods or {}, pad, 0)
-- end
--
-- local function handleCombo()
--   for combo, pad in pairs(combos) do
--     local k1, k2 = combo:match("([^+]+)%+([^+]+)")
--     if pressed[k1] and pressed[k2] then
--       sendNumpadKey(pad)
--       return true
--     end
--   end
--   return false
-- end
--
-- local function startRepeater(key, pad)
--   timers[key] = hs.timer.doWhile(
--     function() return pressed[key] end,
--     function() sendNumpadKey(pad) end,
--     repeat_interval
--   )
-- end
--
-- local function stopRepeater(key)
--   if timers[key] then
--     timers[key]:stop()
--     timers[key] = nil
--   end
-- end
--
-- local eventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
--   local code = event:getKeyCode()
--   local key = hs.keycodes.map[code]
--   local flags = event:getFlags()
--   local isModifier = flags[modifier]
--
--   -- Only act if modifier is held and key is in our map
--   if isModifier and keymap[key] then
--     if event:getType() == hs.eventtap.event.types.keyDown then
--       if not pressed[key] then
--         pressed[key] = true
--         hs.timer.doAfter(combo_timeout, function()
--           if not handleCombo() then
--             startRepeater(key, keymap[key])
--           else
--             pressed[key] = nil
--           end
--         end)
--       end
--       return true -- block original key
--     elseif event:getType() == hs.eventtap.event.types.keyUp then
--       pressed[key] = nil
--       stopRepeater(key)
--       return true
--     end
--   end
--
--   -- Handle combos for spacebar with shift/ctrl
--   if isModifier and key == "space" then
--     if event:getType() == hs.eventtap.event.types.keyDown then
--       if flags.shift then
--         sendNumpadKey("pad0")
--       elseif flags.ctrl then
--         sendNumpadKey("pad5", {"ctrl"})
--       end
--       -- Don't block spacebar if not shift/ctrl
--       if flags.shift or flags.ctrl then return true end
--     end
--   end
--
--   return false -- pass through all other keys
-- end)
--
-- eventtap:start()
