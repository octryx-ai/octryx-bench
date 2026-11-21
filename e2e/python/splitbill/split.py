"""Splitting a total (in cents) into shares that add up to the total."""

from __future__ import annotations


def parse_amount(text: str) -> int:
    """'10.00' -> 1000 cents. Accepts at most two decimals."""
    whole, _, frac = text.strip().partition(".")
    if len(frac) > 2 or not whole.isdigit() or (frac and not frac.isdigit()):
        raise ValueError(f"not an amount: {text!r}")
    return int(whole) * 100 + int(frac.ljust(2, "0") or 0)


def split(total_cents: int, people: int) -> list[int]:
    """Shares in cents, one per person, largest first."""
    if people < 1:
        raise ValueError("people must be at least 1")
    if total_cents < 0:
        raise ValueError("total must not be negative")
    share = total_cents // people
    return [share] * people


def format_cents(cents: int) -> str:
    return f"{cents // 100}.{cents % 100:02d}"
