import 'package:calendar/entity/enum/e_variable.dart';
import 'package:calendar/entity/helper/colors.dart';
import 'package:calendar/providers/local/product_type_provider.dart';
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

class ProductTypeScreen extends StatefulWidget {
  const ProductTypeScreen({super.key});

  @override
  State<ProductTypeScreen> createState() => _ProductTypeScreenState();
}

class _ProductTypeScreenState extends State<ProductTypeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> _refreshData(ProductTypeProvider provider) async {
    return await provider.getHome();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductTypeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('ប្រភេទផលិតផល'),
            centerTitle: true,
            bottom: CustomHeader(),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: Colors.blue[800],
              backgroundColor: Colors.white,
              onRefresh: () => _refreshData(provider),
              child:
                  provider.isLoading
                      ? Center(child: Text('Loading...'))
                      : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            if (provider.productType != null &&
                                provider.productType!['data'] != null &&
                                (provider.productType!['data'] as List)
                                    .isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    (provider.productType!['data'] as List)
                                        .length,
                                itemBuilder: (context, index) {
                                  final data =
                                      provider.productType!['data'] as List;
                                  return Dismissible(
                                    key: Key(data[index]['id'].toString()),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      color: Colors.red,
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      return await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirm Delete'),
                                            content: Text(
                                              'Are you sure you want to delete this product type?',
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(false),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(true),
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    onDismissed: (direction) async {
                                      final id = data[index]['id'];
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      ); // capture valid context
                                      final success = await provider
                                          .deleteProduct(id);
    
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'លុបបានដោយជោគជ័យ'
                                                : provider.error ??
                                                    '${provider.error}.',
                                          ),
                                          backgroundColor:
                                              success
                                                  ? Colors.green
                                                  : Colors.black,
                                        ),
                                      );
                                    },
    
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: HColors.darkgrey
                                                .withOpacity(0.2),
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child: Card(
                                        margin: EdgeInsets.only(bottom: 0),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 24,
                                            backgroundColor: HColors.darkgrey
                                                .withOpacity(0.1),
                                            child:
                                                data[index]['image'] !=
                                                            null &&
                                                        data[index]['image']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      mainUrlFile +
                                                          data[index]['image'],
                                                      height: 25,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Icon(
                                                          Icons.category,
                                                          color:
                                                              HColors
                                                                  .darkgrey,
                                                        );
                                                      },
                                                    )
                                                    : Icon(
                                                      Icons.category,
                                                      color: HColors.darkgrey,
                                                    ),
                                          ),
    
                                          title: Text(
                                            data[index]['name'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${data[index]['n_of_products'] ?? '0'} products',
                                            style: TextStyle(
                                              color: HColors.darkgrey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          onTap: () {
                                            context.push('/product-type-update/${data[index]['id']}/${Uri.encodeComponent(data[index]['image'])}/${Uri.encodeComponent(data[index]['name'])}');
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No product types found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}
