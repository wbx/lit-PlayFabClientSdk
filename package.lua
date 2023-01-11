return {
    name = "wbx/PlayFab",
    version = "0.125.220509-4",
    description = "PlayFab Client SDK modified for luvit/lit use, with optional coro-style wrapper.",
    license = "Apache License 2.0",
    dependencies = {
        "creationix/coro-http",
        "luvit/secure-socket"
    },
    files = {
        "LICENSE",
        "**.lua",
        "!test.lua"
    }
}
