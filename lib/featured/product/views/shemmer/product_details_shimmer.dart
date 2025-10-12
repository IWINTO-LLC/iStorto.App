import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.paddingSizeSmall),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: TColors.lightgrey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).cardColor,
                  highlightColor: Colors.grey[300]!,
                  enabled: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          height: MediaQuery.of(context).size.width - 50,
                          padding: const EdgeInsets.all(
                            TSizes.paddingSizeLarge,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.lightgrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.paddingSizeSmall,
                            ),
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.paddingSizeSmall,
                            ),
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.paddingSizeSmall,
                            ),
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width - 20,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width / 2,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width - 20,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width / 2,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width / 4,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 20,
                          width: MediaQuery.of(context).size.width - 20,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: TSizes.paddingSizeEight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width - 20,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: TSizes.paddingSizeEight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width - 20,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: TSizes.paddingSizeEight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width - 20,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width - 20,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
