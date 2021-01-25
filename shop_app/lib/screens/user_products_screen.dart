import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-product';

  Future<void> _refreshProducts(BuildContext context) async {
    try {
      await Provider.of<Products>(context, listen: false)
          .fetchAndSetProduct(false);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Xảy ra lỗi!!"),
          content: Text(error.toString()),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Navigator.of(context).pop();
                },
                child: Text("Rời Khỏi")),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding....");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              }),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (_, i) => Column(
                                  children: [
                                    UserProductItem(
                                      id: productsData.items[i].id,
                                      title: productsData.items[i].title,
                                      imageUrl: productsData.items[i].imageUrl,
                                    ),
                                    Divider(),
                                  ],
                                )),
                      ),
                    )),
      ),
      drawer: AppDrawer(),
    );
  }
}
