

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_tracker/data/models/place.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../bloc/point/point_block.dart';
import '../../../bloc/point/point_event.dart';
import '../../../bloc/point/point_state.dart';
import '../../../data/mappers/photo_mapper.dart';
import '../../../data/models/user.dart';

class SlidingPanelBodyWidget extends StatefulWidget {
  final PointsLoadedState state;
  final PanelController panelController;
  final PanelController authPanelController;
   bool isPanelOpen;
   bool isDialogVisible;
  final User currentUser;
  final PointBloc pointBloc;

  SlidingPanelBodyWidget({
    required this.isDialogVisible,
    required this.isPanelOpen,
    required this.authPanelController,
    required this.state,
    required this.panelController,
    required this.currentUser,
    required this.pointBloc,
    Key? key,
  }) : super(key: key);

  @override
  _SlidingPanelWidgetState createState() => _SlidingPanelWidgetState();
}

class _SlidingPanelWidgetState extends State<SlidingPanelBodyWidget> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final point = widget.state.temporaryPoint ?? widget.state.selectedPoint;
    nameController = TextEditingController(text: point?.name ?? '');
    descriptionController = TextEditingController(text: point?.description ?? '');
  }

  @override
  void didUpdateWidget(covariant SlidingPanelBodyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPoint = widget.state.temporaryPoint ?? widget.state.selectedPoint;
    if (oldWidget.state.selectedPoint != widget.state.selectedPoint ||
        oldWidget.state.temporaryPoint != widget.state.temporaryPoint) {
      nameController.text = newPoint?.name ?? '';
      descriptionController.text = newPoint?.description ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
  final ImagePicker _picker = ImagePicker();


  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final temporaryPoint = state.temporaryPoint;
    final selectedPoint = state.selectedPoint;
    Place? point = temporaryPoint ?? selectedPoint;
    final isTemporary = temporaryPoint != null;
    int currentPage = 0;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Скрыть клавиатуру
        },
        child: Container(
          color: Colors.white,
          child: !widget.currentUser.isAuthorized
              ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            widget.authPanelController.open();
                           widget.panelController.close();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.grey.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Войти',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              : Stack(
            children: [
              if (point != null)
                StatefulBuilder(
                  builder: (context, setState) {
                    return GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (widget.panelController.isAttached &&
                            details.primaryVelocity! > 0) {
                          widget.panelController.close();
                        }
                      },
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context)
                                    .height *
                                    0.3,
                                width:
                                MediaQuery.sizeOf(context).width,
                                child: point!.photosMain.isEmpty
                                    ? const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 100,
                                  ),
                                )
                                    : PageView.builder(
                                  itemCount:
                                  point.photosMain.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      currentPage = index;
                                    });
                                  },
                                  itemBuilder:
                                      (context, index) {
                                    return point
                                        .photosMain[index]
                                        .isLocal()
                                        ? Image.file(
                                      File(point
                                          .photosMain[
                                      index]
                                          .filePath),
                                      fit: BoxFit.cover,
                                    )
                                        : Image.network(
                                      point
                                          .photosMain[
                                      index]
                                          .filePath,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                  visible:
                                  point.photosMain.isNotEmpty,
                                  child: Positioned(
                                    left: 16,
                                    bottom: 30,
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        setState(() {
                                          point.photosMain
                                              .removeAt(currentPage);
                                          currentPage = 0;
                                        });
                                      },
                                      mini: true,
                                      backgroundColor: Colors.white,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )),
                              Positioned(
                                bottom: 30,
                                left: 80,
                                right: 80,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: List.generate(
                                    point.photosMain.length ?? 0,
                                        (index) => AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      margin:
                                      const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: currentPage == index
                                          ? 12
                                          : 8,
                                      height: currentPage == index
                                          ? 12
                                          : 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: currentPage == index
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible:
                                  point.photosMain.length < 5,
                                  child: Positioned(
                                    right: 16,
                                    bottom: 30,
                                    child: FloatingActionButton(
                                      onPressed: () async {
                                        final pickedFile =
                                        await _picker
                                            .pickMultiImage();
                                        if (pickedFile.isNotEmpty) {
                                          if (pickedFile.length +
                                              point.photosMain
                                                  .length >
                                              5) {
                                            Fluttertoast.showToast(
                                              msg:
                                              "Можно добавить только 5 фотографий для одной точки",
                                              toastLength:
                                              Toast.LENGTH_SHORT,
                                              gravity:
                                              ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor:
                                              Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                          }
                                          setState(() {
                                            point.photosMain.addAll(
                                                PhotoMapper.fromXFiles(
                                                    pickedFile
                                                        .take(5 -
                                                        point
                                                            .photosMain
                                                            .length)
                                                        .toList()));
                                          });
                                        }
                                      },
                                      mini:
                                      true, // Smaller circular button
                                      backgroundColor: Colors.white,
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              transform: Matrix4.translationValues(
                                  0,
                                  -MediaQuery.sizeOf(context).height *
                                      0.01,
                                  0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
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
                                        hintText:
                                        'Добавьте название...',
                                        filled: true,
                                        fillColor:
                                        Colors.grey.shade100,
                                        contentPadding:
                                        const EdgeInsets.all(12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      minLines: 1,
                                      maxLines: 2,
                                      maxLength: 40,
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller:
                                      descriptionController,
                                      scrollPhysics:
                                      const NeverScrollableScrollPhysics(),
                                      decoration: InputDecoration(
                                        hintText:
                                        'Добавьте описание...',
                                        filled: true,
                                        fillColor:
                                        Colors.grey.shade100,
                                        contentPadding:
                                        EdgeInsets.all(12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      minLines: 1,
                                      maxLines: 9,
                                      maxLength: 750,
                                    ),
                                    const SizedBox(height: 16),
                                    Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        FloatingActionButton(
                                          backgroundColor:
                                          Colors.grey.shade400,
                                          elevation: 0,
                                          onPressed: () {
                                            if (isTemporary) {
                                              widget.pointBloc.add(
                                                  CancelTemporaryPointEvent());
                                            } else {
                                              print(
                                                  'selectedIndex:${state.selectedIndex}');

                                              print(
                                                  'idForDelete:${state.points[state.selectedIndex].id}');
                                              print(
                                                  'nameForDelete:${state.points[state.selectedIndex].name}');
                                              print(
                                                  'temporForDelete:${state.points[state.selectedIndex].isPointTemporay}');
                                              print(
                                                  'selForDelete:${state.points[state.selectedIndex].isSelected}');
                                              widget.pointBloc.add(RemovePointEvent(
                                                  selectedIndex: state
                                                      .selectedIndex,
                                                  jwt: widget.currentUser
                                                      .jwt));
                                            }
                                            widget.panelController.close();
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.black,
                                            size: 25,
                                          ),
                                        ),
                                        FloatingActionButton(
                                          backgroundColor:
                                          Colors.grey.shade400,
                                          elevation: 0,
                                          onPressed: () {
                                            if (nameController.text
                                                .trim() ==
                                                '') {
                                              Fluttertoast.showToast(
                                                msg:
                                                "Необходимо добавить название точки",
                                                toastLength: Toast
                                                    .LENGTH_SHORT,
                                                gravity: ToastGravity
                                                    .BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor:
                                                Colors.black,
                                                textColor:
                                                Colors.white,
                                                fontSize: 16.0,
                                              );
                                            } else {
                                              if (isTemporary) {
                                                widget.pointBloc.add(SaveTemporaryPointEvent(
                                                    point!.copyWith(
                                                        name:
                                                        nameController
                                                            .text,
                                                        description:
                                                        descriptionController
                                                            .text,
                                                        photosMain: point
                                                            .photosMain),
                                                    widget.currentUser));
                                              } else {
                                                widget.pointBloc.add(
                                                  UpdatePointEvent(
                                                      point.copyWith(
                                                          name: nameController
                                                              .text,
                                                          description:
                                                          descriptionController
                                                              .text,
                                                          photosMain:
                                                          point
                                                              .photosMain),
                                                      widget.currentUser),
                                                );
                                              }
                                              widget.panelController
                                                  .close();
                                            }
                                          },
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.black87,
                                            size: 35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                SizedBox.shrink(),
              Visibility(
                  visible: !widget.isPanelOpen && isTemporary,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.2,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25)),
                    ),
                    child: Center(
                      child: FloatingActionButton(
                          elevation: 0,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(
                            Icons.add,
                            color: Colors.black45,
                            size: 35,
                          ),
                          onPressed: () {
                            setState(() {
                             widget.isPanelOpen = true;
                             widget.isDialogVisible = false;
                            });
                            widget.panelController.open();
                            //   _panelController.open();
                          }),
                    ),
                  )),
              Container(
                width: double.infinity,
                height: 40,
                child: Center(
                  child: Container(
                    width: 50,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
