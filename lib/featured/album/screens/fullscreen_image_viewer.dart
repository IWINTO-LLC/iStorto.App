import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// كلاس نقطة الرسم
class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });
}

// كلاس عنصر النص
class TextElement {
  final String text;
  Offset position;
  Color color;
  final double fontSize;
  bool isSelected;

  TextElement({
    required this.text,
    required this.position,
    required this.color,
    required this.fontSize,
    this.isSelected = false,
  });
}

class FullscreenImageViewer extends StatefulWidget {
  final List<dynamic> images; // يمكن أن تكون File أو PhotoModel أو String URL
  final int initialIndex;
  final bool showDeleteButton;
  final bool showEditButton;
  final bool hideControls; // إخفاء جميع عناصر التحكم والإبقاء على الزووم فقط
  final Function(int)? onDelete;
  final Function(File, int)? onSave; // دالة حفظ الصورة المعدلة

  const FullscreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.showDeleteButton = false,
    this.showEditButton = false,
    this.hideControls = false,
    this.onDelete,
    this.onSave,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;
  bool _isProcessing = false;
  PhotoViewController? _photoViewController;
  double _currentRotation = 0.0; // زاوية التدوير الحالية للصورة المعروضة
  int _rotationStep = 0; // خطوة التدوير (0, 1, 2, 3) تمثل 0°, 90°, 180°, 270°
  Map<int, File> _processedImages = {}; // تخزين الصور المعدلة

  // متغيرات الرسم والكتابة
  bool _isDrawingMode = false;
  bool _isTextMode = false;
  List<DrawingPoint> _drawingPoints = [];
  List<TextElement> _textElements = [];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;
  String _textInput = '';
  Offset? _textPosition;

  // متغيرات تحكم النص
  TextElement? _selectedTextElement;
  bool _isDraggingText = false;

  // متغيرات التراجع
  Map<int, List<File>> _undoStack = {}; // مكدس التراجع لكل صورة
  Map<int, List<File>> _redoStack = {}; // مكدس إعادة التنفيذ لكل صورة

  // متغير لتتبع حالة تصغير لوحة التحكم
  bool _isControlPanelMinimized = false;

  // مفتاح للـ RepaintBoundary لالتقاط الصورة المعروضة
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // اقتصاص الصورة
  Future<File?> _cropImage(File imageFile) async {
    try {
      setState(() => _isProcessing = true);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'اقتصاص الصورة',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'اقتصاص الصورة', aspectRatioLockEnabled: false),
        ],
      );

      setState(() => _isProcessing = false);
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      setState(() => _isProcessing = false);
      print('Error cropping image: $e');
      return null;
    }
  }

  // ضغط الصورة
  Future<File?> _compressImage(File imageFile) async {
    try {
      setState(() => _isProcessing = true);

      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        compressedFile.path,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
      );

      setState(() => _isProcessing = false);
      return result != null ? File(result.path) : null;
    } catch (e) {
      setState(() => _isProcessing = false);
      print('Error compressing image: $e');
      return null;
    }
  }

  // تدوير الصورة بزاوية محددة
  Future<File?> _rotateImage(File imageFile, double angle) async {
    try {
      setState(() => _isProcessing = true);

      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final rotatedImage = img.copyRotate(image, angle: angle.toInt());

      final tempDir = await getTemporaryDirectory();
      final rotatedFile = File(
        '${tempDir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final rotatedBytes = img.encodeJpg(rotatedImage);
      await rotatedFile.writeAsBytes(rotatedBytes);

      setState(() => _isProcessing = false);
      return rotatedFile;
    } catch (e) {
      setState(() => _isProcessing = false);
      print('Error rotating image: $e');
      return null;
    }
  }

  // تدوير الصورة بزاوية 90 درجة
  void _rotate90Degrees() {
    setState(() {
      _rotationStep = (_rotationStep + 1) % 4;
      _currentRotation = _rotationStep * 90.0;
    });
  }

  // تدوير الصورة بزاوية -90 درجة
  void _rotateMinus90Degrees() {
    setState(() {
      _rotationStep = (_rotationStep - 1 + 4) % 4;
      _currentRotation = _rotationStep * 90.0;
    });
  }

  // إضافة صورة إلى مكدس التراجع
  void _addToUndoStack(File imageFile) {
    if (!_undoStack.containsKey(_currentIndex)) {
      _undoStack[_currentIndex] = [];
    }
    _undoStack[_currentIndex]!.add(imageFile);

    // مسح مكدس إعادة التنفيذ عند إضافة تعديل جديد
    if (_redoStack.containsKey(_currentIndex)) {
      _redoStack[_currentIndex]!.clear();
    }
  }

  // التراجع عن آخر تعديل
  void _undoLastEdit() {
    if (_undoStack.containsKey(_currentIndex) &&
        _undoStack[_currentIndex]!.isNotEmpty) {
      final lastEdit = _undoStack[_currentIndex]!.removeLast();

      // إضافة الصورة الحالية إلى مكدس إعادة التنفيذ
      if (_processedImages.containsKey(_currentIndex)) {
        if (!_redoStack.containsKey(_currentIndex)) {
          _redoStack[_currentIndex] = [];
        }
        _redoStack[_currentIndex]!.add(_processedImages[_currentIndex]!);
      }

      // تطبيق التراجع
      setState(() {
        _processedImages[_currentIndex] = lastEdit;
        _currentRotation = 0.0;
        _rotationStep = 0;
        _drawingPoints.clear();
        _textElements.clear();
        _selectedTextElement = null;
        _isDraggingText = false;
      });
    }
  }

  // إعادة تنفيذ آخر تراجع
  void _redoLastEdit() {
    if (_redoStack.containsKey(_currentIndex) &&
        _redoStack[_currentIndex]!.isNotEmpty) {
      final redoEdit = _redoStack[_currentIndex]!.removeLast();

      // إضافة الصورة الحالية إلى مكدس التراجع
      if (_processedImages.containsKey(_currentIndex)) {
        if (!_undoStack.containsKey(_currentIndex)) {
          _undoStack[_currentIndex] = [];
        }
        _undoStack[_currentIndex]!.add(_processedImages[_currentIndex]!);
      }

      // تطبيق إعادة التنفيذ
      setState(() {
        _processedImages[_currentIndex] = redoEdit;
        _currentRotation = 0.0;
        _rotationStep = 0;
        _drawingPoints.clear();
        _textElements.clear();
        _selectedTextElement = null;
        _isDraggingText = false;
      });
    }
  }

  // التحقق من إمكانية التراجع
  bool _canUndo() {
    return _undoStack.containsKey(_currentIndex) &&
        _undoStack[_currentIndex]!.isNotEmpty;
  }

  // التحقق من إمكانية إعادة التنفيذ
  bool _canRedo() {
    return _redoStack.containsKey(_currentIndex) &&
        _redoStack[_currentIndex]!.isNotEmpty;
  }

  // إعادة تعيين الصورة إلى حالتها الأصلية
  void _resetImage() {
    setState(() {
      _processedImages.remove(_currentIndex);
      _currentRotation = 0.0;
      _rotationStep = 0;
      _drawingPoints.clear();
      _textElements.clear();
      _selectedTextElement = null;
      _isDraggingText = false;

      // مسح مكدسات التراجع وإعادة التنفيذ
      _undoStack.remove(_currentIndex);
      _redoStack.remove(_currentIndex);
    });
  }

  // بدء وضع الرسم
  void _startDrawingMode() {
    setState(() {
      _isDrawingMode = true;
      _isTextMode = false;
      _rotationStep = 0;
    });
  }

  // بدء وضع الكتابة
  void _startTextMode() {
    setState(() {
      _isTextMode = true;
      _isDrawingMode = false;
      _rotationStep = 0;
    });
  }

  // إيقاف وضع الرسم/الكتابة
  void _stopDrawingTextMode() {
    setState(() {
      _isDrawingMode = false;
      _isTextMode = false;
      // إلغاء تحديد النص عند الخروج من وضع الكتابة
      for (final element in _textElements) {
        element.isSelected = false;
      }
      _selectedTextElement = null;
      _isDraggingText = false;
      // إعادة تعيين حالة تصغير لوحة التحكم
      _isControlPanelMinimized = false;
    });
  }

  // إضافة نقطة رسم
  void _addDrawingPoint(Offset offset) {
    if (_isDrawingMode) {
      setState(() {
        _drawingPoints.add(
          DrawingPoint(
            offset: offset,
            color: _selectedColor,
            strokeWidth: _strokeWidth * 2, // زيادة سمك الخط للرؤية الأفضل
          ),
        );
      });
    }
  }

  // إضافة نص
  void _addText(String text, Offset position) {
    if (_isTextMode && text.isNotEmpty) {
      setState(() {
        _textElements.add(
          TextElement(
            text: text,
            position: position,
            color: _selectedColor,
            fontSize: 40.0, // زيادة حجم النص
          ),
        );
        _textInput = '';
        _textPosition = null;
      });
    }
  }

  // تحديد النص عند النقر عليه
  void _selectTextElement(Offset tapPosition) {
    for (int i = _textElements.length - 1; i >= 0; i--) {
      final textElement = _textElements[i];
      final textPainter = TextPainter(
        text: TextSpan(
          text: textElement.text,
          style: TextStyle(
            color: textElement.color,
            fontSize: textElement.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textRect = Rect.fromLTWH(
        textElement.position.dx,
        textElement.position.dy,
        textPainter.width,
        textPainter.height,
      );

      if (textRect.contains(tapPosition)) {
        setState(() {
          // إلغاء تحديد جميع النصوص الأخرى
          for (final element in _textElements) {
            element.isSelected = false;
          }
          textElement.isSelected = true;
          _selectedTextElement = textElement;
        });
        return;
      }
    }

    // إذا لم يتم النقر على أي نص، إلغاء التحديد
    setState(() {
      for (final element in _textElements) {
        element.isSelected = false;
      }
      _selectedTextElement = null;
    });
  }

  // تحريك النص المحدد
  void _moveSelectedText(Offset newPosition) {
    if (_selectedTextElement != null) {
      setState(() {
        _selectedTextElement!.position = newPosition;
      });
    }
  }

  // تغيير لون النص المحدد
  void _changeSelectedTextColor(Color newColor) {
    if (_selectedTextElement != null) {
      setState(() {
        _selectedTextElement!.color = newColor;
      });
    }
  }

  // حذف النص المحدد
  void _deleteSelectedText() {
    if (_selectedTextElement != null) {
      setState(() {
        _textElements.remove(_selectedTextElement);
        _selectedTextElement = null;
      });
    }
  }

  // حفظ الصورة مع الرسم والنص باستخدام RepaintBoundary
  Future<File?> _saveImageWithDrawing() async {
    try {
      setState(() => _isProcessing = true);

      // التأكد من وجود RepaintBoundary
      if (_repaintBoundaryKey.currentContext == null) {
        print('RepaintBoundary context is null');
        setState(() => _isProcessing = false);
        return null;
      }

      // التقاط الصورة المعروضة من RepaintBoundary
      RenderRepaintBoundary boundary =
          _repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(
        pixelRatio: 3.0,
      ); // استخدام pixelRatio عالي لجودة أفضل
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // حفظ الصورة المعدلة
      final tempDir = await getTemporaryDirectory();
      final processedFile = File(
        '${tempDir.path}/drawn_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await processedFile.writeAsBytes(pngBytes);

      setState(() => _isProcessing = false);

      // طباعة رسالة تأكيد للحفظ
      print('Image saved with drawing and text elements via RepaintBoundary');

      return processedFile;
    } catch (e) {
      setState(() => _isProcessing = false);
      print('Error saving image with drawing via RepaintBoundary: $e');
      return null;
    }
  }

  // عرض مربع حوار إدخال النص
  void _showTextInputDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('title'.tr),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'description'.tr),
          onChanged: (value) {
            _textInput = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('general_cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              if (_textInput.isNotEmpty && _textPosition != null) {
                _addText(_textInput, _textPosition!);
              }
              Get.back();
            },
            child: Text('album.create'.tr),
          ),
        ],
      ),
    );
  }

  // حفظ الصورة المعدلة
  Future<void> _saveProcessedImage(File processedFile) async {
    // إضافة الصورة الحالية إلى مكدس التراجع قبل حفظ الصورة الجديدة
    if (_processedImages.containsKey(_currentIndex)) {
      _addToUndoStack(_processedImages[_currentIndex]!);
    }

    // تخزين الصورة المعدلة في الذاكرة المحلية
    setState(() {
      _processedImages[_currentIndex] = processedFile;
    });

    if (widget.onSave != null) {
      widget.onSave!(processedFile, _currentIndex);
      // لا نغلق الصفحة بعد الحفظ - يبقى المستخدم في وضعية التعديل
      // Navigator.pop(context); // تم إزالة هذا السطر

      // إظهار رسالة تأكيد الحفظ
      // String message = 'تم حفظ التعديلات بنجاح';
      // if (_currentRotation != 0.0) {
      //   message += ' (مع التدوير ${_currentRotation.toInt()}°)';
      // }
      // if (_drawingPoints.isNotEmpty) {
      //   message += ' (مع الرسم)';
      // }
      // if (_textElements.isNotEmpty) {
      //   message += ' (مع النص)';
      // }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       message,
      //       style: TextStyle(color: Colors.white),
      //     ),
      //     backgroundColor: Colors.black,
      //     duration: Duration(seconds: 3),
      //     behavior: SnackBarBehavior.floating,
      //     margin: EdgeInsets.all(16),
      //   ),
      // );

      // طباعة رسالة تأكيد للحفظ
      print(
        'Processed image saved successfully for index $_currentIndex with modifications: rotation=$_currentRotation, drawing=${_drawingPoints.length}, text=${_textElements.length}',
      );

      // إعادة تعيين التعديلات بعد الحفظ الناجح
      setState(() {
        _currentRotation = 0.0;
        _rotationStep = 0;
        _drawingPoints.clear();
        _textElements.clear();
        _selectedTextElement = null;
        _isDraggingText = false;
      });
    }
  }

  // دالة لحفظ الصورة مع جميع التعديلات
  Future<File?> _saveImageWithAllModifications() async {
    try {
      setState(() => _isProcessing = true);

      // الحصول على الصورة الحالية
      dynamic currentImage = widget.images[_currentIndex];
      if (_processedImages.containsKey(_currentIndex)) {
        currentImage = _processedImages[_currentIndex]!;
      }

      // إذا كانت الصورة URL وليست ملف، نحتاج لتحميلها أولاً
      File? imageFile;
      if (currentImage is String) {
        // تحميل الصورة من URL كملف مؤقت
        imageFile = await _downloadImageFromUrl(currentImage);
        if (imageFile == null) {
          setState(() => _isProcessing = false);
          return null;
        }
      } else if (currentImage is File) {
        imageFile = currentImage;
      } else {
        setState(() => _isProcessing = false);
        return null;
      }

      File imageToProcess = imageFile;

      // تطبيق التدوير أولاً إذا كان موجوداً
      if (_currentRotation != 0.0) {
        final rotatedFile = await _rotateImage(imageFile, _currentRotation);
        if (rotatedFile != null) {
          imageToProcess = rotatedFile;
        }
      }

      // إذا كان هناك رسم أو نص، استخدم RepaintBoundary
      if (_drawingPoints.isNotEmpty || _textElements.isNotEmpty) {
        // تحديث الصورة في _processedImages مؤقتاً للرسم
        setState(() {
          _processedImages[_currentIndex] = imageToProcess;
        });

        // انتظار قليل لضمان تحديث الواجهة
        await Future.delayed(Duration(milliseconds: 100));

        // حفظ الصورة مع الرسم والنص
        final finalImage = await _saveImageWithDrawing();
        if (finalImage != null) {
          setState(() => _isProcessing = false);
          return finalImage;
        }
      }

      // إذا كان هناك تدوير فقط بدون رسم أو نص، إرجاع الصورة المدورة
      if (_currentRotation != 0.0) {
        setState(() => _isProcessing = false);
        return imageToProcess;
      }

      setState(() => _isProcessing = false);
      return imageToProcess;
    } catch (e) {
      setState(() => _isProcessing = false);
      print('Error saving image with all modifications: $e');
      return null;
    }
  }

  // دالة لتحميل الصورة من URL كملف مؤقت
  Future<File?> _downloadImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/downloaded_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tempFile.writeAsBytes(response.bodyBytes);
        return tempFile;
      }
      return null;
    } catch (e) {
      print('Error downloading image from URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // معرض الصور مع دعم التدوير بحركة الأصبعين والرسم
            RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Stack(
                children: [
                  PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      final image = widget.images[index];
                      return PhotoViewGalleryPageOptions(
                        imageProvider: _getImageProvider(image, index),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2.0,
                        heroAttributes: PhotoViewHeroAttributes(
                          tag: "image_$index",
                        ),
                        controller: _photoViewController,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.transparent,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    itemCount: widget.images.length,
                    loadingBuilder: (context, event) {
                      return Container(
                        color: Colors.transparent,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    pageController: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        // إعادة تعيين زاوية التدوير عند تغيير الصورة
                        _currentRotation = 0.0;
                        _rotationStep = 0;
                        // إعادة تعيين النص المحدد عند تغيير الصورة
                        _selectedTextElement = null;
                        _isDraggingText = false;
                        for (final element in _textElements) {
                          element.isSelected = false;
                        }
                        // مسح نقاط الرسم والنصوص عند تغيير الصورة
                        _drawingPoints.clear();
                        _textElements.clear();
                        _currentRotation = 0.0;
                        _rotationStep = 0;
                      });
                    },
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),

                  // طبقة الرسم والكتابة
                  if (_isDrawingMode || _isTextMode)
                    Positioned.fill(
                      child: GestureDetector(
                        onPanStart: (details) {
                          if (_isDrawingMode) {
                            _addDrawingPoint(details.localPosition);
                          } else if (_isTextMode &&
                              _selectedTextElement != null) {
                            // بدء تحريك النص المحدد
                            setState(() {
                              _isDraggingText = true;
                            });
                          }
                        },
                        onPanUpdate: (details) {
                          if (_isDrawingMode) {
                            _addDrawingPoint(details.localPosition);
                          } else if (_isTextMode &&
                              _selectedTextElement != null) {
                            // تحريك النص المحدد
                            _moveSelectedText(details.localPosition);
                          }
                        },
                        onPanEnd: (details) {
                          if (_isTextMode && _isDraggingText) {
                            setState(() {
                              _isDraggingText = false;
                            });
                          }
                        },
                        onTapDown: (details) {
                          if (_isTextMode) {
                            // التحقق من النقر على نص موجود أولاً
                            _selectTextElement(details.localPosition);

                            // إذا لم يتم النقر على نص موجود، إضافة نص جديد
                            if (_selectedTextElement == null) {
                              _textPosition = details.localPosition;
                              _showTextInputDialog();
                            }
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: CustomPaint(
                            painter: DrawingPainter(
                              drawingPoints: _drawingPoints,
                              textElements: _textElements,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // مؤشر المعالجة
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'processing...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // واجهة الرسم والكتابة
            if (_isDrawingMode || _isTextMode)
              Positioned(
                top: 100, // نقل اللوحة إلى أعلى الشاشة
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isDrawingMode ? 'وضع الرسم' : 'وضع الكتابة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              // زر تصغير/تكبير لوحة التحكم
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isControlPanelMinimized =
                                        !_isControlPanelMinimized;
                                  });
                                },
                                icon: Icon(
                                  _isControlPanelMinimized
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip:
                                    _isControlPanelMinimized
                                        ? 'تكبير لوحة التحكم'
                                        : 'تصغير لوحة التحكم',
                              ),
                              IconButton(
                                onPressed: () {
                                  _stopDrawingTextMode();
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // محتوى لوحة التحكم (يظهر فقط عندما لا تكون مصغرة)
                      if (!_isControlPanelMinimized) ...[
                        const SizedBox(height: 12),

                        // رسالة توضيحية
                        if (_selectedTextElement != null)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _isDraggingText
                                  ? 'جاري تحريك النص...'
                                  : 'اسحب النص لتحريكه أو اختر لوناً جديداً',
                              style: TextStyle(
                                color:
                                    _isDraggingText
                                        ? Colors.orange
                                        : Colors.yellow,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // اختيار اللون
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ColorButton(
                              color: Colors.red,
                              isSelected: _selectedColor == Colors.red,
                              onTap: () {
                                setState(() => _selectedColor = Colors.red);
                                if (_selectedTextElement != null) {
                                  _changeSelectedTextColor(Colors.red);
                                }
                              },
                            ),
                            _ColorButton(
                              color: Colors.blue,
                              isSelected: _selectedColor == Colors.blue,
                              onTap: () {
                                setState(() => _selectedColor = Colors.blue);
                                if (_selectedTextElement != null) {
                                  _changeSelectedTextColor(Colors.blue);
                                }
                              },
                            ),
                            _ColorButton(
                              color: Colors.green,
                              isSelected: _selectedColor == Colors.green,
                              onTap: () {
                                setState(() => _selectedColor = Colors.green);
                                if (_selectedTextElement != null) {
                                  _changeSelectedTextColor(Colors.green);
                                }
                              },
                            ),
                            _ColorButton(
                              color: Colors.yellow,
                              isSelected: _selectedColor == Colors.yellow,
                              onTap: () {
                                setState(() => _selectedColor = Colors.yellow);
                                if (_selectedTextElement != null) {
                                  _changeSelectedTextColor(Colors.yellow);
                                }
                              },
                            ),
                            _ColorButton(
                              color: Colors.white,
                              isSelected: _selectedColor == Colors.white,
                              onTap: () {
                                setState(() => _selectedColor = Colors.white);
                                if (_selectedTextElement != null) {
                                  _changeSelectedTextColor(Colors.white);
                                }
                              },
                            ),
                          ],
                        ),

                        if (_isDrawingMode) ...[
                          const SizedBox(height: 12),
                          Text(
                            'حجم القلم: ${_strokeWidth.toInt()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Slider(
                            value: _strokeWidth,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            activeColor: Colors.white,
                            inactiveColor: Colors.grey,
                            onChanged: (value) {
                              setState(() => _strokeWidth = value);
                            },
                          ),
                        ],

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // زر التراجع
                            if (_canUndo())
                              TextButton(
                                onPressed: () {
                                  _undoLastEdit();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم التراجع عن آخر تعديل',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.blue,
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(16),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'تراجع',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),

                            // زر إعادة التنفيذ
                            if (_canRedo())
                              TextButton(
                                onPressed: () {
                                  _redoLastEdit();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم إعادة تنفيذ التعديل',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.blue,
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(16),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'إعادة تنفيذ',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _drawingPoints.clear();
                                  _textElements.clear();
                                  _selectedTextElement = null;
                                  _currentRotation = 0.0;
                                  _rotationStep = 0;
                                });
                              },
                              child: const Text(
                                'مسح الكل',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            if (_selectedTextElement != null)
                              TextButton(
                                onPressed: () {
                                  _deleteSelectedText();
                                },
                                child: const Text(
                                  'حذف النص',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                if (widget.onSave != null) {
                                  // حفظ الصورة مع جميع التعديلات
                                  final processedFile =
                                      await _saveImageWithAllModifications();
                                  if (processedFile != null) {
                                    await _saveProcessedImage(processedFile);
                                  }
                                }
                              },
                              child: const Text('حفظ'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // شريط التحكم العلوي
            if (!widget.hideControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // زر الرجوع
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // إظهار رسالة تأكيد الخروج إذا كان هناك تعديلات
                                  if (_processedImages.isNotEmpty ||
                                      _isDrawingMode ||
                                      _isTextMode) {
                                    Get.dialog(
                                      AlertDialog(
                                        title: Text('general_confirm'.tr),
                                        content: Text('warning'.tr),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text('general_cancel'.tr),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Get.back();
                                              Get.back();
                                            },
                                            child: Text(
                                              'exitApp'.tr,
                                              style: const TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    Get.back();
                                  }
                                },
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),

                            // عداد الصور
                            if (widget.images.length > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentIndex + 1} / ${widget.images.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            // زر الحذف
                            if (widget.showDeleteButton &&
                                widget.onDelete != null)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // إظهار رسالة تأكيد الحذف
                                    Get.dialog(
                                      AlertDialog(
                                        title: Text('confirm_deletion'.tr),
                                        content: Text('delete_item_confirm'.tr),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text('general_cancel'.tr),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Get.back();
                                              widget.onDelete!(_currentIndex);
                                              Get.back();
                                            },
                                            child: Text(
                                              'delete'.tr,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // شريط التحكم السفلي
            if (!widget.hideControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity:
                      (_showControls && !_isDrawingMode && !_isTextMode)
                          ? 1.0
                          : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // زر إزالة الخلفية
                              // _ControlButton(
                              //   icon: Icons.auto_fix_high,
                              //   onTap: () async {
                              //     dynamic currentImage =
                              //         widget.images[_currentIndex];
                              //     if (_processedImages.containsKey(_currentIndex)) {
                              //       currentImage = _processedImages[_currentIndex]!;
                              //     }
                              //     if (currentImage is File) {
                              //       final processedFile =
                              //           await _removeBackground(currentImage);
                              //       if (processedFile != null) {
                              //         await _saveProcessedImage(processedFile);
                              //       }
                              //     }
                              //   },
                              // ),

                              // const SizedBox(width: 8),

                              // زر الاقتصاص
                              _ControlButton(
                                icon: Icons.crop,
                                onTap: () async {
                                  dynamic currentImage =
                                      widget.images[_currentIndex];
                                  if (_processedImages.containsKey(
                                    _currentIndex,
                                  )) {
                                    currentImage =
                                        _processedImages[_currentIndex]!;
                                  }
                                  if (currentImage is File) {
                                    final processedFile = await _cropImage(
                                      currentImage,
                                    );
                                    if (processedFile != null) {
                                      await _saveProcessedImage(processedFile);
                                    }
                                  }
                                },
                              ),

                              // const SizedBox(width: 8),

                              // زر التدوير لليمين
                              _ControlButton(
                                icon: Icons.rotate_right,
                                onTap: () async {
                                  _rotate90Degrees();
                                  // تطبيق التدوير مباشرة
                                  if (widget.onSave != null) {
                                    final processedFile =
                                        await _saveImageWithAllModifications();
                                    if (processedFile != null) {
                                      await _saveProcessedImage(processedFile);

                                      // إظهار رسالة تأكيد التدوير
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'تم تدوير الصورة ${_currentRotation.toInt()}° بنجاح',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(16),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),

                              const SizedBox(width: 8),

                              // زر التدوير لليسار
                              _ControlButton(
                                icon: Icons.rotate_left,
                                onTap: () async {
                                  _rotateMinus90Degrees();
                                  // تطبيق التدوير مباشرة
                                  if (widget.onSave != null) {
                                    final processedFile =
                                        await _saveImageWithAllModifications();
                                    if (processedFile != null) {
                                      await _saveProcessedImage(processedFile);

                                      // إظهار رسالة تأكيد التدوير
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'تم تدوير الصورة ${_currentRotation.toInt()}° بنجاح',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(16),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),

                              const SizedBox(width: 8),

                              // زر الضغط
                              _ControlButton(
                                icon: Icons.compress,
                                onTap: () async {
                                  dynamic currentImage =
                                      widget.images[_currentIndex];
                                  if (_processedImages.containsKey(
                                    _currentIndex,
                                  )) {
                                    currentImage =
                                        _processedImages[_currentIndex]!;
                                  }
                                  if (currentImage is File) {
                                    final processedFile = await _compressImage(
                                      currentImage,
                                    );
                                    if (processedFile != null) {
                                      await _saveProcessedImage(processedFile);
                                    }
                                  }
                                },
                              ),

                              const SizedBox(width: 8),

                              // زر الرسم
                              _ControlButton(
                                icon: _isDrawingMode ? Icons.check : Icons.edit,
                                onTap: () {
                                  if (_isDrawingMode) {
                                    _stopDrawingTextMode();
                                  } else {
                                    _startDrawingMode();
                                  }
                                },
                              ),

                              const SizedBox(width: 8),

                              // زر الكتابة
                              _ControlButton(
                                icon:
                                    _isTextMode
                                        ? Icons.check
                                        : Icons.text_fields,
                                onTap: () {
                                  if (_isTextMode) {
                                    _stopDrawingTextMode();
                                  } else {
                                    _startTextMode();
                                  }
                                },
                              ),

                              // زر الحفظ
                              if (widget.showEditButton) ...[
                                const SizedBox(width: 8),
                                _ControlButton(
                                  icon: Icons.save,
                                  onTap: () async {
                                    if (widget.onSave != null) {
                                      // حفظ الصورة مع جميع التعديلات
                                      final processedFile =
                                          await _saveImageWithAllModifications();
                                      if (processedFile != null) {
                                        await _saveProcessedImage(
                                          processedFile,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],

                              // زر التراجع
                              if (_canUndo()) ...[
                                const SizedBox(width: 8),
                                _ControlButton(
                                  icon: Icons.undo,
                                  onTap: () {
                                    _undoLastEdit();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تم التراجع عن آخر تعديل',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.blue,
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(16),
                                      ),
                                    );
                                  },
                                ),
                              ],

                              // زر إعادة التنفيذ
                              if (_canRedo()) ...[
                                const SizedBox(width: 8),
                                _ControlButton(
                                  icon: Icons.redo,
                                  onTap: () {
                                    _redoLastEdit();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تم إعادة تنفيذ التعديل',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.blue,
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(16),
                                      ),
                                    );
                                  },
                                ),
                              ],

                              // زر إعادة التعيين
                              if (_processedImages.containsKey(
                                _currentIndex,
                              )) ...[
                                const SizedBox(width: 8),
                                _ControlButton(
                                  icon: Icons.refresh,
                                  onTap: () {
                                    _resetImage();
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // زر الإغلاق البسيط عندما تكون عناصر التحكم مخفية
            if (widget.hideControls)
              Positioned(
                top: 40,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // الحصول على مزود الصورة
  ImageProvider _getImageProvider(dynamic image, int index) {
    // التحقق من وجود صورة معدلة
    if (_processedImages.containsKey(index)) {
      print('Using processed image for index $index');
      return FileImage(_processedImages[index]!);
    }

    if (image is File) {
      print('Using original file image for index $index');
      return FileImage(image);
    } else if (image is String) {
      print('Using network image for index $index');
      return NetworkImage(image);
    } else {
      // إذا كان PhotoModel أو أي نوع آخر
      print('Using PhotoModel image for index $index');
      try {
        return NetworkImage(image.url);
      } catch (e) {
        // إذا فشل، استخدم صورة افتراضية
        return NetworkImage(image.toString());
      }
    }
  }
}

// زر التحكم
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// رسام الرسم والنص
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  final List<TextElement> textElements;

  DrawingPainter({required this.drawingPoints, required this.textElements});

  @override
  void paint(Canvas canvas, Size size) {
    // رسم النقاط
    if (drawingPoints.isNotEmpty) {
      final paint =
          Paint()
            ..color = drawingPoints.first.color
            ..strokeWidth = drawingPoints.first.strokeWidth
            ..strokeCap = StrokeCap.round;

      for (int i = 0; i < drawingPoints.length - 1; i++) {
        final point1 = drawingPoints[i];
        final point2 = drawingPoints[i + 1];
        canvas.drawLine(point1.offset, point2.offset, paint);
      }
    }

    // رسم النصوص
    for (final textElement in textElements) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: textElement.text,
          style: TextStyle(
            color: textElement.color,
            fontSize: textElement.fontSize,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, textElement.position);

      // رسم إطار حول النص المحدد
      if (textElement.isSelected) {
        final borderPaint =
            Paint()
              ..color = Colors.yellow
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.0;

        final borderRect = Rect.fromLTWH(
          textElement.position.dx - 6,
          textElement.position.dy - 6,
          textPainter.width + 12,
          textPainter.height + 12,
        );
        canvas.drawRect(borderRect, borderPaint);

        // رسم نقاط التحكم في الزوايا
        final controlPointPaint =
            Paint()
              ..color = Colors.yellow
              ..style = PaintingStyle.fill;

        final controlPointSize = 10.0;
        final controlPoints = [
          Offset(borderRect.left, borderRect.top),
          Offset(borderRect.right, borderRect.top),
          Offset(borderRect.right, borderRect.bottom),
          Offset(borderRect.left, borderRect.bottom),
        ];

        for (final point in controlPoints) {
          canvas.drawCircle(point, controlPointSize, controlPointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// زر اختيار اللون
class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}

// دالة مساعدة لفتح معاينة الصورة
void showFullscreenImage({
  required BuildContext context,
  required List<dynamic> images,
  int initialIndex = 0,
  bool showDeleteButton = false,
  bool showEditButton = false,
  Function(int)? onDelete,
  Function(File, int)? onSave,
}) {
  Get.to(
    () => FullscreenImageViewer(
      images: images,
      initialIndex: initialIndex,
      showDeleteButton: showDeleteButton,
      showEditButton: showEditButton,
      onDelete: onDelete,
      onSave: onSave,
    ),
  );
}
