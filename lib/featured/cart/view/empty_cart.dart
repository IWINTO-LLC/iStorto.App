import 'package:flutter/material.dart';

import 'package:istoreto/featured/cart/view/widgets/saved_item.dart';
import 'package:istoreto/navigation_menu.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/constants/color.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const SizedBox(
                height: 200,
                child: Icon(
                  Icons.add_shopping_cart_sharp,
                  size: 100,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: CustomFloatActionButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NavigationMenu()),
                    );
                  },
                ),
              ),
              SavedItems(),
            ],
          ),
        ),
      ),
    );
  }
}
