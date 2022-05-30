import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductScreen({Key key}) : super(key: key);

  Future<void> refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding..');
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder(
        future: refreshProducts(context),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapshot.error != null) {
            return Center(
              child: Text('An Error Occured'),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => refreshProducts(context),
              child: Consumer<Products>(
                builder: (context, productsData, _) => Padding(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (context, index) => Column(children: [
                            UserProductItem(
                              product: productsData.items[index],
                            ),
                            Divider(),
                          ])),
                ),
              ),
            );
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
