
import 'package:calendar/entity/helper/colors.dart';
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/providers/local/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> _refreshData(ProductProvider provider) async {
    return await provider.getHome();
  }
  

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        // Derive categories dynamically from productData
        final List<String> categories =
            (provider.productData != null &&
                    provider.productData?['data'] is List)
                ? [
                    'All',
                    ...(provider.productData!['data']
                            .map((product) => product['type']?['name'] as String?)
                            .where((name) => name != null)
                            .toSet()
                            .cast<String>()
                            .toList()),
                  ]
                : ['All'];
    
        // Map API data to products
        final List<Map<String, dynamic>> products =
            (provider.productData != null &&
                    provider.productData?['data'] is List)
                ? (provider.productData!['data'] as List).map((item) {
                    return {
                      'id': item['id'], // Added for deletion
                      'category': item['type']?['name'] ?? 'Unknown',
                      'code': item['code'] ?? '',
                      'name': item['name'] ?? '',
                      'price': item['unit_price'] != null
                          ? '${item['unit_price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ៛'
                          : '0 ៛',
                      'image': item['image'] ?? '',
                    };
                  }).toList()
                : [];
    
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'ផលិតផល',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
            bottom: CustomHeader(),
          ),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Colors.blue[800],
            backgroundColor: Colors.white,
            onRefresh: () => _refreshData(provider),
            child: provider.isLoading
                ? Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        ),
                        Text(
                          'សូមរងចាំ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                : provider.error != null
                    ? Center(child: Text('Something went wrong'))
                    : SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category tabs
                            SizedBox(
                              height: 50,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(categories.length, (
                                  index,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(categories[index]),
                                      checkmarkColor: Colors.white,
                                      selected: _selectedTabIndex == index,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedTabIndex = index;
                                        });
                                      },
                                      selectedColor: HColors.blue,
                                      labelStyle: TextStyle(
                                        color: _selectedTabIndex == index
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        side: BorderSide(
                                          color: HColors.darkgrey.withOpacity(
                                            0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
    
                            // Product list
                            if (_filteredProducts(products, categories).isEmpty)
                              Center(
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('គ្មានទិន្នន័យ'),
                                ),
                              )
                            else
                              Column(
                                children: List.generate(
                                  _filteredProducts(products, categories)
                                      .length,
                                  (index) {
                                    final product = _filteredProducts(
                                        products, categories)[index];
                                    return InkWell(
                                      onTap: (){
                                        context.push('/product-detail/${product['id']}');
                                      },
                                      child: Dismissible(
                                        key: Key(product['id'].toString()),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 16),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        confirmDismiss: (direction) async {
                                          return await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('លុបផលិតផល'),
                                              content: Text(
                                                  'តើអ្នកប្រាកដទេថាចង់លុប ${product['name']}?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: Text('បោះបង់'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: Text('លុប'),
                                                ),
                                              ],
                                            ),
                                          ) ?? false;
                                        },
                                        onDismissed: (direction) async {
                                          await provider.deleteProduct(
                                              product['id']);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'បានលុប ${product['name']}'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: ProductItem(
                                          category:
                                              '${product['category']} | ${product['code']}',
                                          name: product['name'],
                                          price: product['price'],
                                          image: product['image'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }
}

int _selectedTabIndex = 0;

List<Map<String, dynamic>> _filteredProducts(
    List<Map<String, dynamic>> products, List<String> categories) {
  if (_selectedTabIndex == 0) return products;
  final selectedCategory = categories[_selectedTabIndex];
  return products
      .where(
        (product) =>
            product['category'].startsWith(selectedCategory) ||
            (selectedCategory == 'Food' &&
                product['category'].startsWith('Food')),
      )
      .toList();
}

class ProductItem extends StatelessWidget {
  final String category;
  final String name;
  final String price;
  final String image;

  const ProductItem({
    super.key,
    required this.category,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: HColors.darkgrey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              'https://pos-v2-file.uat.camcyber.com/$image',
              width: 65,
              height: 65,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 65,
                height: 65,
                color: Colors.grey[300],
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: HColors.darkgrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
