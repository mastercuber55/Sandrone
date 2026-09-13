# Sandrone
A lightweight, local voice assistant for Linux.

## Project Structure

```text
Sandrone/
│
├── main.py                 # Core assistant loop
├── actions.py              # Voice command actions
├── response.py             # Notifications & spoken responses
├── config.py               # Configuration File
├── start.sh                # Launch script
│
├── models/
│   ├── piper/              # Piper TTS voice models
│   └── vosk-model/			# Vosk speech recognition model
│                              
│
├── piper/                  # Piper TTS executable
├── icon.jpg                # Sandrone icon for notification
├── voice_cache/            # Cached generated speech
│
└── README.md
```

## Installation

```sh
git clone https://github.com/mastercuber55/Sandrone.git
cd Sandrone
./install.sh
```

## Customizing Actions
NOTE: Sandrone is designed to be personally customized. You SHOULD add your own voice commands to `actions.py` to do anything possible on your system. However, it is recommended to not add deadly operations to Sandrone and also not use it for things such as system Shutdown, system Restart, etc because the speech recognization is not 100% accurate.

While Sandrone can be used for simple tasks, the beauty of Sandrone is in configuring actions that take multiple steps.

### Pre-installed Actions
```py
commands = {
    
    "hello sandro ne": lambda: res.respond("Hey, Sandrone at your service."),
    "sandro ne show commands": show_commands,

    "sandro ne shut down": shutdown,
    "sandro ne restart": restart,

    "sandro ne start recording": start_recording,
    "sandro ne stop recording": stop_recording,

    "sandro ne show system status": show_system_status,
    "sandro ne show storage usage": show_storage_usage,

    "sandro ne open gem shin impact": open_genshin_impact
}
```

As you may observe, for non existant "words", accuracy can never be met, so you have to adjust words such that it will work. eg. genshin -> gem shin, sandrone -> sandro ne.

For every command that you setup, make sure to add a function to it, whether it be lambda or normal.

### Creating Action

```py
# Add to actions.py
def open_terminal(): 
	run("alacritty")

# add to commands dictionary in actions.py
"sandro ne open terminal": open_terminal
```

### Making Sandrone respond
```py
res.speak("Opening terminal") # Voice only
res.notify("Opening terminal") # Notification only
res.respond("Opening terminal") # Both
```

NOTE: Voice replies are cached so it is recommended not to use voice lines for replies that change.
eg. showing disk usage, telling time, etc. res.notify is better for such cases.

### Making Sandrone specific to your system
If Sandrone is missing some shell commands, adjust it according to your desktop.
eg. i have used alacritty all over but you may be using kitty or gnome terminal.