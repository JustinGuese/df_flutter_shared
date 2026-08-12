/// Stepped course player with pluggable chapter types.
///
/// Supersedes the learning-course screens that used to live in df_onboarding,
/// which had four fixed section kinds and a separate progress-ID convention.
library;

export 'src/chapter_renderers/checklist_view.dart';
export 'src/chapter_renderers/quiz_view.dart';
export 'src/chapter_renderers/reading_view.dart';
export 'src/chapter_renderers/red_flags_view.dart';
export 'src/course_models.dart';
export 'src/course_progress_notifier.dart';
export 'src/course_screen.dart';
export 'src/course_strings.dart';
