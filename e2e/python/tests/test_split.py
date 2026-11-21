import pytest

from splitbill import parse_amount, split


def test_parse_amount_in_cents():
    assert parse_amount("10.00") == 1000
    assert parse_amount("7.5") == 750
    assert parse_amount("3") == 300


@pytest.mark.parametrize("text", ["", "1.234", "a.10", "-1"])
def test_parse_amount_refuses_non_amounts(text):
    with pytest.raises(ValueError):
        parse_amount(text)


def test_an_even_total_splits_evenly():
    assert split(900, 3) == [300, 300, 300]


def test_one_person_pays_everything():
    assert split(1234, 1) == [1234]


def test_people_must_be_positive():
    with pytest.raises(ValueError):
        split(100, 0)
