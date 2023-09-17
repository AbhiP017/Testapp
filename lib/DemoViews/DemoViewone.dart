import 'package:flutter/material.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);



class ListViewTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: MyWidget(),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Demo();
  }
}

/// ListView initial animation.
class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> with TickerProviderStateMixin {
  late List<String> data;
  final Map<String, AnimationController> animations = {};

  @override
  void initState() {
    super.initState();
    data = [
      "Afghanistan",
      "Albania",
      "Algeria",
      "Andorra",
      "Angola",
      "Antigua",
      "Argentina",
      "Armenia",
      "Australia",
      "Austria",
      "Azerbaijan",
      "Bahamas",
      "Bahrain",
      "Bangladesh",
      "Barbados",
      "Belarus",
      "Belgium",
      "Belize",
      "Benin",
      "Bhutan",
      "Bolivia",
      "Bosnia",
      "Botswana",
      "Brazil",
      "Brunei",
      "Bulgaria",
      "Burkina",
      "Burundi"
    ];
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      // Create an AnimationController for each item.
      AnimationController _controller = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 250));
      animations[item] = _controller;
      // Add delay for initial animation.
      Future.delayed(Duration(milliseconds: i * 50), () {
        _controller.forward().then((_) {
          // Animation finished, clean up the controller.
          animations.remove(item)!.dispose();
          if (mounted) {
            setState(() {});
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return _AnimatedItem(item, animation: animations[item]);
          }),
    );
  }
}

class _AnimatedItem extends StatelessWidget {
  final String data;
  final Animation<double>? animation;
  const _AnimatedItem(this.data, {this.animation});
  @override
  Widget build(BuildContext context) {
    Widget result = Container(
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(data),
    );
    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: result,
      );
    }
    return result;
  }
}
