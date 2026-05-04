import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/features/seeker/constants/seeker_filter_values.dart';

void main() {
  group('SeekerFilterValues', () {
    test('employment type values match backend enums', () {
      expect(SeekerFilterValues.fullTime, 'full_time');
      expect(SeekerFilterValues.partTime, 'part_time');
      expect(SeekerFilterValues.contract, 'contract');
    });

    test('employmentTypes contains unique canonical values', () {
      expect(
        SeekerFilterValues.employmentTypes,
        equals(<String>['full_time', 'part_time', 'contract']),
      );
      expect(
        SeekerFilterValues.employmentTypes.toSet().length,
        SeekerFilterValues.employmentTypes.length,
      );
    });
  });
}
