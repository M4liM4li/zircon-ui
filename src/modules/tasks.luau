--[[
	Loops tied to switches.

	The hand-written shape is ten lines of scaffolding around one line of work — a while loop, three
	unload checks, a pcall, a flag check, a warn nobody sees in a release build, and a wait. Written
	out twenty times it is two hundred lines that all say the same thing, and every one of them keeps
	spinning at its interval after the switch is turned off, no-opping on the flag check.

	Registered here, a task runs only while its flag is on, stops the moment it goes off, and marks
	its own row when it breaks instead of failing where nobody can see it.
]]

local fields = require("@components/Fields")

local tasks = {}

local registry = {}
local running = {}

tasks.Unloaded = false
-- How many ticks in a row may throw before the task is stopped and the switch turned off.
tasks.Tolerance = 3

local function stop(flag: string)
	running[flag] = nil
end

local function start(flag: string)
	local entry = registry[flag]

	if not entry or running[flag] then
		return
	end

	local token = {}

	running[flag] = token

	task.spawn(function()
		local failures = 0

		while running[flag] == token and not tasks.Unloaded do
			local ok, err = pcall(entry.Work)

			if ok then
				failures = 0
			else
				failures += 1

				if entry.OnError then
					task.spawn(entry.OnError, flag, err)
				end

				-- A task that throws every tick is not working and will not start working. Stop it,
				-- put the switch back, and say so on the row rather than burning cycles in silence.
				if failures >= tasks.Tolerance then
					stop(flag)

					local option = fields.Options[flag]

					if option then
						option.Value = false
					end

					local row = fields.Rows[flag]

					if row then
						pcall(function()
							row.Fault = entry.Fault or tostring(err)
						end)
					end

					if fields.OnChanged then
						task.spawn(fields.OnChanged, flag, false)
					end

					return
				end
			end

			task.wait(entry.Interval)
		end
	end)
end

--// Publish
function tasks.Register(flag: string, interval: number, work: () -> (), options: { [string]: any }?)
	options = options or {}

	registry[flag] = {
		Interval = interval or 0.5,
		Work = work,
		Fault = options.Fault,
		OnError = options.OnError,
	}

	local option = fields.Options[flag]

	if option and option.Value == true then
		start(flag)
	end
end

function tasks.Stop(flag: string)
	stop(flag)
end

function tasks.StopAll()
	tasks.Unloaded = true

	for flag in pairs(running) do
		stop(flag)
	end
end

-- One listener for every task: a switch flipping is the only thing that starts or stops one.
fields.Watch(function(flag: string, value: any)
	if not registry[flag] then
		return
	end

	if value == true then
		local row = fields.Rows[flag]

		if row then
			pcall(function()
				row.Fault = nil
			end)
		end

		start(flag)
	else
		stop(flag)
	end
end)

return tasks
