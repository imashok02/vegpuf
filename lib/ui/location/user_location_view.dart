import 'package:flutter/material.dart';
import 'package:flutterbuyandsell/config/ps_colors.dart';
import 'package:flutterbuyandsell/config/ps_config.dart';
import 'package:flutterbuyandsell/constant/ps_constants.dart';
import 'package:flutterbuyandsell/provider/item_location/item_location_provider.dart';
import 'package:flutterbuyandsell/repository/item_location_repository.dart';
import 'package:flutterbuyandsell/ui/common/ps_button_widget.dart';
import 'package:flutterbuyandsell/viewobject/common/ps_value_holder.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class LocationSelectView extends StatefulWidget {
  const LocationSelectView({
    @required this.productParameterHolder,
    @required this.animation,
    @required this.animationController,
    this.itemLocationRepository,
  });

  final ItemLocationRepository itemLocationRepository;
  final PsValueHolder productParameterHolder;
  final AnimationController animationController;
  final Animation<double> animation;

  @override
  _LocationSelectViewState createState() => _LocationSelectViewState();
}

class _LocationSelectViewState extends State<LocationSelectView> {
  Position _currentPosition;
  bool _isLoading = false;

//  ItemLocationProvider _provider;

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    _provider = Provider.of(context, listen: false);
    return Scaffold(
      appBar: AppBar(backgroundColor: PsColors.mainColor,
        title: Text(
          PsConst.LOCATION,
          style: TextStyle(
              color: PsColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: ChangeNotifierProvider<ItemLocationProvider>(
        lazy: false,
        create: (_) => ItemLocationProvider(
            repo: widget.itemLocationRepository,
            psValueHolder: widget.productParameterHolder),
        child: Consumer<ItemLocationProvider>(builder: (BuildContext context,
            ItemLocationProvider provider, Widget child) {
          return Container(
            child: Stack(
              children: [
                Column(
                  children: [

                    const SizedBox(height: 30,),
                    const Text('Current Location', style: TextStyle(
                        color: Colors.black,fontSize: 16,
                        fontFamily: PsConfig.ps_default_font_family,
                        fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                    Text(widget?.productParameterHolder?.locactionName ?? '',style: const TextStyle(decoration: TextDecoration.underline,decorationStyle: TextDecorationStyle.dashed),),

                    const SizedBox(height: 40,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: PSButtonWidget(
                          hasShadow: true,
                          width: double.infinity,
                          titleText: 'Change To Current Location',
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            final List<Address> addressList = await _getAddress(
                                _currentPosition.latitude,
                                _currentPosition.longitude);
                            await provider.replaceItemLocationData(
                                addressList.first.postalCode,
                                addressList.first.subAdminArea,
                                _currentPosition.latitude.toString(),
                                _currentPosition.latitude.toString());
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pop();
                          }),
                    )
                  ],
                ),
                if (_isLoading) const Center(child: CircularProgressIndicator())
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
    });
    final Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final Coordinates coordinates = Coordinates(lat, lang);
    final List<Address> add =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    print(' ADDRESS: ${add.first.toMap()}');
    return add;
  }
}
