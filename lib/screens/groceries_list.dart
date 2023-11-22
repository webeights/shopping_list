import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';

class GroceriesList extends StatefulWidget {
  const GroceriesList({super.key});

  @override
  State<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends State<GroceriesList> {
  List<GroceryItem> groceryItem = [];

  void loadItem() async {
    final List<GroceryItem> groceryList = [];
    final url = Uri.https(
      'flutter-prep-e9d42-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    final response = await http.get(url);
    final Map<String, dynamic> responseData = json.decode(response.body);

    for (final item in responseData.entries) {
      final categs = categories.entries
          .firstWhere((categoryItem) =>
              categoryItem.value.title == item.value['category'])
          .value;

      groceryList.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: categs,
        ),
      );
    }
    setState(() {
      groceryItem = groceryList;
    });
  }

  @override
  void initState() {
    loadItem();
    super.initState();
  }

  void newItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );
  }

  void removeItem(GroceryItem item) {
    setState(() {
      groceryItem.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = groceryItem.isEmpty
        ? const Center(
            child: Text(
              'You have no items yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : ListView.builder(
            itemCount: groceryItem.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(groceryItem[index].id),
              child: ListTile(
                leading: Container(
                  width: 20,
                  height: 20,
                  color: groceryItem[index].category.color,
                ),
                title: Text(groceryItem[index].name),
                trailing: Text(groceryItem[index].quantity.toString()),
              ),
              onDismissed: (direction) {
                removeItem(groceryItem[index]);
              },
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: newItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: mainContent,
    );
  }
}
