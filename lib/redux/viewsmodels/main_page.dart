import 'package:equatable/equatable.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/redux/actions/cash_wallet_actions.dart';
import 'package:fusecash/redux/actions/swap_actions.dart';
import 'package:fusecash/redux/actions/user_actions.dart';
import 'package:redux/redux.dart';

class HomeScreenViewModel extends Equatable {
  final bool? isContactsSynced;
  final bool backup;
  final bool isBackupDialogShowed;
  final Function setShowDialog;
  final Function getSwapListBalances;
  final Function updateReward;

  HomeScreenViewModel({
    required this.isContactsSynced,
    required this.backup,
    required this.isBackupDialogShowed,
    required this.setShowDialog,
    required this.getSwapListBalances,
    required this.updateReward,
  });

  static HomeScreenViewModel fromStore(Store<AppState> store) {
    return HomeScreenViewModel(
      isContactsSynced: store.state.userState.isContactsSynced,
      backup: store.state.userState.backup,
      isBackupDialogShowed: store.state.userState.receiveBackupDialogShowed,
      setShowDialog: () {
        store.dispatch(ReceiveBackupDialogShowed());
      },
      getSwapListBalances: () {
        store.dispatch(fetchSwapBalances());
      },
      updateReward: () {
        store.dispatch(getRewardData());
      },
    );
  }

  @override
  List<Object> get props => [
        isBackupDialogShowed,
        backup,
      ];
}
