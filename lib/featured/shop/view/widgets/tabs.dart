import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DragController extends GetxController {
  var draggedIcon = Rx<IconData?>(null); // أيقونة مستهدفة عند السحب

  void setDraggedIcon(IconData icon) {
    draggedIcon.value = icon;
    Future.delayed(Duration(seconds: 1), () => draggedIcon.value = null); // إرجاع اللون بعد ثوانٍ
  }
}

class DragDropScreen extends StatelessWidget {
  final DragController controller = Get.put(DragController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("سحب وإفلات الأيقونات")),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Draggable<IconData>(
                data: Icons.favorite,
                feedback: Icon(Icons.favorite, size: 50, color: Colors.red),
                childWhenDragging: Icon(Icons.favorite, size: 50, color: Colors.grey),
                child: Icon(Icons.favorite, size: 50, color: Colors.red),
              ),
              SizedBox(height: 30),
              DragTarget<IconData>(
                onAccept: (icon) {
                  controller.setDraggedIcon(icon);
                  Get.snackbar("تم الإفلات", "تم تنفيذ الفعل بنجاح!");
                },
                builder: (context, candidateData, rejectedData) {
                  return Obx(() => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: controller.draggedIcon.value == Icons.favorite ? Colors.green : Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, size: 50, color: Colors.white),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
