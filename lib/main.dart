import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'notification.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (c)=>Store1()),
          ChangeNotifierProvider(create: (c)=>Store2()),
        ],
        child: MaterialApp(
          theme: style.theme,

          // 페이지 많을 때
          // initialRoute: '/',
          // routes: {
          //   '/' : (c)=> Text('첫페이지'),
          //   '/detail': (c)=> Text('둘째페이지')
          // },
          home: MyApp()
        ),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var result = [];
  var userImage;
  var userContent;

  saveData() async {
    var storage = await SharedPreferences.getInstance(); // 저장공간 오픈하는법
    storage.setString('name', 'john'); // shared_preferences에 데이터 저장하는 법
    var result =  storage.get('name'); // shared_preferences에 데이터 출력하는 법
    // storage.remove('key'); // 데이터 삭제

    // map 자료 저장하는 법
    /*
    map 자료 저장하려면 json으로 바꿔서 저장해야함
    *  var map = {'age': 20};
    * storage.setString('map', jsonEncode(map)); jsonEncode: map에 따옴표쳐서 json으로 바꿔주느 함수
    참고: json -> map 변환은 jsonDecode(변수명);
    *
    * */
  }

  addMyData(){
    var myData = {
      'id': result.length,
      'image': userImage,
      'likes': 3,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'John Kim'
    };
    setState(() {
      result.insert(0, myData);
    });
  }

  setUserContent(text){
    setState(() {
      userContent = text;
    });
  }

  addData(data){
    setState(() {
      result.add(data);
    });
  }

  getData() async{
    var value =  await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));

    if(value.statusCode ==200){
      setState((){
        result = jsonDecode(value.body);
      });
    } else {
      return Text('데이터 실패');
    }
  }

  @override
  void initState()  {
    super.initState();
    getData();
    saveData();
    initNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      floatingActionButton: FloatingActionButton(child: Text('+'), onPressed: (){
        showNotification2();
      },),
      appBar: AppBar(
          title: Text('Instagram'),
          actions: [
            IconButton(
              onPressed: () async{
                var picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.gallery);
                if(image !=null){
                  setState(() {
                    userImage = File(image.path);
                  });
                }
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> Upload(
                      userImage:userImage,
                      setUserContent:setUserContent,
                      addMyData:addMyData
                  ))
                );
              },
              icon: Icon(Icons.add_box_outlined),
              iconSize: 30,
            )
          ]),
      body: [Feed(result:result,  addData:addData), Text('샵페이지')][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
       onTap: (i){
          setState(() {
            tab=i;
          });
       },
       items: [
         BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
         BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: '샵')
       ],
      ),
    );
  }
}

class Feed extends StatefulWidget {
   Feed({Key? key,  this.result, this.addData}) : super(key: key);
  final result;
  final addData;

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  var scroll = ScrollController();
  getDataMore() async{
    var value = await http.get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    if(value.statusCode ==200){
      var value2 = jsonDecode(value.body);
      widget.addData(value2);
    } else {
      return Text('데이터 실패');
    }
  }

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if(scroll.position.pixels == scroll.position.maxScrollExtent){
        getDataMore();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    if(widget.result.isNotEmpty){
      return ListView.builder(itemCount: widget.result.length, controller: scroll, itemBuilder: (c,i){
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.result[i]['image'].runtimeType == String
                  ? Image.network(widget.result[i]['image'])
                  : Image.file(widget.result[i]['image']),
              GestureDetector(
                child: Text(widget.result[i]['user']),
                onTap: (){
                  Navigator.push(context,
                    PageRouteBuilder(
                      pageBuilder: (c, a1, a2)=>Profile(),
                      transitionsBuilder: (c, a1, a2, child)=>
                          FadeTransition(opacity: a1, child: child),
                      transitionDuration: Duration(microseconds: 500)
                    )
                  );
                },
              ),
              Text(widget.result[i]['likes'].toString()),
              Text(widget.result[i]['date']),
              Text(widget.result[i]['content']),

            ]

        );
      },

      );
    } else {
      return Text('로딩중');
    }
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage, this.setUserContent, this.addMyData}) : super(key: key);
  final userImage;
  final setUserContent;
  final addMyData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: (){
          addMyData();
        }, icon: Icon(Icons.send))
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(userImage),
          Text('이미지업로드'),
          TextField(onChanged: (text){
            setUserContent(text);
          },),
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.close))
        ],
      ),
    );
  }
}

class Store2 extends ChangeNotifier {
  var name = 'john kim';
  changeName(){
    name = 'jp';
    notifyListeners();
  }
}

class Store1 extends ChangeNotifier {
 
  var follower = 0;
  var isClicked = false;
  var profileImage = [];

  getData() async{
   var result = await http.get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
   var result2 = jsonDecode(result.body);
   profileImage = result2;
   print(profileImage);
   notifyListeners();

  }

  
  changeFollow (){
    if(isClicked == false){
      follower++;
      isClicked= !isClicked;
      notifyListeners();
    } else if(isClicked == true){
      follower--;
      isClicked= !isClicked;
      notifyListeners();
    }
  }
  
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<Store2>().name),),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(),
          ),
          SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (c,i)=> Container(child: Image.network(context.watch<Store1>().profileImage[i])),
                childCount: context.watch<Store1>().profileImage.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2))
        ],
      )
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(onPressed: (){
          context.read<Store2>().changeName();
        }, child: Text('버튼')),
        Text(context.watch<Store1>().follower.toString()),
        TextButton(onPressed: (){
          context.read<Store1>().changeFollow();
        }, child: Text('팔로우')),
        TextButton(onPressed: (){
          context.read<Store1>().getData();
        }, child: Text('사진'))
      ],
    );
  }
}





