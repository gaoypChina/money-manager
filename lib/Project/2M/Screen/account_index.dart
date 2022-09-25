import 'dart:io';
import 'dart:typed_data';

import 'package:coresystem/Core/CacheService.dart';
import 'package:coresystem/Project/2M/Contains/skin/color_skin.dart';
import 'package:coresystem/Project/2M/LocalDatabase/model_lib.dart';
import 'package:coresystem/Project/2M/Module/Category/DA/category_controller.dart';
import 'package:coresystem/Project/2M/Module/Money/DA/money_controller.dart';
import 'package:coresystem/Project/2M/Module/Wallet/DA/wallet_controller.dart';
import 'package:coresystem/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../Components/base_component.dart';
import '../../../Core/routes.dart';
import '../../../Core/userService.dart';
import '../../../Utils/PickImage/imagePickerHandler.dart';
import '../Contains/constants.dart';
import '../Contains/skin/typo_skin.dart';
import '../Module/User/DA/user_controller.dart';
import '../Module/User/Logout/handle_log_out.dart';
import 'transaction_index.dart';

class AccountIndex extends StatefulWidget {
  const AccountIndex({Key key}) : super(key: key);

  @override
  State<AccountIndex> createState() => _AccountIndexState();
}

class _AccountIndexState extends State<AccountIndex>
    with TickerProviderStateMixin, ImagePickerListener {
  UserControl userController = UserControl();
  MoneyController moneyController = Get.find();
  CategoryController categoryController = Get.find();
  WalletController walletController = Get.find();
  final _mainMenu = [
    {
      'title': 'Thông tin tài khoản',
      'icon': FFilled.ticket,
      'route': CoreRouteNames.ACCOUNT_INFO
    },
  ];

  AnimationController _controller;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  ImagePickerHandler imagePicker;

  File _imagesFile;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker = ImagePickerHandler(
      this,
      _controller,
      chooseMutil: false,
    );
    imagePicker.init();
    _initPackageInfo();
    if (UserService.getAvtUsername != null) {
      _imagesFile = File(UserService.getAvtUsername);
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void clearAllData() {
    popupWithStatus(
      context,
      backGroundAvatar: FColorSkin.transparent,
      typePopup: TypePopup.error,
      textTitle: 'Bạn có chắc muốn xoá dữ liệu?',
      childSubtitle: Text(
        'Nếu bạn xoá hết dữ liệu, mọi thông tin chi tiêu đã lưu sẽ không thể khôi phục.',
        style: FTextStyle.regular14_22.copyWith(color: FColorSkin.primaryText),
        textAlign: TextAlign.center,
      ),
      textCancel: 'Huỷ',
      actionCancel: () {
        CoreRoutes.instance.pop();
      },
      backGroundAction: FColorSkin.errorPrimary,
      textAction: 'Xoá toàn bộ',
      action: () async {
        // await moneyController.deleteAllMoneyNote();
        await categoryController.deleteAllCategory();
        await walletController.delAllWallet();
        await Hive.deleteFromDisk();
        await HiveDB().initDefaultList();
        await GetControl().reStartGetData();
        RestartWidget.restartApp(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: FColorSkin.grey3_background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: Stack(
            children: [
              Container(
                height: 65,
                color: FColorSkin.grey1_background,
              ),
              SafeArea(
                  child: FListTile(
                padding: EdgeInsets.fromLTRB(16, 0, 8, 16),
                size: FListTileSize.size72,
                avatar: GestureDetector(
                  onTap: () {
                    imagePicker.showDialog(context);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      FBoundingBox(
                          shape: FBoxShape.circle,
                          backgroundColor: FColorSkin.disable,
                          size: FBoxSize.size48,
                          child: _imagesFile != null
                              ? Image.file(
                                  _imagesFile,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                )
                              : FIcon(
                                  icon: FFilled.user,
                                  color: FColorSkin.grey9_background,
                                  size: 20,
                                )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: FBoundingBox(
                          shape: FBoxShape.circle,
                          backgroundColor: FColorSkin.grey3_background,
                          size: FBoxSize.size20,
                          child: FIcon(
                            icon: FFilled.camera,
                            color: FColorSkin.secondaryText,
                            size: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  'Nguyễn Văn Chien',
                  style: FTypoSkin.title3.copyWith(
                    color: FColorSkin.title,
                  ),
                ),
                action: actionAppbar(context),
              )),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 16,
            ),
            ...List.generate(_mainMenu.length, (index) {
              final item = _mainMenu[index];
              return FListTile(
                size: FListTileSize.size56,
                onTap: () {
                  CoreRoutes.instance.navigateToRouteString(item['route']);
                },
                padding: EdgeInsets.only(left: 16),
                border: Border(
                    bottom: BorderSide(color: FColorSkin.grey3_background)),
                avatar: FIcon(
                  icon: item['icon'],
                  size: 20,
                  color: FColorSkin.subtitle,
                ),
                title: Text(
                  item['title'],
                  style: FTypoSkin.title4.copyWith(color: FColorSkin.title),
                ),
                action: Container(
                  padding: EdgeInsets.only(right: 16),
                  child: FIcon(
                    icon: FOutlined.right,
                    color: FColorSkin.title,
                    size: 16,
                  ),
                ),
              );
            }),
            Container(
              padding: EdgeInsets.fromLTRB(0, 24, 0, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Version ${_packageInfo.version}',
                    style: FTypoSkin.bodyText2
                        .copyWith(color: FColorSkin.secondaryText),
                  )
                ],
              ),
            ),
            FFilledButton(
                backgroundColor: FColorSkin.grey4_background,
                child: Text(
                  'Clear All Data',
                  style: FTypoSkin.buttonText2
                      .copyWith(color: FColorSkin.secondaryText),
                ),
                onPressed: () {
                  clearAllData();
                  // walletController.delAllWallet();
                })
          ],
        ),
      ),
    );
  }

  @override
  userImageList(List<File> _image) {
    // var imgFile = File.fromRawPath();
    var imgFile = _image[0];

    setState(() {
      UserService.setAvtUsername(imgFile.path);
      this._imagesFile = imgFile;
    });
  }
}
