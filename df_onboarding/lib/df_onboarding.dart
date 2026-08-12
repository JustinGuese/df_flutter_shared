/// Onboarding carousel shown on first launch.
///
/// This package used to also carry a learning-course player. That has been
/// retired in favour of `package:df_courses`, which supports pluggable chapter
/// types instead of four fixed section kinds. If you were importing
/// `LearningCourseScreen`, `LearningCourseCard`, `LearningCourseModel`,
/// `LearningStepModel` or `learningProgressNotifierProvider` from here, they now
/// live in df_courses as `CourseScreen`, `CourseModel` and
/// `courseProgressNotifierProvider`.
library;

export 'src/onboarding_config.dart';
export 'src/onboarding_page_model.dart';
export 'src/onboarding_provider.dart';
export 'src/onboarding_screen.dart';
export 'src/onboarding_wrapper.dart';
