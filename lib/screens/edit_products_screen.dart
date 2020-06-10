import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../widgets/image_input.dart';

class EditProductsScreen extends StatefulWidget {
  static const screenName = 'edit-products';

  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  String title = 'Add Prodcut';
  FocusNode _priceFocusNode;
  FocusNode _descriptionFocusNode;
  TextEditingController _imageUrlController;
  FocusNode _imageUrlNode;
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    description: '',
    id: null,
    imageUrl: '',
    price: 0.0,
    title: '',
    //isFavorite: false,
  );
  var _initProduct = {
    'title': '',
    'descrition': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true; //to make sure that i don't tun this too often
  var _isLoading = false;
  File _pickedImage;

  void _selectedImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  @override
  void initState() {
    super.initState();
    _priceFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _imageUrlController = TextEditingController();
    _imageUrlNode = FocusNode();
    _imageUrlNode.addListener(_updateImageUrl);
    //_form = GlobalKey<FormState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        title = 'Edit product';
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initProduct = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    // you need to dispode these focus nodes to avoid the memory leak
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_editedProduct.id != null) {
        //Edit exist product
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } else {
        //add new product
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }
    } catch (error) {
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('An error occured!'),
            content: Text(
              error.toString(),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Ok'))
            ],
          );
        },
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initProduct['title'],
                        decoration: InputDecoration(labelText: 'title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            description: null,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            imageUrl: null,
                            price: null,
                            title: value,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter the title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initProduct['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode),
                        onSaved: (value) {
                          _editedProduct = Product(
                            description: null,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            imageUrl: null,
                            price: double.parse(value),
                            title: _editedProduct.title,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter the price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'please enter a valid number.';
                          }
                          if (double.parse(value) < 0) {
                            return 'please enter a value greater than zero.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initProduct['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        textInputAction: TextInputAction.next,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_imageUrlNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            description: value,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            imageUrl: null,
                            price: _editedProduct.price,
                            title: _editedProduct.title,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Input Image Url')
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlController.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  description: _editedProduct.description,
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  imageUrl: value,
                                  price: _editedProduct.price,
                                  title: _editedProduct.title,
                                );
                              },
                              validator: (value) {
                                //TODO: validate the link of the image
                                /*if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'please enter a valid url.';
                          }
                          if (value.endsWith('.png') ||
                              value.endsWith('.jpg') ||
                              value.endsWith('.jpeg')) {
                            return 'please enter a valid url.';
                          }*/
                                return null;
                              },
                            ),
                          ),
                          
                        ],
                      ),
                      SizedBox(height: 10),
                      ImageInput(_selectedImage),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
