import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/token_interceptor.dart';
import '../../cubit/menu_cubit.dart';
import '../../data/repos/menu_repository.dart';
import 'widgets/menu_categories_view_body.dart';

class MenuCategoriesView extends StatelessWidget {
  const MenuCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Create Dio instance with token interceptor
        final dio = Dio();
        dio.interceptors.add(TokenInterceptor());
        
        // Create repository and cubit
        final repository = MenuRepository(dio: dio);
        final cubit = MenuCubit(repository);
        
        // Load categories immediately
        cubit.loadMenuCategories();
        
        return cubit;
      },
      child: const MenuCategoriesViewBody(),
    );
  }
}