import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/entities/entity_actions_dialog.dart';
import 'package:invoiceninja_flutter/ui/app/help_text.dart';
import 'package:invoiceninja_flutter/ui/app/lists/list_divider.dart';
import 'package:invoiceninja_flutter/ui/app/loading_indicator.dart';
import 'package:invoiceninja_flutter/ui/product/product_list_item.dart';
import 'package:invoiceninja_flutter/ui/product/product_list_vm.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:redux/src/store.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  final ProductListVM viewModel;

  @override
  Widget build(BuildContext context) {
    if (!viewModel.isLoaded) {
      return viewModel.isLoading ? LoadingIndicator() : SizedBox();
    } else if (viewModel.productList.isEmpty) {
      return HelpText(AppLocalization.of(context).noRecordsFound);
    }

    return _buildListView(context);
  }

  Widget _buildListView(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    final listUIState = store.state.uiState.productUIState.listUIState;
    final isInMultiselect = listUIState.isInMultiselect();

    return RefreshIndicator(
      onRefresh: () => viewModel.onRefreshed(context),
      child: ListView.separated(
          separatorBuilder: (context, index) => ListDivider(),
          itemCount: isInMultiselect
              ? viewModel.productList.length + 1
              : viewModel.productList.length,
          itemBuilder: (BuildContext context, index) {
            // Add header
            if (index == 0 && isInMultiselect) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) =>
                            _toggleSelectionForAll(store, context),
                        activeColor: Theme.of(context).accentColor,
                        value: listUIState.selectedEntities.length ==
                            viewModel.productList.length),
                  ),
                ],
              );
            }

            if (isInMultiselect) {
              index--;
            }

            final productId = viewModel.productList[index];
            final product = viewModel.productMap[productId];

            void showDialog() => showEntityActionsDialog(
                entities: [product],
                context: context,
                userCompany: viewModel.state.userCompany,
                onEntityAction: viewModel.onEntityAction);

            return ProductListItem(
              userCompany: viewModel.state.userCompany,
              filter: viewModel.filter,
              product: product,
              onEntityAction: (EntityAction action) {
                if (action == EntityAction.more) {
                  showDialog();
                } else {
                  viewModel.onEntityAction(context, [product], action);
                }
              },
              onTap: () => viewModel.onProductTap(context, product),
              onLongPress: () async {
                final longPressIsSelection =
                    store.state.uiState.longPressSelectionIsDefault ?? true;
                if (longPressIsSelection) {
                  viewModel.onEntityAction(
                      context, [product], EntityAction.toggleMultiselect);
                } else {
                  showDialog();
                }
              },
              isChecked: isInMultiselect && listUIState.isSelected(product),
            );
          }),
    );
  }

  void _toggleSelectionForAll(Store<AppState> store, BuildContext context) {
    final products = viewModel.productList
        .map<ProductEntity>((productId) => viewModel.productMap[productId])
        .toList();

    viewModel.onEntityAction(context, products, EntityAction.toggleMultiselect);
  }
}
