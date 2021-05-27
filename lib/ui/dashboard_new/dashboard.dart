import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterbuyandsell/config/ps_colors.dart';
import 'package:flutterbuyandsell/config/ps_config.dart';
import 'package:flutterbuyandsell/constant/ps_constants.dart';
import 'package:flutterbuyandsell/constant/ps_dimens.dart';
import 'package:flutterbuyandsell/constant/route_paths.dart';
import 'package:flutterbuyandsell/provider/category/category_provider.dart';
import 'package:flutterbuyandsell/provider/product/recent_product_provider.dart';
import 'package:flutterbuyandsell/repository/blog_repository.dart';
import 'package:flutterbuyandsell/repository/category_repository.dart';
import 'package:flutterbuyandsell/repository/item_location_repository.dart';
import 'package:flutterbuyandsell/repository/product_repository.dart';
import 'package:flutterbuyandsell/ui/common/dialog/error_dialog.dart';
import 'package:flutterbuyandsell/ui/common/ps_hero.dart';
import 'package:flutterbuyandsell/ui/common/ps_ui_widget.dart';
import 'package:flutterbuyandsell/utils/utils.dart';
import 'package:flutterbuyandsell/viewobject/common/ps_value_holder.dart';
import 'package:flutterbuyandsell/viewobject/default_photo.dart';
import 'package:flutterbuyandsell/viewobject/holder/intent_holder/item_entry_intent_holder.dart';
import 'package:flutterbuyandsell/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:optimized_cached_image/widgets.dart';
import '../../viewobject/holder/product_parameter_holder.dart';


class DashboardNew extends StatefulWidget {
  @override
  _DashboardNewState createState() => _DashboardNewState();
}

class _DashboardNewState extends State<DashboardNew>
    with TickerProviderStateMixin {
  PsValueHolder valueHolder;
  int _currentIndex = 0;
  AnimationController animationController;
  TabController _tabControllerFirst;
  TabController _tabControllerSecond;
  TabController _tabControllerThird;
  CategoryProvider _categoryProvider;
  CategoryRepository repo1;
  ProductRepository repo2;
  BlogRepository repo3;
  ItemLocationRepository repo4;
  RecentProductProvider _recentProductProvider;
  final userInputTEC = TextEditingController();

  Map<String, int> tabCount = {'Things': 4, 'Property': 3, 'Services': 2};

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initalizeTabControllers();
//    Crashlytics.instance.crash();
  }

  @override
  void dispose() {
    super.dispose();
    _tabControllerSecond.dispose();
    _tabControllerFirst.dispose();
    _tabControllerThird.dispose();
    userInputTEC.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              animationController.forward();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              animationController.reverse();
            }
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  List<String> _getTabs(int tabControllerLength) {
    switch (tabControllerLength) {
      case 4:
        return ['Buying', 'Selling', 'Renting', 'Exchanging'];
        break;
      case 3:
        return ['Buying', 'Selling', 'Renting'];
        break;
      case 2:
        return ['Doctors', 'Electricians'];
        break;
    }
  }

  void _initalizeTabControllers() {
    _tabControllerFirst = TabController(
      vsync: this,
      length: tabCount['Things'],
    );
    _tabControllerSecond = TabController(
      vsync: this,
      length: tabCount['Property'],
    );
    _tabControllerThird = TabController(
      vsync: this,
      length: tabCount['Services'],
    );
  }

  void _initAnimations() {
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 100), value: 1);
  }

  int getBottonNavigationIndex(int param) {
    int index = 0;
    switch (param) {
      case 0:
        index = 0;
        break;
      case 1:
        index = 1;
        break;
      case 2:
        index = 2;
        break;
      case 3:
        if (valueHolder.loginUserId != null && valueHolder.loginUserId != '') {
          index = 2;
        } else {
          index = 3;
        }
        break;
      case 4:
        index = 4;
        break;
      default:
        index = 0;
        break;
    }
    return index;
  }

  dynamic getIndexFromBottonNavigationIndex(int param) {
    int index = PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT;
    String title;
    final PsValueHolder psValueHolder =
        Provider.of<PsValueHolder>(context, listen: false);
    switch (param) {
      case 0:
        index = PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT;
        title = ''; //Utils.getString(context, 'app_name');
        break;
      case 1:
        index = PsConst.REQUEST_CODE__DASHBOARD_CATEGORY_FRAGMENT;
        title = Utils.getString(context, 'dashboard__categories');
        break;
      case 2:
        index = PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT;
        title = (psValueHolder == null ||
                psValueHolder.userIdToVerify == null ||
                psValueHolder.userIdToVerify == '')
            ? Utils.getString(context, 'home__bottom_app_bar_login')
            : Utils.getString(context, 'home__bottom_app_bar_verify_email');
        break;
      case 3:
        index = PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT;
        title =
            Utils.getString(context, 'dashboard__bottom_navigation_message');
        break;
      case 4:
        index = PsConst.REQUEST_CODE__DASHBOARD_SEARCH_FRAGMENT;
        title = Utils.getString(context, 'home__bottom_app_bar_search');
        break;

      default:
        index = 0;
        title = ''; //Utils.getString(context, 'app_name');
        break;
    }
    return <dynamic>[title, index];
  }
  
  void _search() {

    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5 * 1, 1.0, curve: Curves.elasticInOut)));
    
    Navigator.pushNamed(context, RoutePaths.home_item_search_view,arguments: [
      animation,
      animationController,
      ProductParameterHolder().getLatestParameterHolder(),
    ]);
    
  }

  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);
    repo1 = Provider.of<CategoryRepository>(context);
    repo2 = Provider.of<ProductRepository>(context);
    repo3 = Provider.of<BlogRepository>(context);
    repo4 = Provider.of<ItemLocationRepository>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CategoryProvider>(
            lazy: false,
            create: (BuildContext context) {
              _categoryProvider ??= CategoryProvider(
                  repo: repo1,
                  psValueHolder: valueHolder,
                  limit: PsConfig.CATEGORY_LOADING_LIMIT);
              _categoryProvider.loadCategoryList().then((dynamic value) {
                // Utils.psPrint("Is Has Internet " + value);
                final bool isConnectedToIntenet = value ?? bool;
                if (!isConnectedToIntenet) {
                  Fluttertoast.showToast(
                      msg: 'No Internet Connectiion. Please try again !',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blueGrey,
                      textColor: Colors.white);
                }
              });
              return _categoryProvider;
            }),
        ChangeNotifierProvider<RecentProductProvider>(
            lazy: false,
            create: (BuildContext context) {
              _recentProductProvider = RecentProductProvider(
                  repo: repo2, limit: PsConfig.RECENT_ITEM_LOADING_LIMIT);
              _recentProductProvider.productRecentParameterHolder
                  .itemLocationId = valueHolder.locationId;
              final String loginUserId = Utils.checkUserLoginId(valueHolder);
              _recentProductProvider.loadProductList(loginUserId,
                  _recentProductProvider.productRecentParameterHolder);
              return _recentProductProvider;
            }),
      ],
      child: Scaffold(
//      backgroundColor: Colors.white,
        body: buildSliver(),
        bottomNavigationBar: buildBottomNavBar(),
        floatingActionButton: buildFAB(),
      ),
    );
  }

  Widget buildSliver() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildNestedScrollView(
            text: 'Things', tabController: _tabControllerFirst),
        _buildNestedScrollView(
            text: 'Services', tabController: _tabControllerSecond),
        _buildNestedScrollView(
            text: 'Property', tabController: _tabControllerThird),
      ],
    );
  }

  Widget buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: getBottonNavigationIndex(_currentIndex),
      showUnselectedLabels: true,
      backgroundColor: PsColors.backgroundColor,
      selectedItemColor: PsColors.mainColor,
      elevation: 10,
      onTap: (int index) {
        getIndexFromBottonNavigationIndex(index);

        setState(() {
          _currentIndex = index;
        });
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.category),
          label: Utils.getString(context, 'Things'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.store,
            size: 20,
          ),
          label: Utils.getString(context, 'Property'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: Utils.getString(context, 'Services'),
        ),
      ],
    );
  }

  Widget buildFAB() {
    return FadeTransition(
      opacity: animationController,
      child: ScaleTransition(
        scale: animationController,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 1,
                  )
                ]),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  isExtended: true,
                  heroTag: null,
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                      Text(Utils.getString(context, 'Category'),
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: PsColors.black)),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            FloatingActionButton.extended(
              onPressed: () async {
                if (await Utils.checkInternetConnectivity()) {
                  Utils.navigateOnUserVerificationView(
                      _categoryProvider, context, () async {
                    final dynamic returnData = await Navigator.pushNamed(
                        context, RoutePaths.itemEntry,
                        arguments: ItemEntryIntentHolder(
                            flag: PsConst.ADD_NEW_ITEM, item: Product()));
                    if (returnData == true) {
                      _recentProductProvider.resetProductList(
                          valueHolder.loginUserId,
                          _recentProductProvider.productRecentParameterHolder);
                    }
                  });
                } else {
                  showDialog<dynamic>(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                          message: Utils.getString(
                              context, 'error_dialog__no_internet'),
                        );
                      });
                }
              },
              icon: Icon(Icons.camera_alt, color: PsColors.white),
              backgroundColor: PsColors.mainColor,
              label: Text(Utils.getString(context, 'dashboard__submit_ad'),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNestedScrollView({
    @required TabController tabController,
    @required String text,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext ctx, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Row(
                children: [
                  Text(text),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _search,
                  )
                ],
              ),
              backgroundColor: Colors.red,
              floating: true,
              pinned: true,
              bottom: PreferredSize(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: TabBar(
                      controller: tabController,
                      isScrollable: tabController.length > 3 ? true : false,
                      indicatorPadding: EdgeInsets.symmetric(horizontal: 20),
                      indicatorColor: Colors.black,
                      indicator: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          )),
                      labelPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      labelColor: Colors.black,
                      tabs: _getTabs(tabController.length)
                          .map((e) => Text(e))
                          .toList()),
                ),
                preferredSize: const Size(double.infinity, kToolbarHeight),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: List<Widget>.generate(
              tabController.length,
              (index) => Container(
                    child: GridView.builder(
                      itemCount: 10,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 0.65),
                      itemBuilder: (context, index) => _buildItem(index),
                    ),
                  )),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    return InkWell(
//      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: PsColors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: PsDimens.space4, vertical: PsDimens.space12),
          decoration: BoxDecoration(
            color: PsColors.backgroundColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          width: PsDimens.space180,
          // child:
          //  ClipPath(
          // child: Container(
          //   // color: Colors.white,
          //   width: PsDimens.space180,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: PsDimens.space4,
                  top: PsDimens.space4,
                  right: PsDimens.space12,
                  bottom: PsDimens.space4,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: PsDimens.space40,
                      height: PsDimens.space40,
                      child: PsNetworkCircleImageForUser(
                        photoKey: '',
                        imagePath:
                            'https://miro.medium.com/max/560/1*MccriYX-ciBniUzRKAUsAw.png',
                        // width: PsDimens.space40,
                        // height: PsDimens.space40,
                        boxfit: BoxFit.cover,
                        onTap: () {
//                              Utils.psPrint(product.defaultPhoto.imgParentId);
//                              onTap();
                        },
                      ),
                    ),
                    const SizedBox(width: PsDimens.space8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: PsDimens.space8, top: PsDimens.space8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(Utils.getString(context, 'default__user_name'),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyText1),
//                                if (product.paidStatus ==
//                                    PsConst.PAID_AD_PROGRESS)
//                                  Text(
//                                      Utils.getString(
//                                          context, 'paid_ad__sponsor'),
//                                      textAlign: TextAlign.start,
//                                      style: Theme.of(context)
//                                          .textTheme
//                                          .caption
//                                          .copyWith(color: PsColors.mainColor))
//                                else
                            Text('2 years ago}',
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.caption)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Stack(
              //   children: <Widget>[

              Expanded(
                child: CachedNetworkImage(
                  placeholder: (BuildContext context, String url) {
                    return const CircularProgressIndicator();
                  },
                  width: 100,
                  height: 100,
//                          fit: BoxFit.cover,
                  imageUrl:
                      'https://media.croma.com/image/upload/f_auto,q_auto,d_Croma%20Assets:no-product-image.jpg,h_260,w_260/v1605337269/Croma%20Assets/Entertainment/Headphones%20and%20Earphones/Images/8984566267934.png',
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          Image.asset(
                    'assets/images/placeholder_image.png',
                    // width: width,
                    // height: height,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                    left: PsDimens.space8,
                    top: PsDimens.space12,
                    right: PsDimens.space8,
                    bottom: PsDimens.space4),
                child: Text(
                  'Earphones for Buy',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText2,
                  maxLines: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: PsDimens.space8,
                    top: PsDimens.space4,
                    right: PsDimens.space8),
                child: Row(
                  children: <Widget>[
                    Material(
                      type: MaterialType.transparency,
                      child: Text(Utils.getString(context, 'item_price_free'),
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(color: PsColors.mainColor)),
                    ),
                    Flexible(
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: PsDimens.space8, right: PsDimens.space8),
                          child: Text('(NEW)',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: PsColors.mainColor))),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: PsDimens.space8,
                    top: PsDimens.space12,
                    right: PsDimens.space8,
                    bottom: PsDimens.space4),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/baseline_pin_black_24.png',
                      width: PsDimens.space10,
                      height: PsDimens.space10,
                      fit: BoxFit.contain,

                      // ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: PsDimens.space8, right: PsDimens.space8),
                        child: Text('Denver',
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.caption))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: PsDimens.space8,
                    right: PsDimens.space8,
                    bottom: PsDimens.space16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: PsDimens.space8,
                          height: PsDimens.space8,
                          decoration: BoxDecoration(
                              color: PsColors.itemTypeColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(PsDimens.space4))),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: PsDimens.space8, right: PsDimens.space4),
                            child: Text('Earphones',
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.caption))
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/images/baseline_favourite_grey_24.png',
                          width: PsDimens.space10,
                          height: PsDimens.space10,
                          fit: BoxFit.contain,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: PsDimens.space4,
                          ),
                          child: Text('2',
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.caption),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ),
          // clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        ),
      ),
    );
  }
}
