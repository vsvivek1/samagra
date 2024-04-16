import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final List<dynamic> items;
  final ValueChanged<String>? onChanged;

  const SearchableDropdown({
    Key? key,
    required this.items,
    this.onChanged,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              if (_searchController.text.isNotEmpty &&
                  !item
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())) {
                return SizedBox.shrink();
              }
              return ListTile(
                title: Text(item['material_name']),
                onTap: () {
                  if (widget.onChanged != null) {
                    widget.onChanged!(item['material_name']);
                  }
                  Navigator.pop(context); // Close the dropdown after selection
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
