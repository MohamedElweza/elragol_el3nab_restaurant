import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/menu_cubit.dart';
import 'widgets/menu_items_view_body.dart';

class MenuItemsView extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const MenuItemsView({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    // Load items when the view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuCubit>().loadMenuItems(categoryId, categoryName);
    });

    return Scaffold(
      body: MenuItemsViewBody(
        categoryId: categoryId,
        categoryName: categoryName,
      ),
    );
  }
}