import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart'as http;
import 'dart:convert'as convert;

class GetLocation{
  final String key="Your key";
  Future<String>getPlcaeID(String input) async {
    print(input);
    final String url="https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input=&inputtype=textquery&key=$key";
    print(url);
    var response=await http.get(Uri.parse(url));
    print("Response"+response.toString());
    var json=convert.jsonDecode(response.body);
    var placeId=json['candidates'][0]['place_id'] as String;
    print(placeId);
    return placeId;
  }

  Future<Map<String,dynamic>> getPlace(String input) async {
    final placeId= await getPlcaeID(input);
    final String url="https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key";
    print(url+"getplace");
    var response=await http.get(Uri.parse(url));
    print("Response"+response.toString());
    var json=convert.jsonDecode(response.body);
    var result=json['result']as Map<String,dynamic>;
    print(result);
    return result;
  }
  Future<Map<String,dynamic>>getDirection(String orgin,String destination) async {
    final String url="https://maps.googleapis.com/maps/api/directions/json?destination=$destination&origin=$orgin&key=$key";
    print(url+"getplace");
    var response=await http.get(Uri.parse(url));
    print("Response"+response.toString());
    var json=convert.jsonDecode(response.body);
    print(json);
    var result={
      'bound_ne':json['routes'][0]['bounds']['northeast'],
      'bound_sw':json['routes'][0]['bounds']['southwest'],
      'start_location':json['routes'][0]['legs'][0]['start_location'],
      'end_location':json['routes'][0]['legs'][0]['end_location'],
      'polyline':json['routes'][0]['overview_polyline']['points'],
      'polyline_decode':PolylinePoints().decodePolyline(json['routes'][0]['overview_polyline']['points'])
    };
    print(result);
    return result;
  }
}
