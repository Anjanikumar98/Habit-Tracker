import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  String goalTitle = "Learn 5 new words";
  int completed = 5;
  int total = 7;
  double strength = 0.75;
  String repeat = "Every Day";
  String streak = "8 Days";
  String best = "11 Days";

  void editGoal() async {
    TextEditingController controller = TextEditingController(text: goalTitle);
    var result = await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xff1c1c2b),
            title: const Text(
              "Edit Goal",
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter new goal",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: const Text("Save"),
              ),
            ],
          ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => goalTitle = result.trim());
    }
  }

  Widget buildStatTile(String title, String value, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 17)),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void editStat(
    String label,
    String currentValue,
    Function(String) onSave,
  ) async {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    var result = await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xff1c1c2b),
            title: Text(
              "Edit $label",
              style: const TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter value",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: const Text("Save"),
              ),
            ],
          ),
    );
    if (result != null && result.trim().isNotEmpty) {
      onSave(result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff131b26),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 35.0),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goalTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 28,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: InkWell(
                            onTap: editGoal,
                            child: Icon(
                              Icons.edit,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Text(
                      "$completed from $total this week",
                      style: TextStyle(color: Colors.grey[500], fontSize: 18),
                    ),
                    const SizedBox(height: 11.0),
                    LinearProgressIndicator(
                      value: completed / total,
                      backgroundColor: const Color(0xff1c232d),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xff701bff),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      "Strength",
                      style: TextStyle(color: Colors.grey[500], fontSize: 20),
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${(strength * 100).toInt()}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        CircularProgressIndicator(
                          value: strength,
                          backgroundColor: Colors.grey[600],
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xff701bff),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(color: Colors.grey[500], height: 1.0),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildStatTile(
                          "Repeat",
                          repeat,
                          () => editStat(
                            "Repeat",
                            repeat,
                            (v) => setState(() => repeat = v),
                          ),
                        ),
                        buildStatTile(
                          "Streak",
                          streak,
                          () => editStat(
                            "Streak",
                            streak,
                            (v) => setState(() => streak = v),
                          ),
                        ),
                        buildStatTile(
                          "Best",
                          best,
                          () => editStat(
                            "Best",
                            best,
                            (v) => setState(() => best = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Transform.rotate(
                angle: 3.14,
                child: CustomPaint(
                  child: MyBezierCurve(),
                  painter: CurvePath(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvePath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    paint.color = Color(0xff701dff);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;

    var path = Path();

    path.moveTo(0, size.height * 0.50);
    path.quadraticBezierTo(
      size.width * 0.10,
      size.height * 0.80,
      size.width * 0.15,
      size.height * 0.60,
    );
    path.quadraticBezierTo(
      size.width * 0.20,
      size.height * 0.45,
      size.width * 0.27,
      size.height * 0.60,
    );
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height,
      size.width * 0.50,
      size.height * 0.80,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.93,
      size.width,
      size.height * 0.60,
    );

    path.moveTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyBezierCurve extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClippingClass(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff221b4c), Color(0xff151b2b)],
          ),
        ),
      ),
    );
  }
}

class ClippingClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height * 0.50);
    path.quadraticBezierTo(
      size.width * 0.10,
      size.height * 0.80,
      size.width * 0.15,
      size.height * 0.60,
    );

    path.quadraticBezierTo(
      size.width * 0.20,
      size.height * 0.45,
      size.width * 0.27,
      size.height * 0.60,
    );

    path.quadraticBezierTo(
      size.width * 0.45,
      size.height,
      size.width * 0.50,
      size.height * 0.80,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.93,
      size.width,
      size.height * 0.60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
