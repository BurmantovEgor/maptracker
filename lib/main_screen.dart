import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Text(counter.toString()),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    counter++;
                  });
                },
                child: Text("data")),
            ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                          padding: EdgeInsets.all(20),
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder()),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder()),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              counter++;
                                            });
                                          },
                                          child: Text("data")),
                                      FloatingActionButton(
                                          onPressed: () {
                                            setState(() {
                                              counter++;
                                            });
                                          },
                                          child: Text("+")),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Text(counter.toString())
                                    ],
                                  )
                                ],
                              )));
                    },
                  );
                },
                child: Text(
                  "Нижнее меню",
                ))
          ],
        ),
      )),
    );
  }
}
