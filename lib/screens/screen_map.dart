import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seoul/widget/bottombar/bottom_bar.dart';

import '../widget/appbar/main_app_bar.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  static String routeName = "/screen_map";

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapScreen> {
  late GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  final LatLng _center = const LatLng(37.3216, 127.1268);

  bool _showAllMarkers = false; // allMarkers 보여줄지말지

  List<Marker> allMarkers = []; // 공공데이ㅓㅌ 핑찍기

  Map<MarkerId, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    getCurrentLocation();
  }
  Future<void> _loadMarkers() async {
    // assets 폴더에서 locations.json 파일을 읽습니다.
    String jsonString = await rootBundle.loadString('assets/data.json');
    // JSON 문자열을 파싱하여 리스트로 변환합니다.
    List<dynamic> jsonResponse = json.decode(jsonString);

    setState(() {
      allMarkers = jsonResponse.map((location) => Marker(
        markerId: MarkerId(location["media"]),
        position: LatLng(location["latitude"], location["longitude"]),
        infoWindow: InfoWindow(
          title: location["media"],
          snippet: location["detail"]
        ),
      )).toList();
      
      _markers = Map.fromIterable(allMarkers, key:  (marker) => marker.markerId, value: (marker) => marker);
    });
  }

  // allmarkers 키고끄기
  void _toggleMarkers() {
    setState(() {
      _showAllMarkers = !_showAllMarkers; // 상태를 토글합니다.
      if (_showAllMarkers) {
        // _showAllMarkers가 true일 경우 모든 마커를 추가합니다.
        _markers = Map.fromIterable(allMarkers, key: (m) => m.markerId, value: (m) => m);      } else {
        // _showAllMarkers가 false일 경우 모든 마커를 제거합니다.
        _markers.clear();
      }
    });
  }

  void _updateMarkersForSearch(String searchText) {

    List<Marker> filteredMarkers = [];

    // 모든 마커를 순회하며 검색 텍스트를 포함하는지 확인
    for (var marker in allMarkers) {
      String detail = marker.infoWindow.snippet ?? ''; // 여기서 마커의 detail 정보를 얻습니다.
      if (detail.contains(searchText)) {
        filteredMarkers.add(marker);
      }
    }

    setState(() {
      // 지도에 표시될 마커 업데이트
      _markers = Map.fromIterable(filteredMarkers, key: (marker) => marker.markerId, value: (marker) => marker);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);
  }


  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 서비스 권한이 거부되었습니다.');
        return; // 권한이 없으므로 여기서 리턴
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('위치 서비스 권한이 영구적으로 거부되었습니다.');
      // 사용자가 위치 서비스 권한을 영구적으로 거부한 경우 처리 로직
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      print('위치 서비스가 비활성화 되었습니다.');
      return; // 위치 서비스가 비활성화되었으므로 여기서 리턴
    }

    try {
      final GoogleMapController controller = await _controller.future;
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('현재 위치: ${position.latitude}, ${position.longitude}');
      // 현재 위치에 마커 추가
      final MarkerId markerId = MarkerId("current_location");
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: "현재 위치"),
      );
      setState(() {
        _markers[markerId] = marker; // _markers는 Map<MarkerId, Marker> 타입의 상태 변수입니다.
      });

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(position.latitude, position.longitude),
          zoom: 18.0,
        ),
      ));
    } catch (e) {
      print('현재 위치를 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize( // AppBar 클래스는 명시적으로 너비와 높이를 설정할 수 있는 PreferredSize 위젯을 상속 받는다.
        preferredSize: Size.fromHeight(60), // 앱바 높이 조절
        child: MainAppBar(), // 앱바 적용
      ),
      body:
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children : <Widget>[
              SizedBox(
                width: double.infinity,
                height: 735,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 18.0,
                  ),
                  markers: Set<Marker>.of(_markers.values),
                  zoomControlsEnabled: false,
                ),
              ),
              Positioned(
                top: 18,
                left: 18,
                right: 18,
                child: SizedBox(
                  width: 336, height: 42,
                  child:  MapSearchBar(
                    onSearch: _updateMarkersForSearch,
                    onToggle: _toggleMarkers,

                  )
                ),
              ),
          Positioned(
            bottom: 110,
            right: 10,
            child: Card(
              elevation: 2,
              child: Container(
                color: Color(0xFFFAFAFA),
                width: 40,
                height: 100,
                child: Column(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          var currentZoomLevel = await mapController.getZoomLevel();

                          currentZoomLevel = currentZoomLevel + 2;
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _center,
                                zoom: currentZoomLevel,
                              ),
                            ),
                          );
                        }),
                    SizedBox(height: 2),
                    IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () async {
                          var currentZoomLevel = await mapController.getZoomLevel();
                          currentZoomLevel = currentZoomLevel - 2;
                          if (currentZoomLevel < 0) currentZoomLevel = 0;
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _center,
                                zoom: currentZoomLevel,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 110,
                child: GestureDetector(
                  onTap: (){
                    getCurrentLocation();
                    },
                  child: Container(
                    child: Icon(
                      Icons.my_location,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right:0,
                  child: BottomBar(
                    isMap: true,
                    isBoard: false,
                    isChat: false,
                    isMy: false,
                    isComment: false,
                  ),
              ),
            ],
          ),
        ),
    );
  }
}

class MapSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function() onToggle;

  const MapSearchBar({
    Key? key,
    required this.onSearch,
    required this.onToggle,
  }) : super(key: key);

  @override
  _MapSearchBarState createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  bool _showAllMarkers = false;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      onChanged: (value) {
        print("Input changed: $value");  // 입력된 값이 바뀔 때마다 프린트
        widget.onSearch(value);
      },
      onSubmitted: (value) {
        print("Input submitted: $value");  // 검색 제출 시 프린트
        widget.onSearch(value);
      },
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      backgroundColor: MaterialStatePropertyAll(Color(0xffcfe6fb)),
      leading: Icon(Icons.search, size: 18,),
      hintText: "목적지를 입력하시오",
      textStyle: MaterialStateProperty.all(TextStyle(
        fontSize: 14,
        color: Color(0xff767676),
      )),
      trailing: [
        IconButton(
          icon: _showAllMarkers
              ? Icon(Icons.toggle_on) // 토글이 켜져 있을 때 아이콘
              : Icon(Icons.toggle_off_outlined), // 토글이 꺼져 있을 때 아이콘
          onPressed: () {
            setState(() {
              _showAllMarkers = !_showAllMarkers;
            });
            widget.onToggle(); // 부모 위젯의 토글 핸들러를 호출합니다.
          },
        ),
      ],
    );
  }
}