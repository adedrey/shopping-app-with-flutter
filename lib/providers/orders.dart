import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  final String authToken;

  List<OrderItem> _orders = [];
  final String userId;

  Orders(this.authToken, this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://isabella-ed317-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final List<OrderItem> loadedOrders = [];
      final response = await http.get(url);
      final extractedOrders =
          json.decode(response.body) as Map<String, dynamic>;
      if (extractedOrders == null) {
        return;
      }
      extractedOrders.forEach((orderId, order) {
        loadedOrders.add(OrderItem(
            id: orderId,
            amount: order['amount'],
            dateTime: DateTime.parse(order['dateTime']),
            products: (order['products'] as List<dynamic>)
                .map((prod) => CartItem(
                    id: prod['id'],
                    productId: prod['productId'],
                    title: prod['title'],
                    price: prod['price'],
                    quantity: prod['quantity']))
                .toList()));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // ...
    final url = Uri.parse(
        'https://isabella-ed317-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cartProd) => {
                    'id': cartProd.productId,
                    'title': cartProd.title,
                    'quantity': cartProd.quantity,
                    'price': cartProd.price,
                  })
              .toList()
        }),
      );
      final newOrder = OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timeStamp,
          products: cartProducts);
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (err) {}
  }
}
