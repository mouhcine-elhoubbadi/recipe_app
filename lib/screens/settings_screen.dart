// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../recipe_provider.dart';
// import '../theme/app_theme.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         backgroundColor: AppTheme.lightBackground,
//       ),
//       body: Consumer<RecipeProvider>(
//         builder: (context, provider, child) {
//           return ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               ListTile(
//                 title: const Text('Language'),
//                 trailing: DropdownButton<String>(
//                   value: provider.language,
//                   items: const [
//                     DropdownMenuItem(value: 'en', child: Text('English')),
//                     DropdownMenuItem(value: 'ar', child: Text('العربية')),
//                   ],
//                   onChanged: (value) {
//                     if (value != null) provider.language = value;
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }