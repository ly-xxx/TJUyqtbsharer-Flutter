import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/provider/view_state_model.dart';
import 'package:we_pei_yang_flutter/lounge/service/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/view_model/lounge_time_model.dart';

class BuildingDataModel extends ViewStateListModel {
  BuildingDataModel(this.timeModel) {
    timeModel.addListener((){
      refresh();
    });
  }

  final LoungeTimeModel timeModel;

  DateTime get dateTime => timeModel.dateTime;

  Campus get campus => timeModel.campus;

  changeCampus() {
    timeModel.changeCampus();
    refresh();
  }

  @override
  refresh() async {
    setBusy();
    if (timeModel.state == ViewState.error) {
      setError(Exception('refresh data error when change date'), null);
    } else if (timeModel.state == ViewState.idle) {
      super.refresh();
    }
  }

  @override
  Future<List> loadData() async {
    List<Building> list = await HiveManager.instance.baseBuildingDataFromDisk
        .where((building) => building.campus == campus.id)
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}
