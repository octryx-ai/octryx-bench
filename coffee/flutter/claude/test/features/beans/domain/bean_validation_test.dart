import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_field_error.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_validation.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';

void main() {
  test('name', () {
    expect(BeanValidation.validateName('  '), BeanFieldError.nameRequired);
    expect(BeanValidation.validateName('a' * 60), isNull);
    expect(
      BeanValidation.validateName(' ${'a' * 61} '),
      BeanFieldError.nameTooLong,
    );
    expect(BeanValidation.validateName(' ${'a' * 60} '), isNull);
  });

  test('size', () {
    expect(BeanValidation.validateSizeG(null), BeanFieldError.sizeRequired);
    expect(BeanValidation.validateSizeG(49), BeanFieldError.sizeOutOfRange);
    expect(BeanValidation.validateSizeG(50), isNull);
    expect(BeanValidation.validateSizeG(5000), isNull);
    expect(BeanValidation.validateSizeG(5001), BeanFieldError.sizeOutOfRange);
  });

  test('lead time and min stock', () {
    expect(BeanValidation.validateLeadTime(null), isNotNull);
    expect(BeanValidation.validateLeadTime(-1), isNotNull);
    expect(BeanValidation.validateLeadTime(0), isNull);
    expect(BeanValidation.validateLeadTime(60), isNull);
    expect(BeanValidation.validateLeadTime(61), isNotNull);
    expect(BeanValidation.validateMinStock(null), isNull);
    expect(BeanValidation.validateMinStock(0), isNull);
    expect(BeanValidation.validateMinStock(5000), isNull);
    expect(BeanValidation.validateMinStock(-1), isNotNull);
    expect(BeanValidation.validateMinStock(5001), isNotNull);
  });

  test('roast date', () {
    final today = DateTime(2026, 11, 16, 10);
    expect(BeanValidation.validateRoastDate(null, today), isNotNull);
    expect(
      BeanValidation.validateRoastDate(DateTime(2026, 11, 16), today),
      isNull,
    );
    expect(
      BeanValidation.validateRoastDate(DateTime(2026, 11, 17), today),
      BeanFieldError.roastDateInFuture,
    );
  });

  test('roast level codes', () {
    for (final l in RoastLevel.values) {
      expect(RoastLevel.parse(l.code), l);
    }
    expect(() => RoastLevel.parse('x'), throwsFormatException);
  });
}
