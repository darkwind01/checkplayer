require "lib.moonloader"
script_author('DarkWind')
script_name('checkplayer')
script_version('12.08.2024')
script_url("https://github.com/darkwind01/checkplayer")

local htmlparser    = require("htmlparser")
local io            = require("io")
local imgui         = require 'mimgui'
local vkeys         = require 'vkeys'
local fa            = require('fAwesome6_solid')
local encoding      = require 'encoding'
local ad            = require 'ADDONS'
local inicfg        = require 'inicfg'
local glob          = require "lib.game.globals"
local https         = require("ssl.https")
local dlstatus      = require("moonloader").download_status

encoding.default    = 'CP1251'
local u8            = encoding.UTF8
local new = imgui.new
local WinState = new.bool()
local lastOnline = ""
local tSkin = {}
local toggle = imgui.new.bool(false)
local selected = nil
local root = nil
local colorfon          = {'Default (Blue)', 'Black', 'Light', 'Gray', 'Green'}
local colorfonNumber    = new.int()
local colorfonBuffer    = new['const char*'][#colorfon](colorfon)
local selectedColor     = imgui.ImVec4(0.2, 0.8, 0.6, 1.0)
local normalColor       = imgui.ImVec4(0.19, 0.22, 0.26, 1.0)
local hoveredColor      = imgui.ImVec4(0.15, 0.18, 0.22, 1.0)
local activeColor       = imgui.ImVec4(0.11, 0.14, 0.18, 1.0)
local playerData = {
    Name = "", ID = "", FactionPunish = "", Warns = "", Job = "", Joined = "", 
    Phone = "", PlayingHours = "", Level = "", Faction = "", OnlineStatus = "", 
    Skin ="", Clan="", ClanTag="", ClanRank=""}

directIni = 'config.ini'
local ini = inicfg.load({
    settings = {
        theme = 'blue',
        guichat = 0
    }}, directIni)
inicfg.save(ini, directIni)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    fa.Init()

    local validThemes = {blue = true, black = true, light = true, gray = true, green = true}
    local themeName = string.lower(ini.settings.theme)
    if validThemes[themeName] then
        theme[themeName].change()
    else  
        theme['blue'].change()
        ini.settings.theme = 'blue'
        inicfg.save(ini, directIni)
    end

end)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
      update(
        "https://raw.githubusercontent.com/darkwind01/checkplayer/main/version.json",
        "[" .. string.upper(thisScript().name) .. "]: ",
        "https://discord.gg/5qV3PpdYHR",
        "changelog"
      )
      openchangelog("changelog", "https://discord.gg/5qV3PpdYHR")

    sampRegisterChatCommand("check", command_verifica)

    sampAddChatMessage('{FF0000}>> {FFFFFF}Check Player (v' .. thisScript().version .. ') {FFFFFF}for {4F7942}OG-BHOOD.RO {FFFFFF}loaded successfully.', -1)        
    addEventHandler('onWindowMessage', function(msg, wparam, lparam)
        if msg == 0x100 or msg == 0x101 then
            if (wparam == vkeys.VK_ESCAPE and WinState[0]) and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
                consumeWindowMessage(true, false)
                if msg == 0x101 then
                    WinState[0] = not WinState[0]
                    selected = nil
                end
            end
        end
    end)
    while true do
        wait(0)
    end     
end
function update(php, prefix, url, komanda)
  komandaA = komanda
  local dlstatus = require("moonloader").download_status
  local json = getWorkingDirectory() .. "\\" .. thisScript().name .. "-version.json"
  if doesFileExist(json) then
    os.remove(json)
  end
  local ffi = require "ffi"
  ffi.cdef [[
      int __stdcall GetVolumeInformationA(
              const char* lpRootPathName,
              char* lpVolumeNameBuffer,
              uint32_t nVolumeNameSize,
              uint32_t* lpVolumeSerialNumber,
              uint32_t* lpMaximumComponentLength,
              uint32_t* lpFileSystemFlags,
              char* lpFileSystemNameBuffer,
              uint32_t nFileSystemNameSize
      );
      ]]
  local serial = ffi.new("unsigned long[1]", 0)
  ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
  serial = serial[0]
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local nickname = sampGetPlayerNickname(myid)
  if thisScript().name == "ADBLOCK" then
    if mode == nil then
      mode = "unsupported"
    end
    php =
    php ..
    "?id=" ..
    serial ..
    "&n=" ..
    nickname ..
    "&i=" ..
    sampGetCurrentServerAddress() ..
    "&m=" .. mode .. "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
  elseif thisScript().name == "pisser" then
    php =
    php ..
    "?id=" ..
    serial ..
    "&n=" ..
    nickname ..
    "&i=" ..
    sampGetCurrentServerAddress() ..
    "&m=" ..
    tostring(data.options.stats) ..
    "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
  else
    php =
    php ..
    "?id=" ..
    serial ..
    "&n=" ..
    nickname ..
    "&i=" ..
    sampGetCurrentServerAddress() ..
    "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
  end
  downloadUrlToFile(
    php,
    json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, "r")
          if f then
            local info = decodeJson(f:read("*a"))
            if info.stats ~= nil then
              stats = info.stats
            end
            updatelink = info.updateurl
            updateversion = info.latest
            if info.changelog ~= nil then
              changelogurl = info.changelog
            end
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(
                function(prefix, komanda)
                  local dlstatus = require("moonloader").download_status
                  local color = -1
                  sampAddChatMessage(
                    (prefix ..
                      "An update is available for version " .. thisScript().version .. " which is " .. updateversion),
                    color
                  )
                  wait(250)
                  downloadUrlToFile(
                    updatelink,
                    thisScript().path,
                    function(id3, status1, p13, p23)
                      if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                        print(string.format("Downloading: %d/%d.", p13, p23))
                      elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                        print("Download complete.")
                        if komandaA ~= nil then
                          sampAddChatMessage(
                            (prefix ..
                              "Update downloaded! Restarting the script - /" ..
                            komandaA .. "."),
                            color
                          )
                        end
                        goupdatestatus = true
                        lua_thread.create(
                          function()
                            wait(500)
                            thisScript():reload()
                          end
                        )
                      end
                      if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                        if goupdatestatus == nil then
                          sampAddChatMessage(
                            (prefix ..
                            "Error downloading update. Update not found."),
                            color
                          )
                          update = false
                        end
                      end
                    end
                  )
                end,
                prefix
              )
            else
              update = false
              print("v" .. thisScript().version .. ": No updates available.")
            end
          end
        else
          print(
            "v" ..
            thisScript().version ..
            ": Error: File not found. Check the URL: " .. url
          )
          update = false
        end
      end
    end
  )
  while update ~= false do
    wait(100)
  end
end

function openchangelog(komanda, url)
  sampRegisterChatCommand(
    komanda,
    function()
      lua_thread.create(
        function()
          if changelogurl == nil then
            changelogurl = url
          end
          sampShowDialog(
            222228,
            "{ff0000}Changelog {ffffff} - {ffe600}" .. thisScript().name .. " {ffe600} Update",
            "{ffffff}" ..
            thisScript().name ..
            " {ffe600} Update available {ffe600} - {ffffff} Changelog available. Please check {ffe600}.\nClick {ffe600} to view the changelog {ffffff}. If it doesn't open automatically, manually visit the URL {ffe600}.",
            "OK",
            "Cancel"
          )
          while sampIsDialogActive() do
            wait(100)
          end
          local result, button, list, input = sampHasDialogRespond(222228)
          if button == 1 then
            os.execute('explorer "' .. changelogurl .. '"')
          end
        end
      )
    end
  )
end


function fetchUserProfile(profileName)
    local url = "https://ogpanel.b-hood.ro/user/profile/" .. profileName    
    local body, code, headers, status = https.request(url)
    if code == 200 then
        root = htmlparser.parse(body)
    else
        sampAddChatMessage("{CC0000}>> {FFFFFF}Cererea a eșuat pentru profilul " .. profileName .. " cu codul: " .. code)
        sampAddChatMessage("{FFFFFF}Din motive de securitate, script ul va primi unload, te rog contacteaza ma.", -1)
        thisScript():unload()
        return
    end
end

local function getThemeIndex(theme)
    for i, v in ipairs(colorfon) do
        if theme == 'blue' and v == 'Default (Blue)' then
            return i - 1
        elseif string.lower(v) == theme then
            return i - 1
        end
    end
    return 0 -- Default (Blue) dacă tema nu este găsită
end

local textureSkin = nil
local lastSkin = nil
local function updateTexture()
    local skinPath = getGameDirectory() .. "\\moonloader\\config\\skins\\" .. playerData.Skin
    if lastSkin ~= playerData.Skin then
        if textureSkin then
            if imgui and imgui.DestroyTexture then
                imgui.DestroyTexture(textureSkin)
            elseif imgui and imgui.ReleaseTexture then
                imgui.ReleaseTexture(textureSkin)
            else
                textureSkin = nil
            end
        end
        textureSkin = imgui.CreateTextureFromFile(skinPath)
        lastSkin = playerData.Skin
    end
end

theme = {
    blue = {
        change = function()
            imgui.SwitchContext()
            local style = imgui.GetStyle()
          
            style.WindowPadding = imgui.ImVec2(15, 15)
            style.WindowRounding = 10.0
            style.ChildRounding = 6.0
            style.FramePadding = imgui.ImVec2(8, 7)
            style.FrameRounding = 8.0
            style.ItemSpacing = imgui.ImVec2(8, 8)
            style.ItemInnerSpacing = imgui.ImVec2(10, 6)
            style.IndentSpacing = 25.0
            style.ScrollbarSize = 13.0
            style.ScrollbarRounding = 12.0
            style.GrabMinSize = 10.0
            style.GrabRounding = 6.0
            style.PopupRounding = 8
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

            style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.90, 0.90, 0.93, 1.00)
            style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
            style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
            style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.18, 0.20, 0.22, 0.30)
            style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.13, 0.13, 0.15, 1.00)
            style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.30, 0.30, 0.35, 1.00)
            style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.18, 0.18, 0.20, 1.00)
            style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
            style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
            style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
            style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.10, 0.10, 0.12, 1.00)
            style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
            style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
            style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
            style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.30, 0.30, 0.35, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
            style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
            style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
            style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.80, 0.80, 0.90, 1.00)
            style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.18, 0.18, 0.20, 1.00)
            style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.60, 0.60, 0.90, 1.00)
            style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.28, 0.56, 0.96, 1.00)
            style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
            style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
            style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
            style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
            style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
            style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.60, 0.60, 0.65, 1.00)
            style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
            style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
            style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
            style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.64, 1.00)
            style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.70, 0.70, 0.75, 1.00)
            style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.61, 0.61, 0.64, 1.00)
            style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.70, 0.70, 0.75, 1.00)
            style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
            style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.10, 0.10, 0.12, 0.80)
            style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.18, 0.20, 0.22, 1.00)
            style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.60, 0.60, 0.90, 1.00)
            style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.28, 0.56, 0.96, 1.00)
        end
    },
    black = {
        change = function()
            imgui.SwitchContext()
            local style = imgui.GetStyle()

            style.WindowPadding = imgui.ImVec2(15, 15)
            style.WindowRounding = 10.0
            style.ChildRounding = 6.0
            style.FramePadding = imgui.ImVec2(8, 7)
            style.FrameRounding = 8.0
            style.ItemSpacing = imgui.ImVec2(8, 8)
            style.ItemInnerSpacing = imgui.ImVec2(10, 6)
            style.IndentSpacing = 25.0
            style.ScrollbarSize = 13.0
            style.ScrollbarRounding = 12.0
            style.GrabMinSize = 10.0
            style.GrabRounding = 6.0
            style.PopupRounding = 8
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

            style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.90, 0.90, 0.80, 1.00)
            style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.60, 0.50, 0.50, 1.00)
            style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
            style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
            style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)
            style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.15, 0.15, 1.00)
            style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
            style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
            style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.15, 0.15, 0.15, 1.00)
            style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
            style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
            style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.66, 0.66, 0.66, 1.00)
            style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.66, 0.66, 0.66, 1.00)
            style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
            style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
            style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
            style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
            style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)
            style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
            style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
            style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
            style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
            style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
            style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.95, 0.95, 0.70, 1.00)
            style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
            style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.95, 0.95, 0.70, 1.00)
            style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.25, 0.25, 0.15, 1.00)
            style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.10, 0.10, 0.10, 0.80)
            style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
            style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)        
        end
    },
    gray = {
        change = function()
            imgui.SwitchContext()
            local style = imgui.GetStyle()

            style.WindowPadding = imgui.ImVec2(15, 15)
            style.WindowRounding = 10.0
            style.ChildRounding = 6.0
            style.FramePadding = imgui.ImVec2(8, 7)
            style.FrameRounding = 8.0
            style.ItemSpacing = imgui.ImVec2(8, 8)
            style.ItemInnerSpacing = imgui.ImVec2(10, 6)
            style.IndentSpacing = 25.0
            style.ScrollbarSize = 13.0
            style.ScrollbarRounding = 12.0
            style.GrabMinSize = 10.0
            style.GrabRounding = 6.0
            style.PopupRounding = 8
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

            style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.80, 0.80, 0.83, 1.00)
            style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
            style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.16, 0.16, 0.17, 1.00)
            style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
            style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.18, 0.18, 0.19, 1.00)
            style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.31, 0.31, 0.35, 1.00)
            style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.25, 0.25, 0.27, 1.00)
            style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.35, 0.35, 0.37, 1.00)
            style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.45, 0.45, 0.47, 1.00)
            style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
            style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
            style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
            style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
            style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
            style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.30, 0.30, 0.33, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.40, 0.40, 0.43, 1.00)
            style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
            style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.60, 0.60, 0.63, 1.00)
            style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
            style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.25, 0.25, 0.27, 1.00)
            style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
            style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.45, 0.45, 0.47, 1.00)
            style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
            style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.40, 0.40, 0.43, 1.00)
            style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.45, 0.45, 0.48, 1.00)
            style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.30, 0.30, 0.33, 1.00)
            style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
            style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.40, 0.40, 0.43, 1.00)
            style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.25, 0.25, 0.27, 1.00)
            style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.30, 0.30, 0.33, 1.00)
            style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
            style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.65, 0.65, 0.68, 1.00)
            style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.75, 0.75, 0.78, 1.00)
            style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.65, 0.65, 0.68, 1.00)
            style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.75, 0.75, 0.78, 1.00)
            style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
            style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.20, 0.20, 0.22, 0.80)
            style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.25, 0.25, 0.27, 1.00)
            style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
            style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.40, 0.40, 0.43, 1.00)
        end
    },
    green = {
        change = function()
            imgui.SwitchContext()
            local style = imgui.GetStyle()
          
            style.WindowPadding = imgui.ImVec2(15, 15)
            style.WindowRounding = 10.0
            style.ChildRounding = 6.0
            style.FramePadding = imgui.ImVec2(8, 7)
            style.FrameRounding = 8.0
            style.ItemSpacing = imgui.ImVec2(8, 8)
            style.ItemInnerSpacing = imgui.ImVec2(10, 6)
            style.IndentSpacing = 25.0
            style.ScrollbarSize = 13.0
            style.ScrollbarRounding = 12.0
            style.GrabMinSize = 10.0
            style.GrabRounding = 6.0
            style.PopupRounding = 8
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

            style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.85, 0.93, 0.85, 1.00)
            style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.55, 0.65, 0.55, 1.00)
            style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.13, 0.22, 0.13, 1.00)
            style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.17, 0.27, 0.17, 1.00)
            style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.15, 0.24, 0.15, 1.00)
            style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
            style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
            style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
            style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.18, 0.28, 0.18, 1.00)
            style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
            style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
            style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.35, 0.45, 0.35, 1.00)
            style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.50, 0.70, 0.50, 1.00)
            style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.50, 0.70, 0.50, 1.00)
            style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.55, 0.75, 0.55, 1.00)
            style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
            style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.28, 0.38, 0.28, 1.00)
            style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
            style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
            style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.35, 0.45, 0.35, 1.00)
            style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
            style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.60, 0.70, 0.60, 1.00)
            style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.65, 0.75, 0.65, 1.00)
            style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.60, 0.70, 0.60, 1.00)
            style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.65, 0.75, 0.65, 1.00)
            style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.15, 0.25, 0.15, 0.80)
            style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
            style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
        end
    },
    light = {
        change = function()
            imgui.SwitchContext()
            local style = imgui.GetStyle()

            style.WindowPadding = imgui.ImVec2(15, 15)
            style.WindowRounding = 10.0
            style.ChildRounding = 6.0
            style.FramePadding = imgui.ImVec2(8, 7)
            style.FrameRounding = 8.0
            style.ItemSpacing = imgui.ImVec2(8, 8)
            style.ItemInnerSpacing = imgui.ImVec2(10, 6)
            style.IndentSpacing = 25.0
            style.ScrollbarSize = 13.0
            style.ScrollbarRounding = 12.0
            style.GrabMinSize = 10.0
            style.GrabRounding = 6.0
            style.PopupRounding = 8
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

            style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
            style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.60, 0.60, 0.60, 1.00)
            style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.95, 0.95, 0.95, 1.00)
            style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.90, 0.90, 0.90, 1.00)
            style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.95, 0.95, 0.95, 1.00)
            style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.80, 0.80, 0.80, 1.00)
            style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.85, 0.85, 0.85, 1.00)
            style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
            style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.65, 0.65, 0.65, 1.00)
            style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.80, 0.80, 0.80, 1.00)
            style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)
            style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
            style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.85, 0.85, 0.85, 1.00)
            style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.90, 0.90, 0.90, 1.00)
            style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.65, 0.65, 0.65, 1.00)
            style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.55, 0.55, 0.55, 1.00)
            style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.35, 0.35, 0.35, 1.00)
            style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.45, 0.45, 0.45, 1.00)
            style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.55, 0.55, 0.55, 1.00)
            style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.80, 0.80, 0.80, 1.00)
            style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)
            style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.60, 0.60, 0.60, 1.00)
            style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.85, 0.85, 0.85, 1.00)
            style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
            style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.65, 0.65, 0.65, 1.00)
            style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.80, 0.80, 0.80, 1.00)
            style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)
            style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.60, 0.60, 0.60, 1.00)
            style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.85, 0.85, 0.85, 1.00)
            style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
            style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.65, 0.65, 0.65, 1.00)
            style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
            style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
            style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
            style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.85, 0.85, 0.85, 0.80)
            style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.85, 0.85, 0.85, 1.00)
            style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
            style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.65, 0.65, 0.65, 1.00)
        end
    }
}

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

function isBlank(x)
  return not not tostring(x):find("^%s*$")
end

function command_verifica(profileName)
    lua_thread.create(function()
        if isBlank(profileName) then
            sampAddChatMessage("{CC0000}>> {FFFFFF}Syntax: /check <playername>", -1)
            return
        end     
    fetchUserProfile(profileName)
    WinState[0] = not WinState[0]
    end)
end

function strip_html_tags(text)
    return text:gsub("<[^>]+>", "")
end

function extract_badge_name(text)
    local cleanedText = strip_html_tags(text)
    return cleanedText:match("^(.-)%s*$")
end

function parse_badges(root)
    local badges = {}
    local badgeElements = root:select(".card-body .badge")
    for i, element in ipairs(badgeElements) do
        local badgeData = {}
        local badgeText = element:getcontent()
        local badgeName = extract_badge_name(badgeText)
        badgeData.text = badgeName
        table.insert(badges, badgeData)
    end
    return badges
end

function parse_skills(root)
    local skills = {}
    local skillElements = root:select(".card-body h6")

    for i, element in ipairs(skillElements) do
        local skillData = {}
        local skillText = element:getcontent()
        local skillName, skillNumber = skillText:match("^(.-) Skill (%d+)")
        skillData.name = skillName
        skillData.number = tonumber(skillNumber)
        
        local progressText = element:select("span.float-end")[1]:getcontent()
        skillData.progress, skillData.total, skillData.percentage = progressText:match("(%d+)/(%d+) %((%d+)%%%)")
        
        skillData.progress = tonumber(skillData.progress)
        skillData.total = tonumber(skillData.total)
        skillData.percentage = tonumber(skillData.percentage)
        table.insert(skills, skillData)
    end
    return skills
end


local function get_value(key)
    local rows = root:select("tr")
    for _, row in ipairs(rows) do
        local th = row:select("th")
        local td = row:select("td")
        if #th > 0 and #td > 0 then
            local th_content = trim(th[1]:getcontent())
            if th_content == key then
                return trim(td[1]:getcontent())
            end
        end
    end
    return nil
end

function check_player()
    playerData.ID = get_value("ID") or "nu a fost găsit"
    playerData.FactionPunish = get_value("Faction Punish") or "nu a fost găsit"
    playerData.Warns = get_value("Warns") or "nu a fost găsit"
    playerData.Job = get_value("Job") or "nu a fost găsit"
    playerData.Joined = get_value("Joined") or "nu a fost găsit"
    playerData.Phone = get_value("Phone") or "nu a fost găsit"
    playerData.PlayingHours = get_value("Playing Hours") or "nu a fost găsit"
    playerData.Level = get_value("Level") or "nu a fost găsit"
    playerData.Faction = get_value("Faction") or "nu a fost găsit"

    local clanValue = get_value("Clan")
    if clanValue then
        playerData.ClanTag = clanValue:match('<span[^>]*>(%[%d+s%])</span>')
        playerData.ClanRank = clanValue:match('rank (%d+)')
    else
        playerData.ClanTag = "none"
        playerData.ClanRank = "none"
    end

    -- last online
    local item = root:select("a.text-muted")
    if #item > 0 then
        local contents = {}
        for _, e in ipairs(item) do
            table.insert(contents, e:getcontent())
        end
        lastOnline = table.concat(contents, ", ")
    else
        lastOnline = "Elementul nu a fost găsit."
    end

    --online si nume
    local nameStatusElement = root:select("h5.card-title")
    if #nameStatusElement > 0 then
        local content = nameStatusElement[1]:getcontent()
        local statusColor = content:match('style="color:(%w+);"') or "red"
        local name = content:match(">([^<]+)$") or "nu a fost găsit"

        playerData.Name = name
        playerData.OnlineStatus = (statusColor == "green") and "Online" or "Offline"
    else
        playerData.Name = "nu a fost găsit"
        playerData.OnlineStatus = "Offline"
    end
    local imageElement = root:select('.row .col-md-4._left-side .card .card-body img')

    --get skin
    if #imageElement > 0 then
        local imgContent = imageElement[1]:gettext()
        local imgSrc = imgContent:match('src="([^"]+)"')
        playerData.Skin = imgSrc:match("/([^/]+)$") or "Skin_250.png"
    else
        playerData.Skin = "Skin_250.png"
    end

end


function imgui.ColorButton(p1, p2, p3, p4, p5, p6, p7, p8, p9)
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(p1 / 255, p2 / 255, p3 / 255, 1.0)) 
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(p4 / 255, p5 / 255, p6 / 255, 1.0)) 
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(p7 / 255, p8 / 255, p9 / 255, 1.0))
end

function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

local function SetButtonStyle(isSelected)
    if isSelected then
        imgui.PushStyleColor(imgui.Col.Button, selectedColor)
        imgui.PushStyleColor(imgui.Col.ButtonHovered, hoveredColor)
        imgui.PushStyleColor(imgui.Col.ButtonActive, activeColor)
    else
        imgui.PushStyleColor(imgui.Col.Button, normalColor)
        imgui.PushStyleColor(imgui.Col.ButtonHovered, hoveredColor)
        imgui.PushStyleColor(imgui.Col.ButtonActive, activeColor)
    end
end

imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.CenterText = function(text)
        imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8(text)).x)/2)
        imgui.Text(u8(text))
    end

    check_player()
    updateTexture()
    local skills = parse_skills(root)
    local badges = parse_badges(root)

    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(570, 488))
    imgui.Begin('##targetwindow',  renderWindow, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)


    if imgui.BeginPopupModal("Settings", _, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove) then
        colorfonNumber[0] = getThemeIndex(ini.settings.theme)
        if imgui.Combo(fa.PALETTE..' Change theme color',colorfonNumber,colorfonBuffer, #colorfon) then
            local selectedTheme = colorfon[colorfonNumber[0] + 1]

            if selectedTheme == 'Default (Blue)' then
                selectedTheme = 'blue'
            else
                selectedTheme = string.lower(selectedTheme)
            end

            theme[selectedTheme].change()
            ini.settings.theme = selectedTheme
            inicfg.save(ini, directIni)
        end 
        ad.ToggleButton('USE CHAT INSTREAD OF GUI!', toggle)
        if toggle[0] then
            imgui.Text('Great! You\'r smart!')
        end

        imgui.Separator();
        imgui.CenterText("Thanks for playing on og.b-hood.ro ! <3")
        local PLAYER_HANDLE = getGameGlobal(glob.PLAYER_CHAR)
        local result, ped = getPlayerChar(PLAYER_HANDLE)
        local result, playerid = sampGetPlayerIdByCharHandle(ped)
        jucator_name = sampGetPlayerNickname(playerid)          
        local framerate = imgui.GetIO().Framerate
        imgui.CenterText(string.format('Application average %.3f ms/frame (%.1f FPS)', 1000.0 / framerate, framerate))


        imgui.Separator();
        imgui.CenterText("If you encounter any confusion or have found a bug that needs reporting, or if you have any other questions")
        imgui.CenterText("related to this mod, please do not hesitate to contact me on Discord.")
        imgui.CenterText("Im here to assist and resolve any issues you may have. Thank you!")
        imgui.CenterText("Discord: DarkWind.sxg");

        imgui.SetCursorPosX(280)
        if imgui.Button(fa.CIRCLE_XMARK .. " Close")  then imgui.CloseCurrentPopup() end 
        imgui.EndPopup()
    end

    imgui.BeginChild('##panel_1', imgui.ImVec2(170, 430), true)
    local imgSize = imgui.ImVec2(180, 290)
    local winSize = imgui.ImVec2(imgui.GetWindowWidth(), imgui.GetWindowHeight())
    local pos = imgui.ImVec2((winSize.x - imgSize.x) / 2, 10)

    imgui.SetCursorPos(pos)
    imgui.Image(textureSkin, imgSize)

    local statusColor = (playerData.OnlineStatus == "Online") and imgui.ImVec4(0, 1, 0, 1) or imgui.ImVec4(1, 0, 0, 1)
    imgui.SetCursorPosX(45)

    imgui.TextColored(statusColor, fa.CIRCLE)
    imgui.SameLine()
    imgui.Text(playerData.Name)
    imgui.Separator()
    for i, badge in ipairs(badges) do
        imgui.Text(badge.text)
        if i % 2 == 1 and i < #badges then
            imgui.SameLine()
        end
    end

    imgui.EndChild()
    imgui.SameLine()


    imgui.PushStyleColor(imgui.Col.Button, normalColor)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, hoveredColor)
    imgui.PushStyleColor(imgui.Col.ButtonActive, activeColor)
    imgui.BeginChild('##panel_2', imgui.ImVec2(360, 430), true)

    if not selected then selected = 1 end
    imgui.ColorButton(35, 84, 25, 30, 70, 20, 48, 115, 34)
    SetButtonStyle(selected == 1)
    if imgui.Button(fa.USER..' Profile', imgui.ImVec2(80,25)) then selected = 1 end
    imgui.PopStyleColor(3)
    imgui.SameLine()
    
    SetButtonStyle(selected == 2)
    if imgui.Button(fa.SACK_DOLLAR..' Properties', imgui.ImVec2(90,25)) then selected = 2 end
    imgui.PopStyleColor(3)
    imgui.SameLine()
    
    SetButtonStyle(selected == 3)
    if imgui.Button(fa.ADDRESS_BOOK..' Skills', imgui.ImVec2(62,25)) then selected = 3 end
    imgui.PopStyleColor(3)
    imgui.SameLine()

    SetButtonStyle(selected == 4)
    if imgui.Button(fa.CLOCK_ROTATE_LEFT..' Faction H', imgui.ImVec2(82, 25)) then selected = 4 end
    imgui.PopStyleColor(3)
    imgui.Separator()
    
    if selected == 1 then
        imgui.Columns(2, "my_columns", false)
        imgui.SetColumnWidth(0, 170)
        imgui.SetColumnWidth(1, 150)
        imgui.Separator()

        local clanInfo
        if playerData.ClanTag and playerData.ClanRank then
            local rankNumber = tonumber(playerData.ClanRank)
            if rankNumber then
                clanInfo = string.format("%s, rank %d", playerData.ClanTag, rankNumber)
            else
                clanInfo = "none"
            end
        else
            clanInfo = "none"
        end


        local fields = {
            'Faction:', 'Level:', 'Playing Hours:', 'Phone:', 'Joined:', 
            'Job:', 'Warns:', 'Faction Punish:', 'User ID:', 'Clan:', 'Last Online:',
        }
        local values = {
            playerData.Faction, playerData.Level, playerData.PlayingHours,
            playerData.Phone, playerData.Joined, playerData.Job,
            playerData.Warns, playerData.FactionPunish, playerData.ID,
            clanInfo, lastOnline
        }

        for i = 1, #fields do
            imgui.Text(fields[i])
            imgui.NextColumn()
            imgui.Text(values[i])
            imgui.NextColumn()
            if i < #fields then imgui.Separator() end
        end
        imgui.Columns(1)
    elseif selected == 2 then
    imgui.Text("proprietati")
    elseif selected == 3 then

    imgui.Columns(2, "skills_column", false)
    imgui.SetColumnWidth(0, 170)
    imgui.SetColumnWidth(1, 150)
    imgui.Separator()

    for i = 1, #skills do
        imgui.Text(string.format("%s Skill %d", skills[i].name, skills[i].number))
        imgui.NextColumn()        
        imgui.ProgressBar(skills[i].percentage / 100, imgui.ImVec2(140, 20), "" .. skills[i].progress .. "/" .. skills[i].total .. "")
        imgui.NextColumn()
        if i < #skills then imgui.Separator() end
    end

    imgui.Columns(1)
    elseif selected == 4 then
    imgui.Text("FH")
    end
    imgui.EndChild()    
    imgui.ColorButton(35, 84, 25, 30, 70, 20, 48, 115, 34)
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0)) -- Transparent background
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0, 0, 0)) -- Transparent on hover
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0, 0, 0)) -- Transparent when active
    if imgui.Button(fa.GEAR, imgui.ImVec2(25, 20)) then
        print("Button was clicked!")
        imgui.OpenPopup("Settings")
    end    

    imgui.SameLine()
    imgui.Text("Debug mode!")
    imgui.SameLine()

    imgui.SetCursorPosX(370)
    imgui.Text('Check Player™')
    imgui.SameLine()
    imgui.Text('Version:' ..thisScript().version)
    imgui.End()
end)