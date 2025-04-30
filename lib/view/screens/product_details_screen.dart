import 'package:flutter/material.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/ProviderClasses/product_details_provider.dart';
import 'package:pim_project/view/screens/Components/region_detail_InfoCard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String id;

  const ProductDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailsProvider(productId: id),
      child: Consumer<ProductDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final product = provider.product;

          if (product == null) {
            return const Scaffold(
              body: Center(child: Text("Product not found")),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.details),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),

              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
  "${AppConstants.baseUrl}/uploads/${product.image}",
  height: 200,
  errorBuilder: (context, error, stackTrace) {
    return const Text('Error loading image'); // Debug image loading issues
  },
)
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (product.stockQuantity > 0)
                            Text(
                              AppLocalizations.of(context)!.available,
                              style: const TextStyle(color: Colors.green),
                            )
                          else
                            Text(
                              AppLocalizations.of(context)!.notAvailable,
                              style: const TextStyle(color: Colors.red),
                            ),
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow, size: 20),
                              SizedBox(width: 4),
                              Text('4.9 (192)'),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('${product.price}DT / pcs',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.lightGreen),
                                onPressed: () {
                                  provider.decrement();
                                },
                              ),
                              Text('${provider.quantity} pcs',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.lightGreen),
                                onPressed: () {
                                  provider.increment();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.description,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(product.description ?? AppLocalizations.of(context)!.description),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.features,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RegionDetailInfocard(
                                title: AppLocalizations.of(context)!.expanse, value: "3000m²", imageName: "square_foot.png"),
                            RegionDetailInfocard(
                                title: AppLocalizations.of(context)!.temperature, value: "25°C", imageName: "thermostat_arrow_up.png"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RegionDetailInfocard(
                                title: AppLocalizations.of(context)!.humidity, value: "20%", imageName: "humidity.png"),
                            RegionDetailInfocard(
                                title: AppLocalizations.of(context)!.irrigation, value: "50%", imageName: "humidity_high.png"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.seeAll,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Image.asset('../assets/images/pepper.png'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        
                       provider.checkSharedPref(product);

                        Navigator.pop(context);
                       // Add to cart
                       
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 23, 106, 26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.addRegion,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
