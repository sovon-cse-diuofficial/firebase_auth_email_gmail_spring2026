import 'package:flutter/material.dart';
import '../models/item_model.dart';

class ItemDetailsScreen extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onMarkResolved;

  const ItemDetailsScreen({
    super.key,
    required this.item,
    required this.onMarkResolved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Text('Image could not be loaded'),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('No image provided'),
                  ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Type: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(item.type),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Category: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(item.category),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item.isResolved ? 'Recovered' : 'Active',
                      style: TextStyle(
                        color: item.isResolved ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(item.location),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Date: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${item.date.day}/${item.date.month}/${item.date.year}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                if (!item.isResolved)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onMarkResolved();
                        Navigator.pop(context);
                      },
                      child: const Text('Mark as Recovered'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      child: const Text('Already Recovered'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}