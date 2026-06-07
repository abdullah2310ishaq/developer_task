import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:developer_task/app.dart';
import 'package:developer_task/core/config/env_config.dart';
import 'package:developer_task/firebase_options.dart';
import 'package:developer_task/shared/data/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  Stripe.publishableKey = EnvConfig.stripePublishableKey;
  await Stripe.instance.applySettings();

  await NotificationService.instance.init();

  runApp(const FoodDeliveryApp());
}
