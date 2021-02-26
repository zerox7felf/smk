#!/bin/env lua
local args = {...}

if #args < 2 then
    local line = string.char(27).."[4m"
    local clear = string.char(27).."[0m"
    print(
        "Usage:\n smk "..line.."smk file"..clear.." "..line.."output makefile"..clear..
        " ["..line.."config.mk alternate name"..clear.."]"
    )
    os.exit(1)
end

local objects = {}
local executables = {}

local entries = io.open(args[1], "r")
if not entries then error("Unable to open smk file") end
local lineCount = 0
while true do
    local line = entries:read()
    if not line then break end
    lineCount = lineCount + 1

    local split = line:find(":")
    if not split then error("Expected field separator on line "..lineCount) end
    
    local fieldSection = line:match("^[^:]+:")
    if not fieldSection then error("Expected object/executable name on line "..lineCount) end
    fieldSection = fieldSection:sub(1,-2)

    local fieldSpec = { isExec = false, name = "" }
    for token in fieldSection:gmatch("[^%s]+") do
        if token == "exec" then
            fieldSpec.isExec = true
        else
            fieldSpec.name = token
            break
        end
    end
    if not fieldSpec.name then error("Expected object/executable name on line "..lineCount) end

    (fieldSpec.isExec and executables or objects)[fieldSpec.name] = {
        files = {}, heads = {}, objs = {}
    }

    local numDeps = 0
    for dep in line:sub(split+1):gmatch("[^%s]+") do
        numDeps = numDeps + 1
        if dep:sub(1,1) == "$" then
            table.insert(
                (fieldSpec.isExec and executables or objects)[fieldSpec.name].objs,
                dep:sub(2)
            )
        elseif dep:match("%(.+%)") then
            table.insert(
                (fieldSpec.isExec and executables or objects)[fieldSpec.name].heads,
                dep:sub(2,-2)
            )
        else
            table.insert(
                (fieldSpec.isExec and executables or objects)[fieldSpec.name].files,
                dep
            )
        end
    end
    if numDeps == 0 then error("Expected dependencies on line "..lineCount) end
end
entries:close()

local confName = args[3] or "config.mk"
if not os.execute("test -e "..confName) then
    local confFile = io.open(confName, "w")
    if not confFile then error("Unable to open config file") end
    confFile:write(
        "CC=gcc\n"..
        "INCLUDE_DIR=include\n"..
        "SRC_DIR=src\n"..
        "BUILD_DIR=bin\n"..
        "FLAGS=-I$(INCLUDE_DIR)\n"
    )
    confFile:close()
end

local output = io.open(args[2], "w")
if not output then error("Unable to open output file") end

output:write("include "..confName.."\n")

for obj, deps in pairs(objects) do
    objString = "$(BUILD_DIR)/"..obj..".o: "
    buildString = "\t$(CC) -c "

    for _,file in pairs(deps.files) do
        buildString = buildString.."$(SRC_DIR)/"..file.." "
        objString = objString.."$(SRC_DIR)/"..file.." "
    end

    for _,file in pairs(deps.heads) do
        objString = objString.."$(INCLUDE_DIR)/"..file.." "
    end

    for _,objDep in pairs(deps.objs) do
        buildString = buildString.."$(BUILD_DIR)/"..objDep..".o "
        objString = objString.."$(BUILD_DIR)/"..objDep..".o "
    end

    buildString = buildString.."$(FLAGS) -o $(BUILD_DIR)/"..obj..".o"

    output:write(objString.."\n"..buildString.."\n")
end

for obj, deps in pairs(executables) do
    objString = "$(BUILD_DIR)/"..obj..": "
    buildString = "\t$(CC) "

    for _,file in pairs(deps.files) do
        buildString = buildString.."$(SRC_DIR)/"..file.." "
        objString = objString.."$(SRC_DIR)/"..file.." "
    end

    for _,file in pairs(deps.heads) do
        objString = objString.."$(INCLUDE_DIR)/"..file.." "
    end

    for _,objDep in pairs(deps.objs) do
        buildString = buildString.."$(BUILD_DIR)/"..objDep..".o "
        objString = objString.."$(BUILD_DIR)/"..objDep..".o "
    end

    buildString = buildString.."$(FLAGS) -o $(BUILD_DIR)/"..obj

    output:write(objString.."\n"..buildString.."\n")
end
output:close()
