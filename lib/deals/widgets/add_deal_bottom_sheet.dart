import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/place_data.dart';
import '../data/quality_data.dart';
import '../data/price_data.dart';
import '../../books/models/book.dart';
import '../../deals/deals_provider.dart';

class AddDealBottomSheet extends StatefulWidget {
  final Book book;

  AddDealBottomSheet(this.book);

  @override
  _AddDealBottomSheetState createState() => _AddDealBottomSheetState();
}

class _AddDealBottomSheetState extends State<AddDealBottomSheet> {
  var _price = '';
  var _quality = '';
  var _place = '';
  var _description = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa_rounded,
                  size: 65, color: Theme.of(context).primaryColor),
              DropdownButtonFormField(
                hint: Text('Select price'),
                onChanged: (value) => setState(() {
                  _price = value;
                }),
                items: prices
                    .map((price) =>
                        DropdownMenuItem(child: Text(price), value: price))
                    .toList(),
              ),
              DropdownButtonFormField(
                hint: Text('Select quality'),
                onChanged: (value) => setState(() {
                  _quality = value;
                }),
                items: qualities
                    .map((quality) =>
                        DropdownMenuItem(child: Text(quality), value: quality))
                    .toList(),
              ),
              DropdownButtonFormField(
                hint: Text('Select place'),
                onChanged: (value) => setState(() {
                  _place = value;
                }),
                items: places
                    .map((place) =>
                        DropdownMenuItem(child: Text(place), value: place))
                    .toList(),
              ),
              TextField(
                maxLength: 150,
                minLines: 3,
                maxLines: 3,
                decoration:
                    InputDecoration(labelText: 'Description (Optional)'),
                onChanged: (value) => _description = value,
              ),
              ElevatedButton(
                  onPressed: (_price.isEmpty ||
                          _quality.isEmpty ||
                          _place.isEmpty)
                      ? null
                      : () async {
                          // get data before popping screen
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          final errorColor = Theme.of(context).errorColor;
                          final primaryColor = Theme.of(context).primaryColor;
                          // pop screen
                          Navigator.of(context).pop();
                          // try adding the deal
                          final result =
                              await context.read<DealsProvider>().addDeal(
                                    book: widget.book,
                                    price: _price,
                                    quality: _quality,
                                    place: _place,
                                    description: _description,
                                  );
                          // check if an error occured
                          if (!result) {
                            // remove snackbar if existing and show a new with error message
                            final errorMessage =
                                context.read<DealsProvider>().errorMessage;
                            scaffoldMessenger.hideCurrentSnackBar();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                backgroundColor: errorColor,
                                content: Text(errorMessage),
                              ),
                            );
                          }
                          if (result) {
                            // remove snackbar if existing and show a new with error message
                            scaffoldMessenger.hideCurrentSnackBar();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                backgroundColor: primaryColor,
                                content: Text('Succesfully added deal'),
                              ),
                            );
                          }
                        },
                  child: Text('Add deal'))
            ],
          ),
        ),
      ),
    );
  }
}
