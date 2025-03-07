-- by Hashino https://github.com/Hashino/dotfiles
--------------------------------------------------------------------------------
local awful = require("awful")
--------------------------------------------------------------------------------
local run_once = function(class)
	awful.spawn.once(class, {}, function(c)
		return c.class == class
	end)
end
--------------------------------------------------------------------------------
-- makes spotify and discord spawn in specific tags
client.connect_signal("request::tag", function(c)
	if c.class == "Spotify" then
		c:move_to_tag(awful.screen.focused().tags[#awful.screen.focused().tags - 1])
	end
	if c.class == "discord" then
		c:move_to_tag(awful.screen.focused().tags[#awful.screen.focused().tags])
	end
end)
--------------------------------------------------------------------------------
awful.spawn.with_shell(Global.ConfigFolder .. "/autorun.sh")
--------------------------------------------------------------------------------
-- Auto update
-- require("hash.autoupdate")
--------------------------------------------------------------------------------
awesome.connect_signal("startup", function()
	-- run_once("vivaldi")
	run_once("spotify")
	run_once("discord")
end)
--------------------------------------------------------------------------------
