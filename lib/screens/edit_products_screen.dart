import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_model.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/editProductScreen';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  late String id = "";
  late String title = "";
  late String description = "";
  late double price = 0;
  late String imageUrl = "";
  late Product _editedProduct;
  List<String> valid3 = ['jpg', 'gif', 'png', 'bmp'];
  List<String> valid4 = ['jpeg', 'webp', 'wbmp'];
  bool _isInit = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;
      var fetchId = ModalRoute.of(context)?.settings.arguments;
      if (fetchId != null) {
        id = fetchId as String;
        _editedProduct = Provider.of<ProductsProvider>(context).findById(id);
        title = _editedProduct.title;
        description = _editedProduct.title;
        price = _editedProduct.price;
        imageUrl = _editedProduct.imageUrl;
        _imageUrlController.text = imageUrl;
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  bool _checkImageUrlValid(String url) {
    bool validUrl = Uri.parse(url).isAbsolute;
    if (!validUrl) {
      return false;
    }
    String last3 = url.substring(url.length - 3).toLowerCase();
    String last4 = url.substring(url.length - 4).toLowerCase();
    if (valid3.contains(last3) || valid4.contains(last4)) {
      return true;
    }
    return false;
  }

  Widget validImagePreview(String url) {
    if (_checkImageUrlValid(url) || url.isEmpty) {
      imageUrl = url;
    }
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.only(top: 8, right: 10),
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
      child: _checkImageUrlValid(imageUrl)
          ? FittedBox(
              child: Image.network(
                imageUrl,
                errorBuilder: ((context, error, stackTrace) {
                  return Text('Check URL');
                }),
              ),
              fit: BoxFit.contain,
            )
          : Center(child: Text('Enter a URL')),
    );
  }

  void _saveForm() {
    bool isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    if (id.isEmpty) {
      id = DateTime.now().toString();
    }
    _editedProduct = Product(
        id: id,
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl);
    final products = Provider.of<ProductsProvider>(context, listen: false);
    products.addUpdateProduct(_editedProduct);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Product'),
          actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
              key: _form,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      initialValue: title,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        title = value!;
                      },
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: 'Price'),
                        initialValue: price.toString(),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please provide a valid price';
                          }
                          if (double.parse(value) < 0) {
                            return 'Please provide a price greater than zero';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          if (double.tryParse(value!) != null) {
                            price = double.parse(value);
                          } else {
                            price = 0;
                          }
                        }),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: description,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a description';
                        }
                        if (value.length < 10) {
                          return 'Minimum length of description is 10 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        description = value!;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        validImagePreview(_imageUrlController.text),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () => setState(() {}),
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) => _saveForm(),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a URL';
                              }
                              if (!_checkImageUrlValid(value)) {
                                return 'Please provide a valid  Image URL';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              imageUrl = value!;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )),
        ));
  }
}
