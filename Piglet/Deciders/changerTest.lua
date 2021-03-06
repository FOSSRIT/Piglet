--
--Copyright Daniel Shumway, 2014
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

--make our decider object
local decider = {}
decider.goal = ""
decider.effects = {}
decider.keys = {}



function decider.decide(self)
	self.lookedAt = {} self.keys = {} --Reset values.
	--print(self.goal)
	decider.chooseInput(self, self.interpretGoal(self, self.goal), 1 ) --Recursive tree search for best keys to press.
	for k, v in pairs(self.keyValues) do
		if(v > 0) then
			self.keys[k] = true
		end
	end
	--Just set the keys here for now.
	--print(self.keyValues)
	--print(self.lookedAt)
	print(self.keys)
	--print(self.keyValues)
	joypad.set(1, self.keys);
end

decider.keyValues = {}
decider.lookedAt = {}
function decider.chooseInput(self, goal, goalRating)
	--print(goal)
	for k, v in pairs(self.effects[tonumber(goal[2])]) do
		local loop=false
		--Commented out because for right now, we're going to discourage changes that would negatively effect the byte.
		--if(k > 0) then --If it's likely to make the byte change.
			--print(k)
			local translation = self.interpretGoal(self, k)

			--if(translation[1] == "key") then
			--	--If we don't have any information for the current goal (ie, just started)
				-- --Or the goal is positively rated.
				-- if(goal == nil or goalRating > 0) then
				-- 	self.keys[translation[2]] == true
				-- end

			--If it's not "default."
			if (translation[1] == "mem" or translation[1] == "key") then
				--If we've never encountered it.
				--print(translation)
				if(self.lookedAt[translation[2]] == nil) then
					--print('adding lookedAt '..translation[2])
					self.lookedAt[translation[2]] = v --We have now.
					--print(k.." "..v)
					--self.chooseInput(self, self.interpretGoal(self, k), v)
				else
					loop=true
					--Adjust its rating.
					if(goalRating > 0) then --If we're currently looking at something positive.
						self.lookedAt[translation[2]] = self.lookedAt[translation[2]] + v
					elseif(goalRating <= 0) then --If we're currently looking at something negative.
						self.lookedAt[translation[2]] = self.lookedAt[translation[2]] - v
					end

				end --End adjustment.
			end

			--If it's a key, indicate.
			if(translation[1] == "key") then
				--Add it to the list of keys we're looking at/update that list.
				--print('is key, is '..translation[1])
				self.keyValues[translation[2]] = self.lookedAt[translation[2]]
				--Also, return because we've hit the bottom of a tree.
				--return --Unecessary, but makes the code easier to read and indicates intent.
			elseif(translation[1] ~= "default" and loop==false) then --Not a key, means it's memory of some kind.
				--Keep on going down until we find some actual keys to either press or not press.
				--print(k)
				--print("isn't key, is "..translation[1])
				--print(self.interpretGoal(self, k))
				self.chooseInput(self, self.interpretGoal(self, k), v)
			end
		--end
	end
end

function decider.interpretGoal(self, goal)
	local translate = {}
	local i = 1
	for item in string.gmatch(goal, "([^_]+)_?") do
      translate[i] = item;
      i = i +1
    end

    return translate
end






-- --++++++++++++++++++++PUBLIC+++++++++++++++++++++++++++++++

-- ---VARIABLES
-- decider.Experimenting = false; --Are we trying something new or utilizing the past?
-- decider.framesToTry = 0;
-- decider.currentKeysPressed = {}


-- ---FUNCTIONS

-- --decides what input to press for the current frame, and returns it as an object.
-- --Requires:
-- --a list of past inputs (using the List class), 
-- --a list of past results (ints of how bytes were different in that frame), 
-- --how long to remember back when choosing moves
-- --hom many frames to average when choosing future inputs.
-- --How much tolerance for sameness it has (based on the number of bytes changed.)
-- function decider.ChooseInput(self, pastInputs, pastResults, memoryLength, framesToAverage, tolerance)

-- 	----------------EDGE CASES----------------------------------------

-- 	--If I'm in the middle of trying something.
-- 	if(self.framesToTry > 0) then 
-- 		--One less frame to press these buttons.
-- 		self.framesToTry = self.framesToTry - 1
-- 		return self.currentKeysPressed 
-- 	end

-- 	--If you don't have any data to work with, press random buttons.
-- 	if(pastInputs == nil or pastInputs.Count == 0) then
-- 		self.currentKeysPressed = self.RandomInput(self)
-- 		return self.currentKeysPressed
-- 	end

-- 	-----------------------CHOOSING INPUT NORMAL-----------------------

-- 	--A sorted list of what frames had the best inputs in the past.
-- 	local bestFrame = List.CreateList()
-- 	local bestInput = List.CreateList()

-- 	--We loop through our past inputs based on how many we're allowed to remember
-- 	--Then we sort them into an ordered list of which ones had the best results.
-- 		--(see bestFrame and bestInput above).
-- 	--After we're done, we'll use those lists to choose our future input.
-- 	for i=pastResults.LastIndex, pastResults.LastIndex - memoryLength, -1 do
-- 		if(pastResults[i] ~= nil) then --if there's anything to remember or iterate on.
-- 			--loop through the list and see if it can be added.
-- 			for j=bestFrame.FirstIndex, bestFrame.FirstIndex + framesToAverage - 1 do
-- 				--If the list isn't full and you're at the end, just add it.
-- 				if(bestFrame[j] == nil) then 
-- 					List.Push(bestFrame, {frame=i, novelty=pastResults[i]})
-- 					List.Push(bestInput, pastInputs[i])
-- 					break
-- 				end
-- 				--Otherwise, check to see if it should be added.
-- 				if(pastResults[i] > bestFrame[j].novelty) then
-- 					List.Insert(bestFrame, j, {frame=i, novelty=pastResults[i]})
-- 					List.Insert(bestInput, j, pastInputs[i])
-- 					if(bestFrame.Count > framesToAverage) then
-- 						List.Pop(bestFrame)
-- 						List.Pop(bestInput)
-- 					end
-- 					--And it's added, so stop checking.
-- 					break
-- 				end
-- 			end --/for
-- 		end
-- 	end --/for
	
-- 	--Now we actually decide which keys to press.
-- 	local avgNovelty, keys, left, up = 0, 0, 0, 0
-- 	--We can't press all directions at the same time, so we let them compete with each other.
-- 	for j=bestInput.FirstIndex, bestInput.LastIndex do
-- 		--record average novelty
-- 		--avgNovelty = (avgNovelty * (j - bestFrame.FirstIndex) + bestFrame[j].novelty)/(j - bestFrame.FirstIndex + 1)
-- 		if(bestFrame[j].novelty > avgNovelty) then avgNovelty = bestFrame[j].novelty end

-- 		--A little bit arbitrary, if there are the same number of left and right inputs, just do neither.
-- 		--Left and right
-- 		if(bestInput[j].left == 1) then 
-- 			left = left + 1
-- 		elseif(bestInput[j].right == 1) then
-- 			left = left - 1
-- 		end
-- 		--Up and down
-- 		if(bestInput[j].up == 1) then
-- 			up = up + 1
-- 		elseif(bestInput[j].down == 1) then
-- 			up = up - 1
-- 		end
-- 	end --/for


-- 	--We've pulled some data out of the past input.
-- 		--Were the past few frames interesting enough to merit a repeat?
-- 	if(avgNovelty > tolerance) then --If so.
-- 		--Now build keypresses based on the input.
-- 			--We start with input of the best frame (for A, B etc...)
-- 			--This isn't ideal, but it keeps some noise in the program's input, which is good
-- 		keys = bestInput[1]
-- 		if(left > 0) then -- left and right again.
-- 			keys.left = 1
-- 			keys.right = nil
-- 		elseif(left < 0) then
-- 			keys.right = 1
-- 			keys.left = nil
-- 		else
-- 			keys.right = nil
-- 			keys.left = nil
-- 		end --Now for up and down
-- 		if(up > 0) then
-- 			keys.up = 1
-- 			keys.down = nil
-- 		elseif(up < 0) then
-- 			keys.down = 1
-- 			keys.up = nil
-- 		else
-- 			keys.up = nil
-- 			keys.down = nil
-- 		end

-- 		--Update and return
-- 		self.currentKeysPressed = keys
-- 		return keys
-- 	else --IF IT's NOT WORTH REPEATING
-- 		--print("bored - "..avgNovelty)
-- 		self.framesToTry = 30 --SHould not be hard coded in the future
-- 		self.currentKeysPressed = self.RandomInput(self)
-- 		return self.currentKeysPressed
-- 	end

-- 	return {} --How did you get here?
-- end


-- --Presses random keys.
-- function decider.RandomInput(self)
-- 	local keys = {}
-- 	local rand = 0 --Random number.

-- 	rand = math.random()
-- 	if (rand < .45) then
-- 		keys.A = 1
-- 	end

-- 	rand = math.random()
-- 	if (rand < .45) then
-- 		keys.B = 1
-- 	end

-- 	rand = math.random()
-- 	if (rand < .4) then
-- 		keys.left = 1
-- 	elseif(rand < .8) then
-- 		keys.right = 1
-- 	end --or press neither

-- 	rand = math.random()
-- 	if (rand< .4) then
-- 		keys.up = 1
-- 	elseif(rand < .8) then
-- 		keys.down = 1
-- 	end


-- 	return keys
-- end


-- --++++++++++++++++++++e/PUBLIC+++++++++++++++++++++++++++++


return decider --Return the object so that index can actually use it.