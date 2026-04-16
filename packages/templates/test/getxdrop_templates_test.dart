import 'package:getxdrop_templates/getxdrop_templates.dart';
import 'package:test/test.dart';

void main() {
  test('placeholder scaffold input contract is available', () {
    const input = ScaffoldGenerationInput(
      projectRoot: '/repo',
      featureModules: <String>['catalog'],
    );

    expect(input.featureModules.single, 'catalog');
  });
}
