import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<ItemModel> _items = [];
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addItem(ItemModel item) {
    setState(() {
      _items.add(item);
    });
  }

  void _markItemResolved(ItemModel item) {
    setState(() {
      item.isResolved = true;
    });
  }

  void _openAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(onAddItem: _addItem),
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

  List<ItemModel> get _filteredItems {
    List<ItemModel> typeFiltered;

    if (_selectedIndex == 0) {
      typeFiltered = _items.where((item) => item.type == 'Lost').toList();
    } else {
      typeFiltered = _items.where((item) => item.type == 'Found').toList();
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
    final emptyText = _searchController.text.trim().isEmpty
        ? (_selectedIndex == 0 ? 'No lost items yet' : 'No found items yet')
        : 'No matching items found';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Campus'),
        centerTitle: true,
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
            child: _filteredItems.isEmpty
                ? Center(
              child: Text(
                emptyText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _openItemDetails(item),
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.category} • ${item.location}\n'
                          '${item.description}\n'
                          'Status: ${item.isResolved ? "Recovered" : "Active"}',
                    ),
                    trailing: Text(
                      '${item.date.day}/${item.date.month}/${item.date.year}',
                    ),
                  ),
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