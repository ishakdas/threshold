"""Play Store görselleri: ham ekranları (tool/store_assets_test.dart)
telefon çerçevesine koyup başlık ekler.

    flutter test tool/store_assets_test.dart --update-goldens
    python3 tool/store_marketing.py

Çıktı: docs/play/gorseller/<dil>/1..6.png (1080×1920) ve
docs/play/gorseller/<dil>/one-cikan-1024x500.png.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "build" / "store_raw"
OUT = ROOT / "docs" / "play" / "gorseller"
FONTS = ROOT / "assets" / "fonts"

W, H = 1080, 1920

EVENING = {
    "bg": [(0x15, 0x1B, 0x3E), (0x0B, 0x10, 0x29), (0x06, 0x0A, 0x1A)],
    "glow": (0xFF, 0xB2, 0x5C),
    "text": (0xF5, 0xEF, 0xE6),
    "muted": (0xF5, 0xEF, 0xE6, 0xB8),
    "bezel": (0x05, 0x07, 0x12),
}
MORNING = {
    "bg": [(0xFB, 0xE6, 0xCE), (0xF7, 0xEE, 0xE3), (0xF3, 0xEC, 0xE2)],
    "glow": (0xFF, 0xAA, 0x5A),
    "text": (0x2B, 0x1D, 0x12),
    "muted": (0x2B, 0x1D, 0x12, 0xC0),
    "bezel": (0x1C, 0x14, 0x0E),
}

SCREENS = [
    ("1-bildirim", EVENING),
    ("2-aksam", EVENING),
    ("3-kontrol", EVENING),
    ("4-tetikleyiciler", EVENING),
    ("5-sabah", MORNING),
    ("6-gecmis", MORNING),
]

TEXTS = {
    "tr": [
        ("Doğru anda hatırlatır", "Telefonu şarja takınca kontrol listen önüne gelir."),
        ("Yatmadan önce, tek bakış", "Ütü, ocak, kapı… Akşam eşiğin hazır."),
        ("Tek dokunuşla tamam", "Maddeleri işaretle ya da bildirimden “Hepsi tamam” de."),
        ("Saat değil, an", "Şarj, alarm, sessiz mod, Wi‑Fi, NFC: hangisi önce olursa."),
        ("Evden çıkmadan önce", "Alarmı kapatınca sabah listen önünde."),
        ("Her gün eşiği geç", "Hangi akşam ve sabah kontrol ettiğini gör."),
    ],
    "en": [
        ("Reminds you at the right moment", "Plug in your phone and your checklist appears."),
        ("Before bed, one glance", "Iron, stove, door… Your evening check is ready."),
        ("Done in one tap", "Tick items off, or say “All done” from the notification."),
        ("Not a time, a moment", "Charging, alarm, silent mode, Wi‑Fi, NFC: whichever comes first."),
        ("Before you head out", "Stop your alarm and your morning list is there."),
        ("Cross the threshold daily", "See which evenings and mornings you checked."),
    ],
    "es": [
        ("Te avisa en el momento justo", "Pon el móvil a cargar y aparece tu lista."),
        ("Antes de dormir, un vistazo", "Plancha, fuegos, puerta… Tu revisión nocturna, lista."),
        ("Listo con un toque", "Marca cada punto o di «Todo listo» desde la notificación."),
        ("No una hora, un momento", "Carga, alarma, modo silencio, Wi‑Fi, NFC: lo que ocurra primero."),
        ("Antes de salir de casa", "Apaga la alarma y tu lista de la mañana está ahí."),
        ("Cruza el umbral cada día", "Mira qué noches y mañanas revisaste."),
    ],
}

FEATURE = {
    "tr": ("Eşik", "Yatmadan ve evden çıkmadan önce,\ndoğru anda kontrol et."),
    "en": ("Eşik", "Check before bed and before you leave,\nright at the moment."),
    "es": ("Eşik", "Revisa antes de dormir y antes de salir,\njusto en el momento."),
}


def font(weight, size):
    return ImageFont.truetype(str(FONTS / f"Inter-{weight}.ttf"), size)


def gradient(size, stops):
    w, h = size
    img = Image.new("RGB", (1, len(stops)))
    for i, c in enumerate(stops):
        img.putpixel((0, i), c)
    return img.resize((w, h), Image.BICUBIC)


def glow(canvas, center, radius, color, alpha):
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    cx, cy = center
    d.ellipse((cx - radius, cy - radius, cx + radius, cy + radius), fill=(*color, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(radius * 0.55))
    canvas.alpha_composite(layer)


def wrap(draw, text, fnt, max_w):
    words, lines, line = text.split(), [], ""
    for word in words:
        trial = f"{line} {word}".strip()
        if draw.textlength(trial, font=fnt) <= max_w:
            line = trial
        else:
            lines.append(line)
            line = word
    lines.append(line)
    return lines


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius, fill=255)
    return mask


def status_bar(screen, theme):
    """Ham ekranın üst boşluğuna sade bir durum çubuğu çizer."""
    d = ImageDraw.Draw(screen)
    color = theme["text"]
    s = screen.width / 393
    f = font("SemiBold", int(15 * s))
    d.text((int(30 * s), int(17 * s)), "22:47" if theme is EVENING else "07:24", font=f, fill=color)
    # pil
    x, y = screen.width - int(58 * s), int(19 * s)
    d.rounded_rectangle((x, y, x + int(25 * s), y + int(12 * s)), int(3.5 * s), outline=color, width=max(2, int(1.3 * s)))
    d.rounded_rectangle((x + int(2.5 * s), y + int(2.5 * s), x + int(19 * s), y + int(9.5 * s)), int(2 * s), fill=color)
    d.rectangle((x + int(26 * s), y + int(4 * s), x + int(28 * s), y + int(8 * s)), fill=color)
    # sinyal
    bx = x - int(30 * s)
    for i in range(4):
        hgt = int((4 + i * 2.6) * s)
        d.rounded_rectangle(
            (bx + i * int(5 * s), y + int(12 * s) - hgt, bx + i * int(5 * s) + int(3.2 * s), y + int(12 * s)),
            int(1 * s),
            fill=color,
        )


def phone(raw_path, theme, width):
    screen = Image.open(raw_path).convert("RGBA")
    status_bar(screen, theme)
    sw = width - 2 * int(width * 0.035)
    sh = round(screen.height * sw / screen.width)
    screen = screen.resize((sw, sh), Image.LANCZOS)
    bezel = (width - sw) // 2
    pw, ph = width, sh + 2 * bezel
    outer_r = int(width * 0.13)
    inner_r = outer_r - bezel

    body = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle((0, 0, pw - 1, ph - 1), outer_r, fill=(*theme["bezel"], 255))
    # ince kenar parlaması
    ImageDraw.Draw(body).rounded_rectangle(
        (1, 1, pw - 2, ph - 2), outer_r, outline=(255, 255, 255, 40), width=3
    )
    body.paste(screen, (bezel, bezel), rounded_mask((sw, sh), inner_r))
    # ön kamera
    cx, cy, r = pw // 2, bezel + int(sw * 0.045), int(sw * 0.018)
    ImageDraw.Draw(body).ellipse((cx - r, cy - r, cx + r, cy + r), fill=(0, 0, 0, 255))
    return body


def shadowed(canvas, img, pos, blur=40, alpha=150, dy=30):
    sh = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    mask = img.split()[3].point(lambda a: alpha if a else 0)
    sh.paste((0, 0, 0, 255), (pos[0], pos[1] + dy), mask)
    canvas.alpha_composite(sh.filter(ImageFilter.GaussianBlur(blur)))
    canvas.alpha_composite(img, pos)


def screenshot(lang, index):
    name, theme = SCREENS[index]
    title, sub = TEXTS[lang][index]
    canvas = gradient((W, H), theme["bg"]).convert("RGBA")
    glow(canvas, (W // 2, 330), 520, theme["glow"], 110 if theme is EVENING else 150)
    glow(canvas, (W // 2, H + 120), 600, theme["glow"], 60)

    d = ImageDraw.Draw(canvas)
    tf = font("SemiBold", 70)
    while d.textlength(title, font=tf) > W - 120 and tf.size > 50:
        tf = font("SemiBold", tf.size - 2)
    y = 120
    for line in wrap(d, title, tf, W - 120):
        d.text((W // 2, y), line, font=tf, fill=theme["text"], anchor="ma")
        y += int(tf.size * 1.18)
    y += 18
    sf = font("Regular", 38)
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    for line in wrap(d, sub, sf, W - 170):
        od.text((W // 2, y), line, font=sf, fill=theme["muted"], anchor="ma")
        y += int(sf.size * 1.32)
    canvas.alpha_composite(overlay)

    top = max(y + 60, 430)
    body = phone(RAW / lang / f"{name}.png", theme, 760)
    shadowed(canvas, body, ((W - body.width) // 2, top))
    return canvas.convert("RGB")


def feature(lang):
    fw, fh = 1024, 500
    canvas = gradient((fw, fh), EVENING["bg"]).convert("RGBA")
    glow(canvas, (300, 120), 330, EVENING["glow"], 120)
    glow(canvas, (780, 520), 300, MORNING["glow"], 70)

    title, sub = FEATURE[lang]
    d = ImageDraw.Draw(canvas)
    d.text((70, 150), title, font=font("SemiBold", 104), fill=EVENING["text"])
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(overlay).multiline_text(
        (74, 290), sub, font=font("Regular", 27), fill=EVENING["muted"], spacing=12
    )
    canvas.alpha_composite(overlay)

    # Akşam ve sabah ekranları, alttan taşarak.
    for name, theme, x, y in [("2-aksam", EVENING, 610, 70), ("5-sabah", MORNING, 810, 120)]:
        body = phone(RAW / lang / f"{name}.png", theme, 200)
        shadowed(canvas, body, (x, y), blur=18, alpha=170, dy=12)
    return canvas.convert("RGB")


def main():
    for lang in TEXTS:
        out = OUT / lang
        out.mkdir(parents=True, exist_ok=True)
        for i in range(len(SCREENS)):
            screenshot(lang, i).save(out / f"{i + 1}.png", optimize=True)
        feature(lang).save(out / "one-cikan-1024x500.png", optimize=True)
        print(f"{lang}: {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
