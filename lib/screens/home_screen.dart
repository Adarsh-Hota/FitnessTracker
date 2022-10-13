import 'package:fitness_tracker/database/database_service.dart';
import 'package:fitness_tracker/models/activity.dart';
import 'package:fitness_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController myController = TextEditingController();
  String? dropDownValue = dropDownMenu['weight'];
  String? selectedTab = tabMenu['all'];

  //cleaning up the TextEditingController
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  //For adding data to database
  Future<void> addTab() async {
    print(dropDownValue);
    final dbServiceInstance = DatabaseService();
    await dbServiceInstance.addActivity({
      DatabaseService.type: dropDownValue!.toLowerCase(),
      DatabaseService.data: double.parse(myController.text),
      DatabaseService.date: DateTime.now().toString()
    });
    myController.clear();
    if (!mounted) return;
    Navigator.of(context).pop();
    setState(() {});
  }

  //Opening the dialog box
  Future<dynamic> openAddDialog(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
              return SizedBox(
                height: 220,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        'Add',
                        style: textStyle(28, Colors.black, FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 2,
                            child: TextFormField(
                              controller: myController,
                              decoration: InputDecoration(
                                  hintText:
                                      dropDownValue == dropDownMenu['weight']
                                          ? 'In kg'
                                          : 'In cm',
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.black))),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            flex: 1,
                            child: DropdownButton(
                              hint: Text(
                                'Choose',
                                style: textStyle(
                                  18,
                                  Colors.black,
                                  FontWeight.w600,
                                ),
                              ),
                              onChanged: (dynamic value) {
                                stateSetter(() {
                                  dropDownValue = value;
                                });
                              },
                              dropdownColor: Colors.white70,
                              value: dropDownValue,
                              items: [
                                DropdownMenuItem(
                                  value: dropDownMenu['weight'],
                                  child: Text(
                                    'Weight',
                                    style: textStyle(
                                      18,
                                      Colors.black,
                                      FontWeight.w600,
                                      fontType: 3,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: dropDownMenu['height'],
                                  child: Text(
                                    'Height',
                                    style: textStyle(
                                      18,
                                      Colors.black,
                                      FontWeight.w600,
                                      fontType: 3,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      IconButton(
                        color: Colors.redAccent,
                        iconSize: 60,
                        icon: const Icon(
                          Icons.double_arrow_outlined,
                        ),
                        onPressed: () async => await addTab(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> deleteTab(Activity activity) async {
    await DatabaseService().deleteActivity(activity.id);
    setState(() {});
  }

  //Building new tabs/activities
  Widget buildTab(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: InkWell(
        onTap: () => setState(() {
          selectedTab = text;
        }),
        child: Chip(
          elevation: 10,
          backgroundColor:
              selectedTab == text ? Colors.redAccent : Colors.white,
          label: Text(
            text,
            style: selectedTab == text
                ? textStyle(18, Colors.white, FontWeight.w600)
                : textStyle(18, Colors.blueGrey, FontWeight.w600),
          ),
        ),
      ),
    );
  }

  //The build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chip(
          elevation: 8,
          padding: const EdgeInsets.all(8),
          backgroundColor: Colors.redAccent,
          deleteIcon: const Icon(Icons.add, color: Colors.white, size: 26),
          onDeleted: () => openAddDialog(context),
          label: Text(
            'Add',
            style: textStyle(22, Colors.white, FontWeight.w600),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          //Heading and Chips section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(children: [
                Text(
                  'Fitify',
                  style: textStyle(
                    40,
                    Colors.blueGrey,
                    FontWeight.w600,
                    fontType: 1,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      buildTab('All'),
                      buildTab('Weight'),
                      buildTab('Height'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ]),
            ),
          ),

          //Activites/Rows section
          FutureBuilder<List<Map<String, Object?>>>(
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              //If the Future is resolved
              if (snapshot.connectionState == ConnectionState.done) {
                //If the Future has resolved with error
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }
                //If the Future has resolved with data
                else if (snapshot.hasData) {
                  List<Activity> activityList = List<Activity>.generate(
                    snapshot.data!.length,
                    (index) => Activity(
                      snapshot.data![index][DatabaseService.columnId],
                      snapshot.data![index][DatabaseService.date],
                      snapshot.data![index][DatabaseService.data],
                      snapshot.data![index][DatabaseService.type],
                    ),
                  );

                  return SliverGroupedListView<Activity, String>(
                    elements: activityList,
                    groupBy: (Activity activity) => DateFormat.MMMd().format(
                      DateTime.parse(activity.date),
                    ),
                    groupSeparatorBuilder: (String groupByValue) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        groupByValue,
                        style: textStyle(
                          20,
                          Colors.black,
                          FontWeight.w600,
                          fontType: 1,
                        ),
                      ),
                    ),
                    itemBuilder: (BuildContext context, Activity activity) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 8),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Image(
                                width: 50,
                                height: 50,
                                image: activity.type == 'weight'
                                    ? const AssetImage(
                                        'assets/images/weight.png')
                                    : const AssetImage(
                                        'assets/images/height.png'),
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                activity.type == 'weight'
                                    ? '${activity.data} kg'
                                    : '${activity.data} cm',
                                style: textStyle(
                                  20,
                                  Colors.black,
                                  FontWeight.w600,
                                  fontType: 3,
                                ),
                              ),
                              trailing: InkWell(
                                onTap: () async => await deleteTab(activity),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              }
              //If the Future has not resolved yet
              return const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            future: DatabaseService().getActivities(selectedTab!),
          ),
        ],
      ),
    );
  }
}
