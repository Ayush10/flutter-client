import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/product/product_actions.dart';
import 'package:redux/redux.dart';

import 'product_screen.dart';

class ProductScreenBuilder extends StatelessWidget {
  const ProductScreenBuilder({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ProductScreenVM>(
      //rebuildOnChange: true,
      converter: ProductScreenVM.fromStore,
      builder: (context, vm) {
        return ProductScreen(
          viewModel: vm,
        );
      },
    );
  }
}

class ProductScreenVM {
  ProductScreenVM({
    @required this.isInMultiselect,
    @required this.userCompany,
    @required this.onEntityAction,
  });

  final bool isInMultiselect;
  final UserCompanyEntity userCompany;
  final Function(BuildContext, List<BaseEntity>, EntityAction) onEntityAction;

  static ProductScreenVM fromStore(Store<AppState> store) {
    final state = store.state;

    return ProductScreenVM(
      userCompany: state.userCompany,
      isInMultiselect: state.productListState.isInMultiselect(),
      onEntityAction: (BuildContext context, List<BaseEntity> products,
              EntityAction action) =>
          handleProductAction(context, products, action),
    );
  }
}
