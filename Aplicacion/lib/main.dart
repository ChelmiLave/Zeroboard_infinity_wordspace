import 'dart:typed_data';
import 'dart:ui';

const editorChannel = 'zeroboard/editor';

void main() {
  final dispatcher = PlatformDispatcher.instance;
  dispatcher.onBeginFrame = (_) {
    final view = dispatcher.implicitView;
    if (view == null) return;
    final builder = SceneBuilder();
    final scene = builder.build();
    view.render(scene);
    scene.dispose();
  };
  dispatcher.onMetricsChanged = dispatcher.scheduleFrame;
  dispatcher.scheduleFrame();
  dispatcher.sendPlatformMessage(editorChannel, ByteData(0), null);
}
