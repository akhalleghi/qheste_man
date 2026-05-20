Remove-Item Env:HTTP_PROXY, Env:HTTPS_PROXY, Env:ALL_PROXY, Env:http_proxy, Env:https_proxy, Env:all_proxy, Env:NO_PROXY, Env:no_proxy -ErrorAction SilentlyContinue
Write-Host "Proxy OFF (this terminal only)"
