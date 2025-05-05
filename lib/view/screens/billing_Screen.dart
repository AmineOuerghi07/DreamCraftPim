import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/ProviderClasses/factureProvider.dart';
import 'package:pim_project/model/domain/order.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({super.key});

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  DateTime? selectedDate;
  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final factureProvider = Provider.of<FactureProvider>(context, listen: false);
    final Future<void> fetchFuture = factureProvider.fetchOrders();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'Bill History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: fetchFuture,
          builder: (context, snapshot) {
            return Consumer<FactureProvider>(
              builder: (context, factureProvider, child) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (factureProvider.orders.isEmpty) {
                  return const Center(child: Text("No bills available"));
                }
                final filteredOrders = selectedDate == null
                    ? factureProvider.orders
                    : factureProvider.orders.where((order) {
                        return dateFormat.format(order.createdAt) ==
                            dateFormat.format(selectedDate!);
                      }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Recent Bills',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...filteredOrders.map((order) => BillCard(order: order)),
                      const SizedBox(height: 24),
                      _buildFilterCard(context),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(selectedDate == null
                  ? 'Filter by date'
                  : 'Selected: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            if (selectedDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    selectedDate = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

class BillCard extends StatefulWidget {
  final Order order;
  const BillCard({super.key, required this.order});

  @override
  State<BillCard> createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  bool isExpanded = false;
  final Map<String, String> productNames = {};

  Future<void> fetchProductName(String productId) async {
    if (productNames.containsKey(productId)) return;
    try {
      final productProvider = Provider.of<FactureProvider>(context, listen: false);
      final product = await productProvider.fetchProductById(productId);
      setState(() {
        productNames[productId] = product.name;
      });
    } catch (e) {
      print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$e");
      setState(() {
        productNames[productId] = 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final date = DateFormat('yyyy-MM-dd').format(order.createdAt);
    final amount = '\$${order.totalAmount.toStringAsFixed(2)}';
    final statusColor = order.orderStatus == 'Paid' ? Colors.green : Colors.orange;
    final billId = order.referenceId ?? 'Unknown';

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
          if (isExpanded && order.orderItems != null) {
            for (var item in order.orderItems!) {
              fetchProductName(item.productId);
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.orderStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(billId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                    ],
                  ),
                  Text(amount,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              if (isExpanded && order.orderItems != null && order.orderItems!.isNotEmpty) ...[
                const Divider(height: 20),
                const Text('Order Details:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ...order.orderItems!.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Product: ${productNames[item.productId] ?? 'Loading...'}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('Qty: ${item.quantity}'),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
