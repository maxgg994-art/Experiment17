-- Managers/MusicManager.lua
-- Музыкальный плеер с плейлистом и кнопками управления

local MusicManager = {}
local Services = require(script.Parent.Parent.Core.Services)
local State = require(script.Parent.Parent.Core.State)
local NotificationManager = require(script.Parent.NotificationManager)

-- Добавить трек в плейлист
function MusicManager.addToPlaylist(url)
    if not url or url == "" then return end
    table.insert(State.musicPlaylist, url)
    NotificationManager.show("Added to playlist (#" .. #State.musicPlaylist .. ")", Color3.fromRGB(0, 255, 0))
end

-- Удалить трек из плейлиста
function MusicManager.removeFromPlaylist(index)
    if index >= 1 and index <= #State.musicPlaylist then
        table.remove(State.musicPlaylist, index)
        if State.musicCurrentIndex > #State.musicPlaylist then
            State.musicCurrentIndex = #State.musicPlaylist
        end
        NotificationManager.show("Removed from playlist", Color3.fromRGB(255, 150, 0))
    end
end

-- Проиграть трек по индексу
function MusicManager.playFromPlaylist(index)
    if #State.musicPlaylist == 0 then return end

    -- Зацикливание
    if index < 1 then index = #State.musicPlaylist end
    if index > #State.musicPlaylist then index = 1 end

    State.musicCurrentIndex = index

    -- Остановить текущий
    if State.musicPlayer then
        State.musicPlayer:Destroy()
        State.musicPlayer = nil
    end

    local url = State.musicPlaylist[index]
    local sound = Instance.new("Sound")
    sound.Name = "MusicPlayer"
    sound.SoundId = url
    sound.Volume = State.musicVolume
    sound.Looped = State.musicLoop
    sound.Parent = Services.SoundService
    sound:Play()

    State.musicPlayer = sound
    State.musicPlaying = true
    State.musicURL = url
end

-- Воспроизвести (основная функция)
function MusicManager.play(url)
    if #State.musicPlaylist == 0 and url and url ~= "" then
        MusicManager.addToPlaylist(url)
    end
    MusicManager.playFromPlaylist(State.musicCurrentIndex)
end

-- Остановить
function MusicManager.stop()
    if State.musicPlayer then
        State.musicPlayer:Destroy()
        State.musicPlayer = nil
    end
    State.musicPlaying = false
end

-- Пауза
function MusicManager.pause()
    if State.musicPlayer and State.musicPlaying then
        State.musicPlayer:Pause()
        State.musicPlaying = false
    end
end

-- Продолжить
function MusicManager.resume()
    if State.musicPlayer and not State.musicPlaying then
        State.musicPlayer:Resume()
        State.musicPlaying = true
    end
end

-- Следующий трек
function MusicManager.nextTrack()
    if #State.musicPlaylist == 0 then return end
    MusicManager.playFromPlaylist(State.musicCurrentIndex + 1)
end

-- Предыдущий трек
function MusicManager.prevTrack()
    if #State.musicPlaylist == 0 then return end
    MusicManager.playFromPlaylist(State.musicCurrentIndex - 1)
end

-- Переключить Loop
function MusicManager.toggleLoop()
    State.musicLoop = not State.musicLoop
    if State.musicPlayer then
        State.musicPlayer.Looped = State.musicLoop
    end
end

-- Обновить громкость
function MusicManager.updateVolume()
    if State.musicPlayer then
        State.musicPlayer.Volume = State.musicVolume
    end
end

print("[MusicManager] Loaded")
return MusicManager
