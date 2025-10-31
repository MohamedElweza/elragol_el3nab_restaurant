import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/global_menu_provider.dart';
import '../../cubit/menu_cubit.dart';
import 'widgets/menu_categories_view_body.dart';

class MenuManagementView extends StatelessWidget {
  const MenuManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GlobalMenuProvider.getInstance(),
      child: Builder(
        builder: (context) {
          // Load categories with the global instance
          // This will use cache if available, providing instant loading
          context.read<MenuCubit>().loadMenuCategories();
          return const MenuCategoriesViewBody();
        },
      ),
    );
  }
}