--
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

local instant = {}

--Set up the frames.
instant.lastFrame = {}
instant.currentFrame = {}
for a=1, 256*16*16 do
	instant.currentFrame[a] = 0
end

instant.currentKeys = {}

instant.currentChanges = {}
instant.lastChanges = {}

return instant