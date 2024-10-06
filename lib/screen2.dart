import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResultScreen extends StatefulWidget {
  final String location;

  LocationResultScreen({required this.location});

  @override
  _LocationResultScreenState createState() => _LocationResultScreenState();
}

class _LocationResultScreenState extends State<LocationResultScreen> {
  LatLng? latLng;
  LatLng? currentLocation; // Store current location
  MapType _currentMapType = MapType.normal; // Default map type
  GoogleMapController? mapController; // To control the map

  @override
  void initState() {
    super.initState();
    _getLatLngFromAddress(widget.location);
    _getCurrentLocation(); // Get the current location
  }

  Future<void> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          latLng = LatLng(locations.first.latitude, locations.first.longitude);
        });
      } else {
        print("No locations found for the given address.");
      }
    } catch (e) {
      print("Error occurred while fetching coordinates: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error occurred while fetching current location: $e");
    }
  }

  void _onMapTypeChanged(MapType? type) {
    if (type != null) {
      setState(() {
        _currentMapType = type;
      });
    }
  }

  void _goToCurrentLocation() {
    if (currentLocation != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location on Map'),
        actions: [
          PopupMenuButton<MapType>(
            onSelected: _onMapTypeChanged,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: MapType.normal,
                  child: Text("Normal"),
                ),
                PopupMenuItem(
                  value: MapType.satellite,
                  child: Text("Satellite"),
                ),
                PopupMenuItem(
                  value: MapType.terrain,
                  child: Text("Terrain"),
                ),
              ];
            },
          ),
        ],
      ),
      body: latLng == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: latLng!,
                zoom: 14.0,
              ),
              mapType: _currentMapType,
              markers: {
                if (latLng != null)
                  Marker(
                    markerId: MarkerId('userLocation'),
                    position: latLng!,
                    infoWindow: InfoWindow(title: widget.location),
                  ),
                if (currentLocation != null)
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: currentLocation!,
                    infoWindow: InfoWindow(title: 'Current Location'),
                  ),
              },
              onMapCreated: (GoogleMapController controller) {
                mapController = controller; // Store the controller
              },
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, bottom: 20),
          child: FloatingActionButton(
            onPressed: _goToCurrentLocation,
            tooltip: 'Current Location',
            child: Icon(Icons.my_location),
          ),
        ),
      ),
    );
  }
}
