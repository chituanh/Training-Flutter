import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as ord;

class OrdersItem extends StatefulWidget {
  final ord.OrderItem order;

  OrdersItem(this.order);

  @override
  _OrdersItemState createState() => _OrdersItemState();
}

class _OrdersItemState extends State<OrdersItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.linear,
        height: _expanded == false
            ? 95
            : 95 +
                min(
                  widget.order.products.length * 30.0 + 10,
                  180,
                ),
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  title: Text("\$${widget.order.amount.toStringAsFixed(2)}"),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy hh:mm')
                        .format(widget.order.dateTime),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    icon:
                        Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  ),
                ),
                if (_expanded)
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    curve: Curves.linear,
                    height: _expanded
                        ? min(
                            widget.order.products.length * 30.0 + 10,
                            180,
                          )
                        : 0,
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: widget.order.products
                          .map((prod) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      prod.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${prod.quantity}x - \$${prod.price}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
