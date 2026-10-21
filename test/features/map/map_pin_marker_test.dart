import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon_finder/core/theme/app_colors.dart';
import 'package:pigeon_finder/features/map/presentation/widgets/map_pin_marker.dart';

void main() {
  test('pin ring goes from teal to amber to red as the post expires', () {
    expect(freshnessColor(1), AppColors.iridescent);
    expect(freshnessColor(.5), AppColors.grain);
    expect(freshnessColor(0), AppColors.pin);
    expect(freshnessColor(2), freshnessColor(1));
    expect(freshnessColor(.75), isNot(equals(freshnessColor(.25))));
  });
}
