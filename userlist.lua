local fs = require("fs")
local http = require("coro-http")
local json = require("json")
local time = require("timer")

--[[
{
  "previousPageCursor": null,
  "nextPageCursor": null,
  "data": [
    {
      "previousUsernames": [
        "RichyPlaysGaming"
      ],
      "hasVerifiedBadge": false,
      "id": 302949765,
      "name": "Shedritsky",
      "displayName": "lol"
    }
  ]
}

]]

local function search(query, limit, cursor)
    if not query then return false, "No query provided" end
    if not limit then limit = 25 end

    local url = "https://users.roproxy.com/v1/users/search?keyword=" .. query .. "&limit=" .. tostring(limit)

    if cursor then
        url = url .. "&cursor=" .. cursor
    end

    local result, body = http.request("GET", url, { { "accept", "application/json" } })

    if result.code == 200 and json.decode(body) then
        return true, body
    else
        return false, "Failure"
    end
end

local users = {}

local currentPage = 1
local totalUsers = 0

local success, request = search("angelo", 100)
local decoded = json.decode(request)
for _, v in pairs(decoded.data) do
    table.insert(users, v)
end
totalUsers = totalUsers + #decoded.data
print("Page 1 done")
while decoded and decoded.nextPageCursor do
    currentPage = currentPage + 1
    totalUsers = totalUsers + #decoded.data

    ::tryagain::
    success, request = search("angelo", 100, decoded.nextPageCursor)
    if not success then
        print("Failed retrieving page " .. tostring(currentpage) .. ", trying again in 5 seconds...")
        time.sleep(5000)
        goto tryagain
    end
    decoded = json.decode(request)

    for _, v in pairs(decoded.data) do
        table.insert(users, v)
    end

    print("Page", currentPage)
    print("Currently on page " .. tostring(currentPage) .. " with " .. tostring(totalUsers) .. " users accumulated.")
    time.sleep(500)
end

fs.writeFile("usersfull.json", json.encode(users))
