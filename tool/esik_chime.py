"""Eşik'in bildirim sesi: eşikten geçen iki yumuşak çan notası.

Mi (E5) ve La (A5), dörtlü aralık: kapı zilinin tersine, yukarı doğru bir
adım. Her nota çan benzeri kısmi seslerden oluşur (biraz uyumsuz üst ses
çana sıcaklık verir), yumuşak başlar ve uzun söner.

    python3 tool/esik_chime.py out.wav
    ffmpeg -i out.wav -c:a libvorbis -q:a 6 android/app/src/main/res/raw/esik_chime.ogg
"""

import sys
import wave

import numpy as np

RATE = 48_000
LENGTH = 1.6  # saniye


def bell(freq: float, start: float, gain: float, decay: float) -> np.ndarray:
    t = np.arange(int(RATE * LENGTH)) / RATE - start
    on = t >= 0
    t = np.where(on, t, 0)
    # (oran, düzey, sönüm çarpanı): üst sesler daha çabuk söner.
    partials = [(1.0, 1.0, 1.0), (2.0, 0.28, 1.8), (3.01, 0.10, 2.6), (4.16, 0.05, 3.4)]
    tone = sum(
        level * np.sin(2 * np.pi * freq * ratio * t) * np.exp(-t * decay * speed)
        for ratio, level, speed in partials
    )
    attack = np.clip(t / 0.006, 0, 1)  # 6 ms: tık sesi olmasın
    return np.where(on, tone * attack * gain, 0)


def lowpass(x: np.ndarray, cutoff: float) -> np.ndarray:
    a = np.exp(-2 * np.pi * cutoff / RATE)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def main(path: str) -> None:
    e5, a5 = 659.26, 880.0
    x = bell(e5, 0.0, 0.8, 3.2) + bell(a5, 0.17, 1.0, 2.6)
    x += bell(a5 * 2, 0.17, 0.12, 4.0)  # ikinci notaya hafif parıltı
    x = lowpass(x, 5_500)
    fade = np.clip((LENGTH - np.arange(len(x)) / RATE) / 0.25, 0, 1)
    x *= fade
    x *= 0.89 / np.max(np.abs(x))  # -1 dBFS
    pcm = (x * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(pcm.tobytes())


if __name__ == "__main__":
    main(sys.argv[1])
