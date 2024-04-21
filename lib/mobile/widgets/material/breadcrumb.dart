import 'package:flutter/material.dart';


class BreadCrumbItem {
  String text;
  Function callback;

  BreadCrumbItem({
    required this.text,
    required this.callback
  });
}

class BreadCrumbNavigator extends StatelessWidget {
  final List<BreadCrumbItem> items;

  BreadCrumbNavigator({
    required this.items
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.from(items
          .asMap()
          .map(
            (index, item) => MapEntry(
            index,
            GestureDetector(
                onTap: () {
                  item.callback();
                },
                child: _BreadButton(item.text, index == 0)
            )),
          )
          .values),
      mainAxisSize: MainAxisSize.max,
    );
  }
}

class _BreadButton extends StatelessWidget {
  final String text;
  final bool isFirstButton;

  _BreadButton(this.text, this.isFirstButton);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TriangleClipper(!isFirstButton),
      child: Container(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: isFirstButton ? 8 : 20,
              end: 28,
              top: 8,
              bottom: 8
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  final bool twoSideClip;

  _TriangleClipper(this.twoSideClip);

  @override
  Path getClip(Size size) {
    final Path path = new Path();
    if (twoSideClip) {
      path.moveTo(20, 0.0);
      path.lineTo(0.0, size.height / 2);
      path.lineTo(20, size.height);
    } else {
      path.lineTo(0, size.height);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - 20, size.height / 2);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
