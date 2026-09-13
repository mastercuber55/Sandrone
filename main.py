# Import Libraries
import json
import queue

import sounddevice as sd
import vosk

# Import Local Modules
import actions
import response as res

from config import MODEL_PATH, SAMPLE_RATE, BLOCK_SIZE

audio_queue = queue.Queue()


# Setting up voice recognition
model = vosk.Model(MODEL_PATH)

recognizer = vosk.KaldiRecognizer(
    model,
    SAMPLE_RATE,
    json.dumps(list(actions.commands.keys()))
)


# Audio
def audio_callback(indata, frames, time, status):

    if res.speaking:
        return

    # Convert from buffer to bytes for Vosk
    audio_queue.put(bytes(indata))


def create_microphone():
    return sd.RawInputStream(
        samplerate=SAMPLE_RATE,
        blocksize=BLOCK_SIZE,
        dtype="int16",
        channels=1,
        callback=audio_callback,
    )


def execute_command(text):
    for trigger, action in actions.commands.items():
        if trigger in text:
            print(f"Command: {trigger}")
            action()
            return


with create_microphone():
    res.respond("Sandrone at your service.")

    while True:
        data = audio_queue.get()

        if recognizer.AcceptWaveform(data):
            result = json.loads(recognizer.Result())
            text = result.get("text", "")

            if text:
                print(f"Heard: {text}")
                execute_command(text)

        else:
            partial = json.loads(recognizer.PartialResult()).get("partial", "")

            if partial:
                print(f"Heard: {partial}", end="\r")