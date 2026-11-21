"""splitbill: split a bill among people in whole cents."""

from .split import parse_amount, split

__all__ = ["parse_amount", "split"]
