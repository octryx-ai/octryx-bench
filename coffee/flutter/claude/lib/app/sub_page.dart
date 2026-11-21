import 'package:material_ui/material_ui.dart';

import '../core/widgets/coming_soon.dart';
import '../core/widgets/page_body.dart';

/// Pushed detail, form or focus page of a later story: back button, title and
/// the "Coming soon" notice. Has no navigation bar.
class SubPage extends StatelessWidget {
  /// Creates the page.
  const SubPage({required this.title, super.key});

  /// Screen title.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PageBody(children: [ComingSoon(title: title)]),
    );
  }
}
