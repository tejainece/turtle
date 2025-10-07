abstract class Node<O, I> {
  // TODO implement inputs and outputs
  Future<O> process(I input);
}

class DrawRectangleInput {
  final double x;
  final double y;
  final double width;
  final double height;
  final String color;

  DrawRectangleInput({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
  });
}

class DrawRectangleNode implements Node {
  Future<void> process() async {
    // TODO
  }
}
