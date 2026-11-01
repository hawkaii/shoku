"""Keeping a reel's cover forever.

Instagram and YouTube hand out signed CDN links — ``scontent.cdninstagram.com``
with an ``oe=`` expiry baked into the query — so a URL stored at extraction is
dead within hours. The Wall then shows a monogram for every reel that is not
brand new, which reads as broken rather than as a fallback.

So the cover is copied into our bucket **once, at extraction**, and the cache
stores the URL we own. Three consequences worth stating:

* one GET plus one PUT per import, never per read; nothing is proxied at
  request time (the API never serves image bytes);
* the key is the SHA-256 of the stored bytes, so copying the same cover twice
  overwrites one object instead of accumulating copies, and the URL can be
  cached hard;
* **a cover is never worth an import.** Every failure here — 404, timeout, a
  non-image body, a storage that is not configured — is logged and swallowed,
  and the caller keeps the platform URL. The client already draws a monogram
  for a missing image; a failed import is a lost recipe.

The image is downscaled to 720 px wide JPEG. That is 2× the card's width on a
phone (360 dp) and tall enough for the detail header, which is the two places
it is drawn; storing the 1080×1350 original would be roughly three times the
bytes for pixels no screen asks for.
"""

import hashlib
import logging
from io import BytesIO

import httpx

log = logging.getLogger("shoku.thumbnails")

#: 2× a 360 dp card, and enough for a detail header. See the module docstring.
THUMB_WIDTH = 720
#: A cover is a photo thumbnail, not a poster. Anything larger is not one.
MAX_SOURCE_BYTES = 8 * 1024 * 1024
_JPEG_QUALITY = 82


def thumb_key(shortcode: str, body: bytes) -> str:
    """``thumbs/<shortcode>/<sha256-prefix>.jpg`` — content addressed, so a
    re-copy of identical bytes is the same object."""
    digest = hashlib.sha256(body).hexdigest()[:16]
    return f"thumbs/{shortcode}/{digest}.jpg"


def card_sized(raw: bytes) -> bytes | None:
    """Downscale to a card-sized JPEG, or None if these bytes are not an image."""
    from PIL import Image, UnidentifiedImageError  # noqa: PLC0415 - optional at import time

    try:
        with Image.open(BytesIO(raw)) as image:
            image.load()
            if image.mode in ("RGBA", "LA", "P"):
                # Flatten transparency onto white rather than letting JPEG
                # render it black, which looks like a failed image.
                rgba = image.convert("RGBA")
                background = Image.new("RGB", rgba.size, (255, 255, 255))
                background.paste(rgba, mask=rgba.split()[-1])
                rgb = background
            else:
                rgb = image.convert("RGB")

            if rgb.width > THUMB_WIDTH:
                height = max(1, round(rgb.height * THUMB_WIDTH / rgb.width))
                rgb = rgb.resize((THUMB_WIDTH, height), Image.LANCZOS)

            out = BytesIO()
            rgb.save(out, "JPEG", quality=_JPEG_QUALITY, optimize=True, progressive=True)
            return out.getvalue()
    except UnidentifiedImageError:
        return None
    except Exception as exc:  # noqa: BLE001 - a broken cover is not a broken import
        log.warning("could not decode a cover image: %s", exc)
        return None


def stable_cover(
    storage,
    url: str | None,
    *,
    shortcode: str,
    timeout: float = 10.0,
) -> str | None:
    """Copy ``url`` into our storage and return its permanent URL.

    ``None`` means no copy was made — the caller keeps whatever it had.
    """
    if not url:
        return None

    try:
        response = httpx.get(url, timeout=timeout, follow_redirects=True)
        response.raise_for_status()
    except Exception as exc:  # noqa: BLE001 - an expired link is expected, not exceptional
        log.warning("cover for %s not downloaded (%s); keeping the platform URL", shortcode, exc)
        return None

    body = response.content
    if not body or len(body) > MAX_SOURCE_BYTES:
        log.warning(
            "cover for %s is %s bytes; keeping the platform URL", shortcode, len(body)
        )
        return None

    content_type = (response.headers.get("content-type") or "").split(";")[0].strip().lower()
    if content_type and not content_type.startswith("image/"):
        log.warning(
            "cover for %s is %r, not an image; keeping the platform URL",
            shortcode,
            content_type,
        )
        return None

    sized = card_sized(body)
    if sized is None:
        return None

    try:
        return storage.put(thumb_key(shortcode, sized), sized, content_type="image/jpeg")
    except Exception as exc:  # noqa: BLE001 - the import matters more than the picture
        log.warning("cover for %s not stored (%s); keeping the platform URL", shortcode, exc)
        return None
