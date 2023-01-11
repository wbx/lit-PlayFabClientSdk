-- PlayFabHttps_CoroHttp.lua
-- 
-- luvit coro-http HTTPS implementation for PlayFab LuaSdk
--
-- 11-Jan-2023 - Renamed file from PlayFabHttps_LuaSec to PlayFabHttps_CoroHttp, modified to support luvit coro-http

local http = require("coro-http")

local json = require("json")
local PlayFabSettings = require("PlayFab.PlayFabSettings")

local PlayFabHttps_CoroHttp = {
}

function PlayFabHttps_CoroHttp.MakePlayFabApiCall(urlPath, request, authKey, authValue, onSuccess, onError)
    local requestJson = json.encode(request)
    local requestHeaders = {
        { "X-ReportErrorAsSuccess", "true" },
        { "X-PlayFabSDK", PlayFabSettings._internalSettings.sdkVersionString },
        { "Content-Type", "application/json" },
        -- { "content-length", tostring(string.len(requestJson)) },     -- no need
    }
    if (authKey) then
        requestHeaders[#requestHeaders+1] = {authKey, authValue}
    end
    
    local fullUrl = PlayFabSettings.GetFullUrl(urlPath)
    local httpResponse, body = http.request("POST", fullUrl, requestHeaders, requestJson, 5000)

    -- In async environments errors in callbacks should be isolated but this HTTPS is synchronous so we'll just let the error propagate up
    if (httpResponse.code == 200) then
        local response, _, err = json.decode(body or "null")
        if (response and response.code == 200 and response.data and onSuccess) then
            onSuccess(response.data)
        elseif (response and onError) then
            onError(response)
        elseif (err and onError) then
            onError({
                code = httpResponse.code,
                status = httpResponse.reason,
                errorCode = 1123,
                error = "JsonException",
                errorMessage = "Could not deserialize response from server: " .. err .. ":\n" .. tostring(body)
            })
        elseif (onError) then
            onError({
                code = httpResponse.code,
                status = httpResponse.reason,
                errorCode = 1123,
                error = "ServiceUnavailable",
                errorMessage = "Could not deserialize response from server: " .. tostring(body)
            })
        end
    elseif (onError) then
        onError({
            code = httpResponse.code,
            status = httpResponse.reason,
            errorCode = 1123,
            error = "ServiceUnavailable",
            errorMessage = "Could not deserialize response from server: " .. tostring(body)
        })
    end
end

return PlayFabHttps_CoroHttp
