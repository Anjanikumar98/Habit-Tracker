import 'package:flutter/material.dart';

import 'items.dart';
import 'main.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff131b26),
        body: Container(
          padding: EdgeInsets.only(top: 25.0, left: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      softWrap: true,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Most Popular",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                          TextSpan(
                            text: " Habits",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(9.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff6f1bff),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff6f1bff),
                              offset: Offset(0, 3),
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 25.0),
                ],
              ),
              SizedBox(height: 35.0),
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: habits.length,
                  itemBuilder: (ctx, id) {
                    return Container(
                      width: 150,
                      margin: EdgeInsets.only(
                        right: 15.0,
                        top: 9.0,
                        bottom: 9.0,
                      ),
                      padding: EdgeInsets.all(13.0),
                      decoration: BoxDecoration(
                        color: habits[id]['color'],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: habits[id]['color'],
                            blurRadius: 5.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            habits[id]['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            habits[id]['fulltext'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 35.0),
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Color(0xff1b232e),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                padding: EdgeInsets.all(15),
                child: ListView.builder(
                  itemCount: 7,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, f) {
                    int day = DateTime.now().day + f;
                    return FittedBox(
                      child: Container(
                        width: 90,
                        height: 90,
                        margin: EdgeInsets.only(right: 15.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              day == DateTime.now().day
                                  ? Color(0xff727be8)
                                  : Color(0xff131b26),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "${DateTime.now().day + f}",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight:
                                    day == DateTime.now().day
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    day == DateTime.now().day
                                        ? Colors.white
                                        : Colors.grey.shade500,
                              ),
                            ),
                            // Text(
                            //   DateFormat(
                            //     'EE',
                            //   ).format(DateTime.now().add(Duration(days: f))),
                            //   style: TextStyle(
                            //     color:
                            //         day == DateTime.now().day
                            //             ? Colors.white
                            //             : Colors.grey[700],
                            //     fontWeight:
                            //         day == DateTime.now().day
                            //             ? FontWeight.bold
                            //             : FontWeight.normal,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 35.0),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Your Habits ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),
                    TextSpan(
                      text: " 5",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 21,
                      ),
                    ),
                  ],
                ),
              ),
              // ListItem(id: 1,)
              Expanded(
                child: ListView.builder(
                  itemCount: habits2.length,
                  itemBuilder: (ctx, id) {
                    return ListItem(id: id);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
