import 'package:coresystem/Project/2M/LocalDatabase/Models/wallet_item.dart';
import 'package:coresystem/Project/2M/LocalDatabase/model_lib.dart';
import 'package:coresystem/Project/2M/Module/Category/DA/category_controller.dart';
import 'package:coresystem/Project/2M/Module/Money/DA/money_controller.dart';
import 'package:coresystem/Utils/ConvertUtils.dart';
import 'package:get/get.dart';

import '../../../../../Components/widgets/SnackBar.dart';
import '../../../../../Core/CacheService.dart';
import '../../../../../Core/routes.dart';

class WalletController extends GetxController {
  final RxList<WalletItem> _walletList = <WalletItem>[].obs;
  WalletItem walletChoose = WalletItem();

  // save wallet before when edit money note
  WalletItem walletChoosedBefore = WalletItem();

  RxInt idWallet = 0.obs;

  @override
  void onInit() {
    // delAllWallet();
    getWalletList();
    super.onInit();
  }

  int get totalMoneyinWallets {
    var moneyList = _walletList.map((element) => element.moneyWallet);
    return moneyList.reduce((a, b) => a + b);
  }

  // get category list
  List<WalletItem> get walletList {
    return [..._walletList];
  }

  // get index UI cate
  void getIndex(int index) {
    idWallet.value = index;
    walletChoose = _walletList[idWallet.value];
  }

  String get showNameWallet =>
      '${idWallet != null ? _walletList[idWallet.value].title : _walletList?.first?.title}';

  Future getWalletList() async {
    final lst = await getAllWallet();
    _walletList.assignAll(lst);
    if (_walletList != null && _walletList.length != 0) {
      walletChoose = _walletList.first;
      walletChoosedBefore = walletChoose;
    }
  }

  Future addWallet(String id, String name, {MoneyItem editMoneyItem}) async {
    if (_walletList.any((element) => element.title == name) &&
        editMoneyItem == null) {
      await SnackBarCore.warning(title: 'Trùng tên Wallet, hãy thử lại');
      return;
    }
    if (_walletList.any((element) => element.iD == id)) {
      // edit old wallet
      var indexEditWallet =
          _walletList.indexWhere((element) => element.iD == id);
      var editWalletObj = _walletList.firstWhere((element) => element.iD == id);
      if (editMoneyItem != null) {
        // Lấy ví cũ trừ or cộng thêm số tiền mới ở lần chỉnh sửa giao dịch tiền.
        if (walletChoosedBefore.iD != null) {
          if (walletChoosedBefore?.iD != walletChoose?.iD) {
            indexEditWallet = _walletList
                .indexWhere((element) => element.iD == walletChoosedBefore.iD);
            editWalletObj = walletChoosedBefore;
            var indexNewWalletChoose = _walletList
                .indexWhere((element) => element.iD == walletChoose.iD);
            if (editMoneyItem.moneyType == '0') {
              // chi tieu
              editWalletObj.moneyWallet += editMoneyItem.moneyValue.round();
              walletChoose.moneyWallet -= editMoneyItem.moneyValue.round();
              await CacheService.edit<WalletItem>(
                  indexNewWalletChoose, walletChoose);
            } else {
              ///TODO wallet
              // thu nhap
              editWalletObj.moneyWallet -= editMoneyItem.moneyValue.round();
              walletChoose.moneyWallet += editMoneyItem.moneyValue.round();
              await CacheService.edit<WalletItem>(
                  indexNewWalletChoose, walletChoose);
            }
          }
        } else {
          // edit money in wallet when add money note
          if (editMoneyItem.moneyType == '0') {
            editWalletObj.moneyWallet -= editMoneyItem.moneyValue.round();
          } else {
            editWalletObj.moneyWallet += editMoneyItem.moneyValue.round();
          }
        }
      } else {
        // edit wallet
        editWalletObj.title = name;
      }
      await CacheService.edit<WalletItem>(indexEditWallet, editWalletObj);
      _walletList[indexEditWallet] = editWalletObj;
      _walletList.refresh();
      if (editMoneyItem == null) {
        CoreRoutes.instance.pop();
      }
    } else {
      // add new wallet
      final WalletItem obj = WalletItem(
        iD: id,
        title: name,
        avt: '',
        moneyWallet: 0,
        creWalletDate: DateTime.now(),
      );
      await CacheService.add<WalletItem>(id, obj);
      _walletList.insert(0, obj);
      idWallet.value = _walletList.indexWhere((element) => element.iD == id);
      walletChoose = _walletList[idWallet.value];
      _walletList.refresh();
      CoreRoutes.instance.pop();
    }
    await SnackBarCore.success();
  }

  Future<List<WalletItem>> getAllWallet() async {
    final rs = await CacheService.getAll<WalletItem>();
    return rs;
  }

  Future<void> deleteThisWallet(String id) async {
    await CacheService.delete<WalletItem>(id);
    await SnackBarCore.success();
    _walletList.removeWhere((element) => element.iD == id);
    _walletList.refresh();
  }

  Future<void> delAllWallet() async {
    await CacheService.clear<WalletItem>();
  }
}
