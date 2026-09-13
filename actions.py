from datetime import datetime
import subprocess
import os
import random

import response as res

def run(command):
    subprocess.Popen(command, shell=True)

def shutdown():
    res.respond("Farewell, shutting down")
    exit()

def restart():
    res.respond("Restarting.")
    subprocess.Popen(
        "~/Projects/Sandrone/start.sh",
        shell=True
    )
    raise SystemExit

def start_recording():
    if subprocess.run(["pgrep", "-x", "wf-recorder"]).returncode == 0:
        res.notify("A recording is already in progress.")
        return

    filename = datetime.now().strftime(
        "~/Videos/Sandrone/recording-%Y-%m-%d_%H-%M-%S.mp4"
    )

    res.notify("Starting recording.")
    run(f"mkdir -p ~/Videos/Sandrone && wf-recorder -f {filename} -a Combined.monitor")

def stop_recording():
    run("pkill wf-recorder")
    res.respond("Stopping recording.")

def show_system_status():
    run("alacritty -e btop")
    res.speak("Showing System Status")

def show_storage_usage():
    run("alacritty -e sudo ncdu /")
    res.respond("I need Administrator access to scan entire filesystem")

def show_commands():
    command_list = "\n".join(
        f"  • {command}"
        for command in commands.keys()
    )

    with open("/tmp/sandrone-commands.txt", "w") as file:
        file.write("╔════════════════════════════╗\n")
        file.write("║      SANDRONE COMMANDS     ║\n")
        file.write("╚════════════════════════════╝\n\n")
        file.write(command_list)
        file.write("\n\nPress q to close.\n")

    run("alacritty -e less /tmp/sandrone-commands.txt")

def open_genshin_impact():
    run("xdg-open https://play.geforcenow.com/mall/#/deeplink?game-id=64cc9e92-6ad6-49b9-a335-8a579ba7b434") 
    res.respond("Opening Genshin Impact")

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