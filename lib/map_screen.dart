import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_googlemap/get_address.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController orginController=TextEditingController();
  TextEditingController destinationController=TextEditingController();
  Set<Marker>_marker1=Set<Marker>();
  Set<Polygon>_polygon1=Set<Polygon>();
  Set<Polyline>_polyLine1=Set<Polyline>();
  var polylineidCounter=1;
  late GoogleMapController mapController;
  bool isLoading = false;

  late String errorMessage;

  List<Marker> _marker = [];
  List<Marker> list = [];

  Completer<GoogleMapController> _controller = Completer();
  late CameraPosition _currentPosition=CameraPosition(target: LatLng(28.644800, 77.216721),
  zoom: 14
  );


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Map Test")),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: destinationController,
                      decoration: InputDecoration(
                          hintText: "Destination",
                          contentPadding: EdgeInsets.only(left: 15)
                      ),
                    ),
                    TextFormField(
                      controller: orginController,
                      decoration: InputDecoration(
                          hintText: "Origin",
                          contentPadding: EdgeInsets.only(left: 15)
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () async {
                   //var plcae=await GetLocation().getPlace(destinationController.text);
                  // goToPlace(plcae);
                   var direction=await GetLocation().getDirection(orginController.text,destinationController.text);
                   _setpolyLine(direction['polyline_decode']);
                   goToPlace1( direction["start_location"]['lat'],
                     direction['start_location']['lng'],);
                   goToPlace(
                       direction["start_location"]['lat'],
                       direction['start_location']['lng'],
                     direction['bound_ne'],
                     direction['bound_sw']
                   );
                  },
                  icon: Icon(Icons.search))
            ],
          ),
          Expanded(
            child: GoogleMap(
                initialCameraPosition: _currentPosition,
                markers: Set<Marker>.of(_marker),
                polylines: _polyLine1,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,

              ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
         _getCurrentLocation().then((value) async {
           _marker.add(
               Marker(
                   markerId: MarkerId("1"),
                 position: LatLng(value.latitude,value.longitude),
                 infoWindow: InfoWindow(title: "Your Current Location")
               ),
           );
           CameraPosition cameraPosition=CameraPosition(
               target: LatLng(value.latitude,value.longitude),
             zoom: 14
           );
           final GoogleMapController controller=await _controller.future;
           controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
           setState(() {

           });
         });
        },
        child: Icon(Icons.location_on),
      ),
    );
  }

  Future<void> goToPlace(
      double lat,
      double lng,
      Map<String,dynamic> boundne,
      Map<String,dynamic> boundsw
      ) async {
    final GoogleMapController controller=await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(lat,lng),
        zoom: 14
      )
    ));
    controller.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
      southwest: LatLng(boundsw['lat'],boundsw['lng']),
      northeast: LatLng(boundne['lat'],boundne['lng']),
    ),
    25
    ));
  }
void _setpolyLine(List<PointLatLng>points){
    final String polyLineId='polyline_$polylineidCounter';
    polylineidCounter++;
    _polyLine1.add(Polyline(polylineId: PolylineId(polyLineId),
    width: 3,
      color: Colors.red,
      points: points.map((point)=>LatLng(point.latitude, point.longitude)).toList()
    ));
    setState(() {

    });
}

 Future<Position>_getCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace){
      print("Error");
    });
    return await Geolocator.getCurrentPosition();
 }

  Future<void> goToPlace1(
      double lat,
      double lng,
      ) async {
    final GoogleMapController controller=await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(lat,lng),
            zoom: 14
        )
    ));
  }
}
