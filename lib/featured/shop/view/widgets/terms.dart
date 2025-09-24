import 'package:flutter/material.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({
    super.key,
    required this.englishText,
    required this.englishTitle,
    required this.arabicText,
    required this.arabicTitle,
  });

  final String arabicText;
  final String englishText;
  final String arabicTitle;
  final String englishTitle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            !TranslationController.instance.isRTL ? englishTitle : arabicTitle,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Wrap(
                  children: [
                    Text(
                      !TranslationController.instance.isRTL
                          ? englishText
                          : arabicText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
