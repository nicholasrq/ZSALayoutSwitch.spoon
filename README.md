This spoon allows you to sync current Input Source with one of the layers on your ZSA keyboard.

# So, what it does

- Detects when keyboard is physically connected/disconnected
- Automatically connects to the keyboard
- Syncs uses current input source to activate a specific layer
- Sync happens on USB connection and on init (if you reload Hammerspoon config)

# Requirements

- [Keymapp](https://www.zsa.io/flash) 1.3+
- [Kontroll](https://github.com/zsa/kontroll)
- Keyboard that supports Kontroll (Voyager, Moonlander)

# Installation

- Download [ZSALayoutSwitch.spoon](https://github.com/nicholasrq/ZSALayoutSwitch.spoon) from the latest release
- Extract the archive
- Double-click the ZSALayoutSwitch

Open latest release, download the \`ZSALayoutSwitch.spoon.zip\`, extract and double click to install.

# How to use

I have my QWERTY layer at 0 index, and Colemak at 1, so my config will be this:

```lua
    hs.loadSpoon("ZSALayoutSwitch")
    
    -- By default, it will look for Voyager, if you're using Moonlander, uncomment this:
    -- spoon.ZSALayoutSwitch:set_keyboard("Moonlander")
    
    spoon.ZSALayoutSwitch:set_layers({
        ["com.apple.keylayout.RussianWin"] = { layer = 0, title = "QWERTY" },
        ["com.apple.keylayout.US"] = { layer = 1, title = "Colemak DH" },
    })
    
    spoon.ZSALayoutSwitch:start()
```

On start, the Spoon will launch input source watcher and usb watcher + will get current input source and switch your keyboard to specified layer.

After that, layer will switch when input source changes. When you disconnect the keyboard, Spoon will shut down Keymapp. When connected back, it will launch Keymapp, connect to the keyboard and switch to the layer for the current input source.

To find what input sources you have and their respective bundle IDs, run the following commando in your terminal:

```
`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleEnabledInputSources`
```
