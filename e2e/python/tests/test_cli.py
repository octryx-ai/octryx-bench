"""End-to-end check of the CLI: runs `python -m splitbill` as a user would and checks its output.

splitbill is a command-line app without a UI, so this check is part of the unit test run (not a system test, which
the platform reads as a UI it must serve)."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

APP = Path(__file__).resolve().parents[1]


@pytest.mark.parametrize("args, expected, code", [(["9.00", "3"], ["3.00", "3.00", "3.00"], 0), (["abc", "2"], [], 2)])
def test_the_cli_prints_one_share_per_line(args, expected, code):
    done = subprocess.run([sys.executable, "-m", "splitbill", *args], cwd=APP, capture_output=True, text=True)
    assert done.returncode == code and done.stdout.split() == expected
