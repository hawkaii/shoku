"""Which language the assistant answers in.

The app ships ten locales. The model is told the language **by name**, because a
tag like ``pt-BR`` means nothing to it while "Portuguese" does, and because the
instruction has to survive being put in front of a prompt that is otherwise
English.

Precedence is deliberate: a ``locale`` in the body wins over ``Accept-Language``,
and an unknown tag falls back to English rather than to whatever the header said
— a client that explicitly asks for a language we do not ship should get the
default, not a guess from a proxy's header.
"""

#: The shipped locales, by tag. Adding one here is the whole change: the model
#: is told the name, and nothing else knows the list.
LOCALES: dict[str, str] = {
    "en": "English",
    "es": "Spanish",
    "fr": "French",
    "pt": "Portuguese",
    "id": "Indonesian",
    "hi": "Hindi",
    "mr": "Marathi",
    "bn": "Bengali",
    "ta": "Tamil",
    "te": "Telugu",
}

DEFAULT = "English"


def tag(value: str | None) -> str | None:
    """``es-MX,es;q=0.9`` → ``es``; ``pt_BR`` → ``pt``."""
    if not value:
        return None
    first = value.split(",")[0].split(";")[0].strip()
    if not first:
        return None
    return first.lower().replace("_", "-").split("-")[0] or None


def from_header(accept_language: str | None) -> str | None:
    """The language the client's ``Accept-Language`` asks for, if we ship it."""
    return LOCALES.get(tag(accept_language) or "")


def resolve(*, body_locale: str | None, accept_language: str | None) -> str:
    """The language name to put in front of the prompt.

    The body wins when it carries a locale, even an unknown one: an explicit
    request is not overridden by a header some proxy added.
    """
    if body_locale:
        return LOCALES.get(tag(body_locale) or "", DEFAULT)
    return from_header(accept_language) or DEFAULT
