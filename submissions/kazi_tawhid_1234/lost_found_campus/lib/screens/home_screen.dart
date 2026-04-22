import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showOnlyMyPosts = false;

  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  String _selectedCategoryFilter = 'All';
  String _selectedSortOption = 'Newest';

  final List<String> _categories = const [
    'All',
    'Electronics',
    'ID Card',
    'Bag',
    'Books',
    'Keys',
    'Others',
  ];

  final List<String> _sortOptions = const [
    'Newest',
    'Oldest',
    'Active First',
    'Recovered First',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _markItemResolved(ItemModel item) async {
    if (item.id == null) return;
    await _firestoreService.markItemResolved(item.id!);
  }

  Future<void> _deleteItem(ItemModel item) async {
    if (item.id == null) return;
    await _firestoreService.deleteItem(item.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post deleted successfully')),
    );
  }

  Future<void> _editItem(ItemModel item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(itemToEdit: item),
      ),
    );
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
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final canModify = item.userEmail == currentUserEmail;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(
          item: item,
          onMarkResolved: () => _markItemResolved(item),
          onDelete: () => _deleteItem(item),
          onEdit: () => _editItem(item),
          canDelete: canModify,
          canEdit: canModify,
        ),
      ),
    );
  }

  List<ItemModel> _applyFilters(List<ItemModel> items) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    List<ItemModel> filteredItems;

    if (_selectedIndex == 0) {
      filteredItems = items.where((item) => item.type == 'Lost').toList();
    } else {
      filteredItems = items.where((item) => item.type == 'Found').toList();
    }

    if (_showOnlyMyPosts) {
      filteredItems = filteredItems
          .where((item) => item.userEmail == currentUserEmail)
          .toList();
    }

    if (_selectedCategoryFilter != 'All') {
      filteredItems = filteredItems
          .where((item) => item.category == _selectedCategoryFilter)
          .toList();
    }

    final query = _searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) => item.title.toLowerCase().contains(query))
          .toList();
    }

    switch (_selectedSortOption) {
      case 'Newest':
        filteredItems.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        filteredItems.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Active First':
        filteredItems.sort((a, b) {
          if (a.isResolved == b.isResolved) return 0;
          return a.isResolved ? 1 : -1;
        });
        break;
      case 'Recovered First':
        filteredItems.sort((a, b) {
          if (a.isResolved == b.isResolved) return 0;
          return a.isResolved ? -1 : 1;
        });
        break;
    }

    return filteredItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? 'User';
    final appState = LostFoundCampusApp.of(context);
    final isDarkMode = appState?.isDarkMode ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Campus'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
              accountName: const Text('Campus User'),
              accountEmail: Text(currentUserEmail),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _showOnlyMyPosts = false;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('My Posts'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _showOnlyMyPosts = true;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (value) {
                appState?.toggleTheme(value);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About App'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Lost & Found Campus',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.blue,
                  ),
                  children: const [
                    Text(
                      'A Flutter app for reporting and finding lost or found items on campus.',
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Logged in as: $currentUserEmail',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
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
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('All Items'),
                        selected: !_showOnlyMyPosts,
                        onSelected: (_) {
                          setState(() {
                            _showOnlyMyPosts = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('My Posts'),
                        selected: _showOnlyMyPosts,
                        onSelected: (_) {
                          setState(() {
                            _showOnlyMyPosts = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategoryFilter,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryFilter = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSortOption,
                        decoration: InputDecoration(
                          labelText: 'Sort',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _sortOptions
                            .map(
                              (sortOption) => DropdownMenuItem(
                            value: sortOption,
                            child: Text(sortOption),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSortOption = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
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

                String emptyText;
                if (_showOnlyMyPosts) {
                  emptyText = _selectedIndex == 0
                      ? 'You have not posted any lost items'
                      : 'You have not posted any found items';
                } else {
                  emptyText = _selectedIndex == 0
                      ? 'No lost items yet'
                      : 'No found items yet';
                }

                if (_searchController.text.trim().isNotEmpty) {
                  emptyText = 'No matching items found';
                }

                if (_selectedCategoryFilter != 'All') {
                  emptyText = 'No items found in $_selectedCategoryFilter';
                }

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showOnlyMyPosts
                              ? Icons.person_search
                              : (_selectedIndex == 0
                              ? Icons.search_off
                              : Icons.inventory_2_outlined),
                          size: 70,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emptyText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to post a new item.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openItemDetails(item),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      item.type,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: item.type == 'Lost'
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.category,
                                style: TextStyle(
                                  color: Colors.blueGrey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Location: ${item.location}'),
                              const SizedBox(height: 4),
                              Text(
                                'Posted by: ${item.userEmail}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    item.isResolved
                                        ? Icons.check_circle
                                        : Icons.access_time,
                                    size: 18,
                                    color: item.isResolved
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.isResolved ? 'Recovered' : 'Active',
                                    style: TextStyle(
                                      color: item.isResolved
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${item.date.day}/${item.date.month}/${item.date.year}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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