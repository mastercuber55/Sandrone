import subprocess
import hashlib
from pathlib import Path
import os

from config import PIPER_EXE, PIPER_MODEL

speaking = False

def filename_from_text(text: str):
	return hashlib.sha256(text.encode()).hexdigest() + ".wav"

def speak(text: str):
	global speaking

	speaking = True

	fileName = filename_from_text(text)
	filePath = "voice_cache/" + fileName
	file = Path(filePath)

	text = text.replace("Sandrone", "Sandronay")

	if not file.exists():
		subprocess.run([
		    PIPER_EXE,
		    "--model", PIPER_MODEL,
		    "--output-file", filePath,
		    "--length_scale", "0.9"
		], input=text.encode("utf-8"))

	subprocess.run(["aplay", filePath])

	speaking = False

def notify(text: str):
	subprocess.run(["notify-send", "Sandrone", text, "-i", os.path.abspath("./icon.jpg")])

def respond(text: str):
	notify(text)
	speak(text)