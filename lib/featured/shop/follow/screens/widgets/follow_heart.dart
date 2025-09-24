import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/follow/controller/follow_controller.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class FollowHeart extends StatefulWidget {
  const FollowHeart({super.key, required this.myId, required this.orgId});

  final String myId;
  final String orgId;

  @override
  State<FollowHeart> createState() => _FollowHeartState();
}

class _FollowHeartState extends State<FollowHeart> {
  final FollowController controller = FollowController.instance;

  @override
  void initState() {
    super.initState();
    controller.checkFollowStatus(widget.myId, widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      width: 35,
      height: 35,
      radius: BorderRadius.circular(300),
      enableShadow: true,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child:
            widget.myId == widget.orgId
                ? const Icon(
                  CupertinoIcons.heart,
                  color: Colors.black,
                  size: 24,
                )
                : InkWell(
                  onTap: () async {
                    controller.isLoading.value = true;

                    if (controller.isFollowing.value) {
                      await controller.unfollowUser(widget.myId, widget.orgId);
                    } else {
                      await controller.followUser(widget.myId, widget.orgId);
                    }

                    await controller.checkFollowStatus(
                      widget.myId,
                      widget.orgId,
                    );
                    controller.isLoading.value = false;
                  },
                  child: Obx(() {
                    return controller.isLoading.value
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              controller.isFollowing.value
                                  ? Colors.black
                                  : Colors.red,
                            ),
                          ),
                        )
                        : Icon(
                          controller.isFollowing.value
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color:
                              controller.isFollowing.value
                                  ? Colors.red
                                  : Colors.black,
                          size: 24,
                        );
                  }),
                ),
      ),
    );
  }
}
