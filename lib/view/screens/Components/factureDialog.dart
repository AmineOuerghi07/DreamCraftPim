import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/cartProvider.dart';
import 'package:pim_project/ProviderClasses/factureProvider.dart';
import 'package:provider/provider.dart';

class PaymentDialog extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final VoidCallback onClose;

  const PaymentDialog({required this.products, required this.onClose, Key? key})
      : super(key: key);

  double get totalPrice => products.fold(
      0,
      (sum, product) =>
          sum + (product['price'] as double) * (product['quantity'] as int));

  @override
  Widget build(BuildContext context) {
    return Consumer<FactureProvider>(
      builder: (context, factureProvider, child) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text("Confirm Your Purchase",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.mode_edit_outline_outlined,
                          color: Colors.red),
                      onPressed: () {
                        factureProvider.toggleEditMode();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Table with new colors
                Table(
                  border:
                      TableBorder.all(color: Colors.green.shade200, width: 1),
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
                            child: Text("Product Name",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Quantity",
                                style: TextStyle(color: Colors.white))),
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Price",
                                style: TextStyle(color: Colors.white))),
                      ],
                    ),
                    ...products.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      return TableRow(
                        decoration: BoxDecoration(
                            color: index.isEven
                                ? Colors.green.shade50
                                : Colors.white),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                if (factureProvider.editMode)
                                  const Text(
                                    "-",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                if (factureProvider.editMode)
                                  const SizedBox(width: 4),
                                Text(product['name'],
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${product['quantity']}"),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${product['price']} DNT")),
                        ],
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 10),

                // Total Price and (conditionally) Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total: \$${totalPrice.toStringAsFixed(2)} DNT",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
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
                              const Text("Confirm Purchase",
                                  style: TextStyle(fontSize: 14)),
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
                          onPressed: onClose,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          child: const Text("Cancel Purchase"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: factureProvider.editMode
                              ? () {
                                  // Call function for confirming changes (empty for now)
                                }
                              : cartProvider.isConfirmed
                                  ? () {
                                    onClose();
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: factureProvider.editMode
                                ? Colors.orange.shade600
                                : cartProvider.isConfirmed
                                    ? Colors.green.shade600
                                    : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: Text(factureProvider.editMode
                              ? "Confirm Changes"
                              : "Pay Now"),
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
