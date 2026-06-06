import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/features/auth/models/app_user.dart';

String userRouteAfterAuth(AppUser? user) {
  if (user == null) return AppRoutes.roleSelection;
  if (user.role.isAdmin) return AppRoutes.adminHome;
  if (user.needsProfileSetup) return AppRoutes.profileSetup;
  return AppRoutes.userHome;
}
