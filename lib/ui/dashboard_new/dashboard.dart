import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterbuyandsell/config/ps_colors.dart';
import 'package:flutterbuyandsell/config/ps_config.dart';
import 'package:flutterbuyandsell/constant/ps_constants.dart';
import 'package:flutterbuyandsell/constant/ps_dimens.dart';
import 'package:flutterbuyandsell/constant/route_paths.dart';
import 'package:flutterbuyandsell/provider/category/category_provider.dart';
import 'package:flutterbuyandsell/provider/product/recent_product_provider.dart';
import 'package:flutterbuyandsell/provider/product/search_product_provider.dart';
import 'package:flutterbuyandsell/repository/blog_repository.dart';
import 'package:flutterbuyandsell/repository/category_repository.dart';
import 'package:flutterbuyandsell/repository/item_location_repository.dart';
import 'package:flutterbuyandsell/repository/product_repository.dart';
import 'package:flutterbuyandsell/ui/common/dialog/error_dialog.dart';
import 'package:flutterbuyandsell/ui/common/ps_ui_widget.dart';
import 'package:flutterbuyandsell/utils/utils.dart';
import 'package:flutterbuyandsell/viewobject/common/ps_value_holder.dart';
import 'package:flutterbuyandsell/viewobject/holder/intent_holder/item_entry_intent_holder.dart';
import 'package:flutterbuyandsell/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../provider/main_category/main_category_provider.dart';
import '../../viewobject/category_model.dart';
import '../../viewobject/holder/product_parameter_holder.dart';

class DashboardNew extends StatefulWidget {
  @override
  _DashboardNewState createState() => _DashboardNewState();
}

class _DashboardNewState extends State<DashboardNew>
    with TickerProviderStateMixin {
  PsValueHolder valueHolder;
  int _currentIndex = 0;
  final List<int> _innerTabIndex = [0, 0, 0];
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
  final TextEditingController userInputTEC = TextEditingController();
  MainCategoryProvider mainCategoryProvider;

  Map<String, int> tabCount = {'Things': 4, 'Property': 3, 'Services': 2};

  SearchProductProvider _searchProductProvider;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainCategoryProvider =
          Provider.of<MainCategoryProvider>(context, listen: false);
      _initalizeTabControllers(mainCategoryProvider);
    });
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

  void _initalizeTabControllers(MainCategoryProvider provider) {
    _tabControllerFirst = TabController(
        vsync: this,
        length: provider.thingsList.length,
        initialIndex: _innerTabIndex[0]);
    _tabControllerSecond = TabController(
        vsync: this,
        length: provider.propertyList.length,
        initialIndex: _innerTabIndex[1]);
    _tabControllerThird = TabController(
        vsync: this,
        length: provider.servicesList.length,
        initialIndex: _innerTabIndex[2]);

    _tabControllerFirst.addListener(() {
      print('_tabControllerFirst.index ${_tabControllerFirst.index}');
      final int index = _tabControllerFirst.index;
      if (_innerTabIndex[0] != index) {
        _innerTabIndex[0] = index;
        setState(() {});
      }
    });
    _tabControllerSecond.addListener(() {
      print('_tabControllerSecond.index ${_tabControllerSecond.index}');
      final int index = _tabControllerSecond.index;
      if (_innerTabIndex[1] != index) {
        _innerTabIndex[1] = index;
        setState(() {});
      }
    });
    _tabControllerThird.addListener(() {
      print('_tabControllerThird.index ${_tabControllerThird.index}');
      final int index = _tabControllerThird.index;
      if (_innerTabIndex[2] != index) {
        _innerTabIndex[2] = index;
        setState(() {});
      }
    });
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

    Navigator.pushNamed(context, RoutePaths.set_current_location,
        arguments: [animation, animationController, valueHolder, repo4]);
  }

  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);
    repo1 = Provider.of<CategoryRepository>(context);
    repo2 = Provider.of<ProductRepository>(context);
    repo3 = Provider.of<BlogRepository>(context);
    repo4 = Provider.of<ItemLocationRepository>(context);
    mainCategoryProvider = Provider.of<MainCategoryProvider>(context);
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
        body: buildSliver(mainCategoryProvider),
        bottomNavigationBar: buildBottomNavBar(mainCategoryProvider),
        floatingActionButton: buildFAB(),
      ),
    );
  }

  Widget buildSliver(MainCategoryProvider provider) {
    _initalizeTabControllers(provider);
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildNestedScrollView(
            text: 'Things',
            tabs: provider.thingsList,
            tabController: _tabControllerFirst,
            tabIndex: 0),
        _buildNestedScrollView(
            text: 'Property',
            tabs: provider.propertyList,
            tabController: _tabControllerSecond,
            tabIndex: 1),
        _buildNestedScrollView(
            text: 'Services',
            tabs: provider.servicesList,
            tabController: _tabControllerThird,
            tabIndex: 2),
      ],
    );
  }

  Widget buildBottomNavBar(MainCategoryProvider mainCategoryProvider) {
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

        _searchProductProvider =
            SearchProductProvider(repo: repo2, psValueHolder: valueHolder);
        _searchProductProvider.productParameterHolder =
            ProductParameterHolder().getLatestParameterHolder();
        _searchProductProvider.productParameterHolder.itemTypeId =
            getIndexedTab(_currentIndex, mainCategoryProvider);
        final String loginUserId = Utils.checkUserLoginId(valueHolder);
        _searchProductProvider.loadProductListByKey(
            loginUserId, _searchProductProvider.productParameterHolder);

        return _searchProductProvider;
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
                  onPressed: () {
                    print(
                        'servicesList DATA :${mainCategoryProvider.servicesList[0]}');
                    Navigator.pushNamed(context, RoutePaths.categoryList,
                        arguments: getMainCategoryId());
                  },
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
                  final Product product = Product();
                  print('product id is ${product.id}');
                  Utils.navigateOnUserVerificationView(
                      _categoryProvider, context, () async {
                    final dynamic returnData = await Navigator.pushNamed(
                        context, RoutePaths.itemEntry,
                        arguments: [
                          ItemEntryIntentHolder(
                              flag: PsConst.ADD_NEW_ITEM, item: product),
                          getMainCategoryId()
                        ]);
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
    @required List<CategoryModel> tabs,
    @required int tabIndex,
  }) {
//    print('tabs: ${tabs?.first?.toString()}');
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
                      icon: const Icon(Icons.location_on_outlined),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, RoutePaths.itemLocationList);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.message_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                floating: true,
                snap: true,
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
                      tabs: tabs.map((e) => Text(e.name)).toList(),
                      onTap: (int index) {
                        print('INNER TAB CHANGED');
                        if (_innerTabIndex[tabIndex] != index) {
                          _innerTabIndex[tabIndex] = index;
                          _searchProductProvider.productList.data = null;
                          _searchProductProvider.notifyListeners();
                          setState(() {});
                          if (_scrollController.offset > 1) {
                            _scrollController.animateTo(0,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.elasticInOut);
                          }
                        }
                      },
                    ),
                  ),
                  preferredSize: const Size(double.infinity, kToolbarHeight),
                ))
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: List<Widget>.generate(tabController.length, (int index) {
            // print('_buildNestedScrollView $text');
            return RefreshIndicator(
              onRefresh: () async {
                final String loginUserId = Utils.checkUserLoginId(valueHolder);
                _searchProductProvider.productList.data = null;
                _searchProductProvider.notifyListeners();
                await _searchProductProvider.resetLatestProductList(
                    loginUserId, _searchProductProvider.productParameterHolder);
                return;
              },
              child: ChangeNotifierProvider<SearchProductProvider>(
                  lazy: false,
                  create: (BuildContext content) {
                    print('TAB VIEW BUILT');
                    _searchProductProvider = SearchProductProvider(
                        repo: repo2, psValueHolder: valueHolder);
                    _searchProductProvider.productParameterHolder =
                        ProductParameterHolder().getLatestParameterHolder();
                    _searchProductProvider.productParameterHolder.itemTypeId =
                        tabs[index].id;
                    final String loginUserId =
                        Utils.checkUserLoginId(valueHolder);
                    _searchProductProvider.loadProductListByKey(loginUserId,
                        _searchProductProvider.productParameterHolder);

                    return _searchProductProvider;
                  },
                  child: Consumer<SearchProductProvider>(builder:
                      (BuildContext context, SearchProductProvider provider,
                          Widget child) {
                    print('TAB VIEW Notified');
                    if (provider.productList != null &&
                        provider.productList.data != null &&
                        provider.productList.data.isNotEmpty) {
                      return SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: <Widget>[
                            GridView.builder(
                              itemCount: provider.productList.data.length ?? 0,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.65),
                              addAutomaticKeepAlives: false,
                              shrinkWrap: true,
                              itemBuilder: (_, int index) {
                                if (provider.productList.data.length > 4 &&
                                    index ==
                                        provider.productList.data.length - 1) {
                                  final String loginUserId =
                                      Utils.checkUserLoginId(valueHolder);
                                  provider.nextProductListByKey(loginUserId,
                                      provider.productParameterHolder);
                                }
                                return _buildItem(
                                    index, provider.productList.data[index]);
                              },
                            ),
                            if (provider.isLoading)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: const CircularProgressIndicator(),
                                ),
                              )
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox(
                        height: 200,
                      );
                    }
                  })),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildItem(int index, Product product) {
    return InkWell(
//      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: PsColors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: PsDimens.space4, vertical: PsDimens.space8),
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
                child: Stack(
                  children: <Widget>[
                    PsNetworkImage(
                      photoKey:
                          '${product.defaultPhoto.imgId}${PsConst.HERO_TAG__IMAGE}',
                      defaultPhoto: product.defaultPhoto,
                      width: PsDimens.space180,
                      height: double.infinity,
                      boxfit: BoxFit.cover,
                      onTap: () {},
                    ),
                    Positioned(
                        bottom: 0,
                        child: product.isSoldOut == '1'
                            ? Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: PsDimens.space12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        Utils.getString(
                                            context, 'dashboard__sold_out'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(color: PsColors.white)),
                                  ),
                                ),
                                height: 30,
                                width: PsDimens.space180,
                                decoration: BoxDecoration(
                                    color: PsColors.soldOutUIColor),
                              )
                            : Container()
                        //   )
                        // ],
                        ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                    left: PsDimens.space8,
                    top: PsDimens.space12,
                    right: PsDimens.space8,
                    bottom: PsDimens.space4),
                child: Text(
                  product.title,
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
                        child: Text(product.itemLocation.name,
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
                            child: Text(product.category.catName,
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

  String getIndexedTab(int currentIndex, MainCategoryProvider provider) {
    if (_currentIndex == 0) {
      return provider.thingsList[_innerTabIndex[0]].id;
    } else if (_currentIndex == 1) {
      return provider.propertyList[_innerTabIndex[1]].id;
    } else if (_currentIndex == 2) {
      return provider.servicesList[_innerTabIndex[2]].id;
    }
    return '';
  }

  String getMainCategoryId() {
    if (_currentIndex == 0) return PsConfig.things;
    if (_currentIndex == 1) return PsConfig.property;
    if (_currentIndex == 0) return PsConfig.services;
    return PsConfig.things;
  }
}
