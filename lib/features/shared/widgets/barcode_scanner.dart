import 'dart:convert';

import 'package:ethereum_address/ethereum_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fusecash/features/shared/dialogs/scan_qr.dart';
import 'package:fusecash/features/shared/dialogs/warn_send.dart';
import 'package:fusecash/redux/viewsmodels/warn_send.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fusecash/services.dart';
import 'package:fusecash/utils/log/log.dart';
import 'package:fusecash/utils/send.dart';
import 'package:wallet_connect_flutter/wallet_connect_flutter.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({
    Key? key,
    this.child,
  }) : super(key: key);
  final Widget? child;

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> implements IWCHandler {
  late WalletConnectFlutter conn;

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    conn = WalletConnectFlutter(handler: this);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> handleWC(String uri) async {
    if (!uri.contains('bridge')) {
      log.error('connect uri invalid');
      return;
    }
    await conn.killSession();
    WalletConnectResponse res = await conn.connect(uri);
    if (res.isError()) {
      return;
    }
    log.info('connect ${res.toString()}');
  }

  @override
  void onCallRequestEthSendTransaction(int? id, String? result) async {
    Map data = json.decode(result!);
    log.info('a $data');
    final String from = checksumEthereumAddress(data['from']);
    final String to = checksumEthereumAddress(data['to']);
    Map<String, dynamic> signedData = await fuseWeb3!.callContractOffChainV2(
      from,
      to,
      BigInt.parse(data['value']),
      data['data'].replaceFirst(
        '0x',
        '',
      ),
    );
    final WalletConnectResponse walletConnectResponse =
        await conn.approveCallRequest(id!, result);
    log.info(
        'onCallRequestEthSendTransaction: walletConnectResponse ${walletConnectResponse.toString()}');
    final response = await api.multiRelay([signedData]);
    // dynamic response = await api.callContractV2(
    //   data['from'],
    //   data['to'],
    //   data['value'],
    //   data['data'],
    // );
    log.info('response ${response.toString()}');
    log.info('onCallRequestEthSendTransaction $id $result');
  }

  @override
  void onCallRequestEthSign(int? id, String? requestInJson) {
    log.info('onCallRequestEthSign $requestInJson');
  }

  @override
  void onCallRequestEthSignTransaction(int? id, String? requestInJson) {
    log.info('onCallRequestEthSignTransaction $requestInJson');
  }

  @override
  void onCallRequestEthSignTypedData(int? id, String? requestInJson) {
    log.info('onCallRequestEthSignTypedData $requestInJson');
  }

  @override
  void onCallRequestPersonalSign(int? id, String? requestInJson) {
    log.info(
        'onCallRequestPersonalSignonCallRequestPersonalSign $requestInJson');
  }

  @override
  void onError(String? error) {
    log.info('onError $error');
  }

  @override
  void onSessionRequest(int? id, String? requestInJson) async {
    await conn.approveSession(
      [
        '0x862Bd4208b2F6ed64Ce92AAdA2669d3c5CC705d9',
      ],
      122,
    );
    log.info('onSessionRequest $requestInJson');
  }

  @override
  void onCallRequestEthSendRawTransaction(int? id, String? requestInJson) {
    log.info('onCallRequestEthSendRawTransaction $requestInJson');
  }

  @override
  void onSessionDisconnect(String? errInJson) {
    log.info('onSessionDisconnect $errInJson');
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, WarnSendDialogViewModel>(
      distinct: true,
      converter: WarnSendDialogViewModel.fromStore,
      builder: (_, viewModel) => Container(
        width: 45,
        height: 45,
        child: GestureDetector(
          child: widget.child ??
              SvgPicture.asset(
                'assets/images/scan_black.svg',
                width: 25.0,
              ),
          onTap: () async {
            String? result = await showDialog<String>(
              context: context,
              builder: (context) => ScanQRDialog(),
            );
            if (result != null) {
              if (result.startsWith('wc:')) {
                handleWC(result);
              } else {
                if (viewModel.warnSendDialogShowed) {
                  barcodeScannerHandler(context, result);
                } else {
                  final bool? isAccepted = await showDialog<bool>(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => WarnSendDialog(),
                  );
                  if (isAccepted != null && isAccepted) {
                    barcodeScannerHandler(context, result);
                  }
                }
              }
            }
          },
        ),
      ),
    );
  }
}