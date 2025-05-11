import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/cartProvider.dart';
import 'package:pim_project/ProviderClasses/factureProvider.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/product.dart';
import 'package:provider/provider.dart';

class CartBottomSheet extends StatefulWidget {
  final VoidCallback onPaymentComplete;

  const CartBottomSheet({required this.onPaymentComplete, Key? key})
      : super(key: key);

  static void show(BuildContext context, VoidCallback onPaymentComplete) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes it expandable
      backgroundColor: Colors.transparent,
      isDismissible: true, // Allow dismissal when tapping outside
      enableDrag: true, // Allow dragging down to dismiss
      builder: (context) => GestureDetector(
        // This prevents taps inside the sheet from dismissing it
        onTap: () {},
        // This creates a non-dismissible area within the dismissible modal
        child: CartBottomSheet(onPaymentComplete: onPaymentComplete),
      ),
    );
  }

  @override
  _CartBottomSheetState createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  final Set<String> removedItems = {};

  double calculateTotalPrice(BuildContext context) =>
      Provider.of<CartProvider>(context, listen: false)
          .cartItems
          .where((product) => !removedItems.contains(product.id))
          .fold(
              0,
              (sum, product) =>
                  sum + (product.price) * (product.quantity as int));

  @override
  void initState() {
    super.initState();
    // Fetch cart items when the bottom sheet is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).getcartProducts();
    });
  }

  // Method to handle checkout process
  void handleCheckout() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final factureProvider = Provider.of<FactureProvider>(context, listen: false);
    
    // Close the bottom sheet
    Navigator.pop(context);
    
    // Create the order
    factureProvider.createOrder(context, calculateTotalPrice(context));
    
    // Clear the cart after checkout
    cartProvider.clearCart();
    
    // Call the completion callback
    widget.onPaymentComplete();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Handle back button press - now returns true to allow dismissal
      onWillPop: () async => true,
      child: DraggableScrollableSheet(
        initialChildSize: 0.75, // 75% of screen height
        minChildSize: 0.5, // Minimum height (50% of screen)
        maxChildSize: 0.95, // Almost full screen
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag indicator
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Your Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (Provider.of<FactureProvider>(context).editMode)
                        IconButton(
                          icon: const Icon(Icons.check, color: AppConstants.primaryColor),
                          onPressed: () {
                            Provider.of<FactureProvider>(context, listen: false)
                                .toggleEditMode();
                          },
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black87),
                          onPressed: () {
                            Provider.of<FactureProvider>(context, listen: false)
                                .toggleEditMode();
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(),
                // Cart items list
                Expanded(
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      final visibleProducts = cartProvider.cartItems
                          .where((product) => !removedItems.contains(product.id))
                          .toList();

                      if (visibleProducts.isEmpty) {
                        return const Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: visibleProducts.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final product = visibleProducts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                // Product image placeholder
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: product.image.isNotEmpty
                                      ? Image.network(
                                          "${AppConstants.baseUrl}/uploads/${product.image}",
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.error_outline, 
                                                color: Colors.grey[400], size: 24);
                                          },
                                        )
                                      : Icon(Icons.image,
                                          color: Colors.grey[400], size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.price.toStringAsFixed(2)} DNT',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (Provider.of<FactureProvider>(context)
                                    .editMode)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        removedItems.add(product.id);
                                      });
                                    },
                                  )
                                else
                                  Text(
                                    'x${product.quantity}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Bottom section with total and checkout button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Consumer<CartProvider>(
                              builder: (context, cartProvider, _) {
                                return Text(
                                  '${calculateTotalPrice(context).toStringAsFixed(2)} DNT',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (!Provider.of<FactureProvider>(context).editMode)
                          Consumer<CartProvider>(
                            builder: (context, cartProvider, _) {
                              return Row(
                                children: [
                                  Checkbox(
                                    activeColor: Colors.orange,
                                    value: cartProvider.isConfirmed,
                                    onChanged: (bool? value) {
                                      cartProvider.toggleConfirmation(value!);
                                    },
                                  ),
                                  const Text(
                                    "Confirm Purchase",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              );
                            },
                          ),
                        const SizedBox(height: 8),
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, _) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: Provider.of<FactureProvider>(context)
                                        .editMode
                                    ? () {
                                        // Apply removals
                                        for (var id in removedItems) {
                                          final product =
                                              cartProvider.cartItems.firstWhere(
                                            (p) => p.id == id,
                                            orElse: () => Product(
                                                id: '',
                                                name: '',
                                                price: 0,
                                                quantity: 0,
                                                stockQuantity: 0,
                                                image: ''),
                                          );
                                          if (product.id.isNotEmpty) {
                                            cartProvider.removeItem(product);
                                          }
                                        }
                                        setState(() {
                                          removedItems.clear();
                                        });
                                        Provider.of<FactureProvider>(context,
                                                listen: false)
                                            .toggleEditMode();
                                      }
                                    : cartProvider.isConfirmed
                                        ? () => handleCheckout()
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Provider.of<FactureProvider>(context)
                                              .editMode
                                          ? Colors.blue
                                          : cartProvider.isConfirmed
                                              ? Colors.orange
                                              : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  Provider.of<FactureProvider>(context).editMode
                                      ? 'Apply Changes'
                                      : 'Check Out',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}