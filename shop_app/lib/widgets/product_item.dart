import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/products_detail_screen.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem({this.id, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    print("Buil item");
    return Card(
      elevation: 10,
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87.withOpacity(0.5),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            color: Theme.of(context).accentColor,
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border_sharp,
            ),
            onPressed: () async {
              try {
                await product.toggleFavoriteStatus(
                    authData.token, authData.userId);
                var scaffold = Scaffold.of(context);
                scaffold.showSnackBar(
                  SnackBar(
                    content: product.isFavorite == false
                        ? Text('Bạn đã hủy thích ${product.title}')
                        : Text('Bạn đã thích ${product.title}'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (error) {
                var scaffold = Scaffold.of(context);
                scaffold.showSnackBar(
                  SnackBar(
                    content: Text('Không thể sửa đổi yêu thích'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(
                product.id,
                product.price,
                product.title,
              );
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added item to cart!!',
                    textAlign: TextAlign.center,
                  ),
                  action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
