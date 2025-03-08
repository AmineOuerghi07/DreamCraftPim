import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/ProviderClasses/SeeAllProductsProvider.dart';
import 'package:pim_project/view/screens/Components/plants_for_sell.dart';
import 'package:provider/provider.dart';

class SeeAllProductsWithSameCategory extends StatelessWidget {
  final String categorie;

  SeeAllProductsWithSameCategory({super.key, required this.categorie});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SeeAllProductsProvider>(context, listen: false).getProducts(categorie);
    });

    return Consumer<SeeAllProductsProvider>(
      builder: (context, provider, child) {
        if (provider.products.isEmpty) {
          return const Center(child: CircularProgressIndicator()); // Show loading state
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                GoRouter.of(context).push('/market-details/6952315ald2');
                print("Product ${provider.products[index].name} tapped!");
              },
              child: PlantCard(product: provider.products[index]),
            );
          },
        );
      },
    );
  }
}
