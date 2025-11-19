// lib/features/duty/pages/my_duties_result_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class MyDutiesResultPage extends StatelessWidget {
  const MyDutiesResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Moje służby',
        showBack: true,
      ),
      body: PageContainer(
        maxWidth: 480,
        child: const SizedBox.shrink(),
      ),
    );
  }
}

