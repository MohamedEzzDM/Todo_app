
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_appp/shared/cubit/states.dart';
import '../../modules/archived_screen/archived_tasks.dart';
import '../../modules/done_screen/done_tasks.dart';
import '../../modules/new_tasks_screen/new_tasks.dart';

class AppCubit extends Cubit<AppStates>{
  int currentIndex = 0;

  List<Widget> screens = [
    NewTasks_Screen(),
    Done_Screen(),
    Archived_Screen(),
  ];
  List<String> title = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  void changeIndex(int index){
    currentIndex =index;
    emit(AppChangeBottomNavStates());
  }

  late Database database ;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() {
   openDatabase(
        'todo.db',
        version: 1,
        onCreate: (database , version) async
        {
          await database.execute(
              'CREATE TABLE tasks(id INTEGER PRIMARY KEY ,title TEXT ,date TEXT, time TEXT, status TEXT )');
        },
        onOpen: (database){
          getDatabase(database);
        }
    ).then((value) {
     database = value;

     emit(AppCreateDBStates());
   }
    );
  }

   insertDatabase({
    required String title,
    required String time,
    required String date,
  })async {
     await database.transaction((txn) async
    {
       await txn.rawInsert('INSERT INTO tasks(title, date ,time, status)VALUES("$title","$date","$time","new")'
      ).then((value) {
        emit(AppInsertDBStates());

        getDatabase(database);
      });
    });
  }

  void getDatabase(database){
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDBLoadingStates());
      database.rawQuery('SELECT * FROM tasks').then((value) {

        value.forEach((element){
          if(element['status'] == 'new')
            newTasks.add(element);
          else if(element['status'] == 'done')
            doneTasks.add(element);
          else archivedTasks.add(element);
        });
      emit(AppGetDBStates());
    });
  }
  
  void updateDB({
  required String status,
  required int id,
})async{
     await database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
          getDatabase(database);
          emit(AppUpdateDBStates());
     });
  }

  void deleteDB({
    required int id,
  })async{
    await database.rawDelete(
        'DELETE FROM tasks WHERE id = ?',
        [id]).then((value) {
      getDatabase(database);
      emit(AppDeleteDBStates());
    });
  }

  bool isBottomSheet = false ;
  IconData fabIcon = Icons.edit;

  void changeBottomSheet({
  required bool isShow,
  required IconData icon,
}){
    isBottomSheet = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetStates());
  }
}

