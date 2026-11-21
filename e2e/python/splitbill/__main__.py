"""CLI: python -m splitbill <total> <people>"""

from __future__ import annotations

import sys

from .split import format_cents, parse_amount, split


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("usage: python -m splitbill <total> <people>", file=sys.stderr)
        return 2
    try:
        shares = split(parse_amount(argv[0]), int(argv[1]))
    except ValueError as error:
        print(f"error: {error}", file=sys.stderr)
        return 2
    for share in shares:
        print(format_cents(share))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
