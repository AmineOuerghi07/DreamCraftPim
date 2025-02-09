import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/ProviderClasses/quantity_provider.dart';
import 'package:pim_project/view/screens/Components/region_detail_InfoCard.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String id;

  const ProductDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
              child: Image.asset(
                'assets/images/limeTree.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lime Seedlings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      'Available in stock',
                      style: TextStyle(color: Colors.green),
                    ),
                    const Row(children: [
                      Icon(Icons.star, color: Colors.yellow, size: 20),
                      SizedBox(width: 4),
                      Text('4.9 (192)'),
                    ]),
                  ],
                ),
                Column(
                  children: [
                    const Text('16DT / pcs',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.lightGreen),
                          onPressed: () {
                            context.read<QuantityProvider>().decrement();
                          },
                        ),
                        Consumer<QuantityProvider>(
                          builder: (context, provider, _) {
                            return Text('${provider.quantity}pcs',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Colors.lightGreen),
                          onPressed: () {
                            context.read<QuantityProvider>().increment();
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
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Limes are closely related to lemons. They even look similar to them. Lime tree harvest is easier when you are familiar with the different types of Lime Tree.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Environment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Card(
              elevation: 4,
              //padding:  EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RegionDetailInfocard(
                          title: "Expanse",
                          value: "3000m²",
                          imageName: "square_foot.png"),
                      RegionDetailInfocard(
                          title: "Temperature",
                          value: "25°C",
                          imageName: "thermostat_arrow_up.png"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RegionDetailInfocard(
                          title: "Humidity",
                          value: "20%",
                          imageName: "humidity.png"),
                      RegionDetailInfocard(
                          title: "Irragation",
                          value: "50%",
                          imageName: "humidity_high.png"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Related Products',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    child: Image.asset('assets/images/pepper.png'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Add To Cart",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 106, 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EnvironmentStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
