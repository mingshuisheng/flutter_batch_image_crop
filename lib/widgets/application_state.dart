import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class ApplicationStateProvider extends StatelessWidget {
  const ApplicationStateProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Provider.value(value: ApplicationState(), child: child);
  }
}

class ApplicationState {
  Rect clipRect = Rect.zero;
}
