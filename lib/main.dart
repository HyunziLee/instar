import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(
      MaterialApp(
        theme: style.theme,

        // 페이지 많을 때
        // initialRoute: '/',
        // routes: {
        //   '/' : (c)=> Text('첫페이지'),
        //   '/detail': (c)=> Text('둘째페이지')
        // },
        home: MyApp()
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
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
                  MaterialPageRoute(builder: (context)=> Upload(userImage:userImage))
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
              Image.network(widget.result[i]['image']),
              Text(widget.result[i]['likes'].toString()),
              Text(widget.result[i]['date']),
              Text(widget.result[i]['content']),
              Text(widget.result[i]['user']),
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
  const Upload({Key? key, this.userImage}) : super(key: key);
  final userImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(userImage),
          Text('이미지업로드'),
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.close))
        ],
      ),
    );
  }
}



