local Services = {}
Services.Players = game:GetService("Players")
Services.UserInputService = game:GetService("UserInputService")
Services.RunService = game:GetService("RunService")
Services.TweenService = game:GetService("TweenService")
Services.Lighting = game:GetService("Lighting")
Services.StarterGui = game:GetService("StarterGui")
Services.SoundService = game:GetService("SoundService")
Services.PathfindingService = game:GetService("PathfindingService")
Services.HttpService = game:GetService("HttpService")
Services.VirtualInputManager = game:GetService("VirtualInputManager")
Services.TextChatService = game:GetService("TextChatService")
Services.player = Services.Players.LocalPlayer
Services.camera = workspace.CurrentCamera
Services.mouse = Services.player:GetMouse()
Services.playerGui = Services.player:WaitForChild("PlayerGui")
_G.Experiment17.isMobile = Services.UserInputService.TouchEnabled
print("[Services] OK")
return Services
