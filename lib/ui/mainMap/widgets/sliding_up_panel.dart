import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class sliding_up_panel extends StatefulWidget {
  sliding_up_panel({super.key,  required this.controller});

  PanelController controller = new PanelController();
  @override
  State<sliding_up_panel> createState() => _sliding_up_panelState();
}

class _sliding_up_panelState extends State<sliding_up_panel> {

  @override
  Widget build(BuildContext context) {

    TextEditingController nameController = TextEditingController();
    TextEditingController emailContoller = TextEditingController();
    TextEditingController passwordContoller = TextEditingController();



    return SlidingUpPanel(
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      minHeight: 0,
      controller: widget.controller,
      defaultPanelState: PanelState.CLOSED,
      backdropEnabled: true,
      panel: Container(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Добавьте название...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              minLines: 1,
              maxLines: 2,
              maxLength: 40,
            ),
            TextField(
              decoration: InputDecoration(
                  fillColor: Colors.green,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(width: 10),
                      borderRadius: BorderRadius.circular(10))),
            )
          ],
        ),
      )),
      /* collapsed: Container(
                color: Color.fromARGB(255, 240, 240, 240),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Center(child: Icon(Icons.open_in_full)),
                    ),
                    Center(child: Text("test")),
                  ],
                ),
              ),*/
      border: Border.all(width: 0, color: Color.fromARGB(255, 240, 240, 240)),
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(20), topLeft: Radius.circular(20)),
    );
  }
}
