import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/cartProvider.dart';
import 'package:pim_project/ProviderClasses/factureProvider.dart';
import 'package:pim_project/model/product.dart';
import 'package:provider/provider.dart';

class PaymentDialog extends StatefulWidget {
  final VoidCallback onClose;

  const PaymentDialog({required this.onClose, Key? key}) : super(key: key);

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final Set<String> removedItems = {}; // Track removed items temporarily

  double calculateTotalPrice(BuildContext context) =>
      Provider.of<CartProvider>(context, listen: false)
          .cartItems
          .where((product) => !removedItems.contains(product.id)) // Exclude removed items
          .fold(0, (sum, product) => sum + (product.price) * (product.quantity as int));

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice(context);
    return Consumer<FactureProvider>(
      builder: (context, factureProvider, child) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      "Confirm Your Purchase",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.mode_edit_outline_outlined, color: Colors.red),
                      onPressed: () {
                        factureProvider.toggleEditMode();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Table wrapped inside Consumer<CartProvider>
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    final visibleProducts = cartProvider.cartItems
                        .where((product) => !removedItems.contains(product.id)) // Filter removed items
                        .toList();

                    return Table(
                      border: TableBorder.all(color: Colors.green.shade200, width: 1),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.green.shade800),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Product Name",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Quantity", style: TextStyle(color: Colors.white)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Price", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        ...visibleProducts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final product = entry.value;
                          return TableRow(
                            decoration: BoxDecoration(
                              color: index.isEven ? Colors.green.shade50 : Colors.white,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    if (factureProvider.editMode)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            removedItems.add(product.id);
                                          });
                                        },
                                      ),
                                    if (factureProvider.editMode) const SizedBox(width: 4),
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${product.quantity}"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${product.price} DNT"),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Total Price and (conditionally) Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: \$${totalPrice.toStringAsFixed(2)} DNT",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    if (!factureProvider.editMode)
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return Row(
                            children: [
                              Checkbox(
                                activeColor: Colors.green,
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
                  ],
                ),

                const SizedBox(height: 10),

                // Buttons
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            factureProvider.closeEditMode();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          child: const Text("Cancel Purchase"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: factureProvider.editMode
                              ? () {
                                  // Permanently remove products from CartProvider
                                  for (var id in removedItems) {
                                    final product = cartProvider.cartItems.firstWhere(
                                      (p) => p.id == id,
                                      orElse: () => Product(id: '', name: '', price: 0, quantity: 0, stockQuantity: 0),
                                    );
                                    if (product.id.isNotEmpty) {
                                      cartProvider.removeItem(product);
                                    }
                                  }
                                  setState(() {
                                    removedItems.clear(); // Clear temporary list
                                  });
                                  factureProvider.toggleEditMode();
                                }
                              : cartProvider.isConfirmed
                                  ? widget.onClose
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: factureProvider.editMode
                                ? Colors.orange.shade600
                                : cartProvider.isConfirmed
                                    ? Colors.green.shade600
                                    : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: Text(factureProvider.editMode ? "Confirm Changes" : "Pay Now"),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
