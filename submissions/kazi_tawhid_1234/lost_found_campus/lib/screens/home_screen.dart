import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _markItemResolved(ItemModel item) async {
    if (item.id == null) return;
    await _firestoreService.markItemResolved(item.id!);
  }

  void _openAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItemScreen(),
      ),
    );
  }

  void _openItemDetails(ItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(
          item: item,
          onMarkResolved: () => _markItemResolved(item),
        ),
      ),
    );
  }

  List<ItemModel> _applyFilters(List<ItemModel> items) {
    List<ItemModel> typeFiltered;

    if (_selectedIndex == 0) {
      typeFiltered = items.where((item) => item.type == 'Lost').toList();
    } else {
      typeFiltered = items.where((item) => item.type == 'Found').toList();
    }

    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return typeFiltered;
    }

    return typeFiltered
        .where((item) => item.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Campus'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ItemModel>>(
              stream: _firestoreService.getItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load items'));
                }

                final items = _applyFilters(snapshot.data ?? []);
                final emptyText = _searchController.text.trim().isEmpty
                    ? (_selectedIndex == 0
                    ? 'No lost items yet'
                    : 'No found items yet')
                    : 'No matching items found';

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => _openItemDetails(item),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.category} • ${item.location}\n'
                              'Posted by: ${item.userEmail}\n'
                              'Status: ${item.isResolved ? "Recovered" : "Active"}',
                        ),
                        trailing: Text(
                          '${item.date.day}/${item.date.month}/${item.date.year}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItemScreen,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Lost',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Found',
          ),
        ],
      ),
    );
  }
}