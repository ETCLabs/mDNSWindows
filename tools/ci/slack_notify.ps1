$body = @{
  username = "AppVeyor CI"
  icon_url = "https://ci.appveyor.com/assets/images/appveyor-blue-144.png"
  attachments = @(
    @{
      fallback = "mDNSWindows build $Env:MDNSWINDOWS_VERSION has been deployed to <https://bintray.com/etclabs/mdnswindows_bin/latest/$Env:MDNSWINDOWS_VERSION|Bintray>."
      color = "#5FE35F"
      text = "mDNSWindows build $Env:MDNSWINDOWS_VERSION has been deployed to <https://bintray.com/etclabs/mdnswindows_bin/latest/$Env:MDNSWINDOWS_VERSION|Bintray>."
      mrkdwn_in = @(
        "text"
      )
    }
  )
}

$json_body = $body | ConvertTo-Json -Depth 4
Invoke-RestMethod -Uri "$Env:SLACK_WEBHOOK" -Body $json_body -Method POST
