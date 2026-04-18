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
        builder: (context) => ItemDetailsScreen(item: item),
      ),
    );
  }

  List<ItemModel> get _filteredItems {
    if (_selectedIndex == 0) {
      return _items.where((item) => item.type == 'Lost').toList();
    } else {
      return _items.where((item) => item.type == 'Found').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Campus'),
        centerTitle: true,
      ),
      body: _filteredItems.isEmpty
          ? Center(
        child: Text(
          _selectedIndex == 0
              ? 'No lost items yet'
              : 'No found items yet',
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
                '${item.location}\n${item.description}',
              ),
              isThreeLine: true,
              trailing: Text(
                '${item.date.day}/${item.date.month}/${item.date.year}',
              ),
            ),
          );
        },
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