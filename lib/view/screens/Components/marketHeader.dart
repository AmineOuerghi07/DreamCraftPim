import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/cartProvider.dart';
import 'package:pim_project/model/product.dart';
import 'package:pim_project/view/screens/Components/factureDialog.dart';
import 'package:provider/provider.dart';

class Marketheader extends StatelessWidget {
  final String profileImage;
  final String greetingText;
  final String username;

  const Marketheader({
    required this.profileImage,
    required this.greetingText,
    required this.username,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Header background color
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    AssetImage(profileImage), // network image after
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: greetingText,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: username, // from database
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return GestureDetector(
                  child: const Icon(Icons.shopping_cart, color: Colors.green),
                  onTap: () async {
                    // ✅ Wait for products to be loaded
                    List<Product> cartProducts =
                        await cartProvider.getcartProducts();

                    // ✅ Convert List<Product> → List<Map<String, dynamic>>
                    List<Product> cartProductsMap = cartProducts;


                    // ✅ Show dialog after converting products
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PaymentDialog(
                        //  products: cartProductsMap, // Now correctly passing as List<Map<String, dynamic>>
                          onClose: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
