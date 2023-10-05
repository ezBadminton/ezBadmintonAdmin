import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:flutter/material.dart';

part 'bracket_section_navigator_state.dart';

class BracketSectionNavigatorCubit extends Cubit<BracketSectionNavigatorState> {
  BracketSectionNavigatorCubit({
    required this.viewController,
  }) : super(const BracketSectionNavigatorState()) {
    viewController.addListener(
      onViewChanged,
    );
  }

  final AnimatedTransformationController viewController;

  void onViewChanged() {
    Matrix4 viewTransform = viewController.currentTransform;

    double scale = viewTransform.getMaxScaleOnAxis();

    double sceneWidth = viewController.sceneSize.width * scale;
    double viewWidth = viewController.viewConstraints!.maxWidth;

    double widthScale = viewWidth / sceneWidth;

    double visibleWidth = viewWidth * widthScale;

    double viewOffset = -1 * viewTransform.getTranslation().x * widthScale;

    if (viewOffset < 0) {
      visibleWidth += viewOffset;
    }

    emit(BracketSectionNavigatorState(
      horizontalOffset: viewOffset,
      visibleWidth: visibleWidth,
    ));
  }

  @override
  Future<void> close() async {
    viewController.removeListener(onViewChanged);
    return super.close();
  }
}
