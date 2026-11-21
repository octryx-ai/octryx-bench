# splitbill

Splits a bill among people, in whole cents.

```
python3 -m splitbill 10.00 3
3.34
3.33
3.33
```

Rules: amounts are handled in cents; the shares always add up to the total; any leftover cent goes to the first
people in the list, one cent each.

Tests: `python3 -m pytest -q` (unit tests and `tests/test_cli.py`, which runs the CLI end to end). No UI.
