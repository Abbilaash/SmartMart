import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: EdgeInsets.only(right: AppSizes.paddingSmall),
            child: GestureDetector(
              onTap: () => onCategoryChanged(category),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryPurple : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryPurple : AppColors.cardShadow,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: AppTextStyles.body2.copyWith(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 