--[[=============================================--
-- test.lua
-- Sample script to demo the library with
-- CoroWrap usage.
--
-- Expected output of this script is:
--   Login Successful: B110DCFCEE5F14D0
--     SomeKey:      NewValue
--     LiveOpsStore: LiveOpsStore1
--     PlayFab:      {"Status": "Awesome"}
--
-- Author: Lyrthras
--=============================================]]--


local CoroWrap = require 'PlayFab/CoroWrap'
local PlayFabClientApi = CoroWrap(require 'PlayFab/PlayFabClientApi')

-- Always set your titleId first, before making any API calls
PlayFabClientApi.settings.titleId = "6195" -- TODO: Set this to your string titleId you created on PlayFab Game Manager website

-- After the above setup is complete, you can make a Login API call
local loginRequest = {
    -- https://api.playfab.com/Documentation/Client/method/LoginWithCustomID
    CustomId = "TestCustomId",
    CreateAccount = true
}

local res, err = PlayFabClientApi.LoginWithCustomID(loginRequest)
if err then
    error("Login Failed: " .. err.errorMessage)
end


print("Login Successful: " .. res.PlayFabId)


-- After login, the full client API will fuction properly
res, err = PlayFabClientApi.GetTitleData({})
if err then
    error("GetTitleData Failed: " .. err.errorMessage)
end

for key, value in pairs(res.Data) do
    print("  "..key..":\t"..value)
end
