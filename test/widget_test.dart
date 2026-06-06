import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:developer_task/features/auth/screens/role_selection_screen.dart';

void main() {
  testWidgets('roles?', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));
  });
}
