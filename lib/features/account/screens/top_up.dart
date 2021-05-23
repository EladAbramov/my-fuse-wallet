import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fusecash/features/account/screens/crypto_deposit.dart';
import 'package:fusecash/generated/l10n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/models/plugins/rampInstant.dart';
import 'package:fusecash/models/plugins/transak.dart';
import 'package:fusecash/redux/viewsmodels/top_up.dart';
import 'package:fusecash/utils/url.dart';
import 'package:fusecash/utils/webview.dart';
import 'package:fusecash/widgets/my_scaffold.dart';

class CustomTile extends StatelessWidget {
  final void Function() onTap;
  final String menuIcon;
  final String subtitle;
  final String title;

  const CustomTile({
    Key key,
    this.onTap,
    this.menuIcon,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        top: 5,
        bottom: 5,
      ),
      onTap: onTap,
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF888888),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
      trailing: Icon(
        Icons.navigate_next,
        color: Colors.black,
      ),
      leading: SvgPicture.asset(
        'assets/images/${menuIcon}.svg',
      ),
    );
  }
}

class TopUpScreen extends StatefulWidget {
  @override
  _TopUpScreenState createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  @override
  void initState() {
    Segment.screen(screenName: '/top-up-screen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: I10n.of(context).top_up,
      body: StoreConnector<AppState, TopUpViewModel>(
        distinct: true,
        converter: TopUpViewModel.fromStore,
        builder: (_, viewModel) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CustomTile(
                      title: I10n.of(context).credit_card,
                      menuIcon: 'credit_card',
                      subtitle:
                          viewModel.isUSUser ? '(Transak)' : '(Ramp network)',
                      onTap: () {
                        if (viewModel.topUpPlugin != null) {
                          final String url = viewModel.isUSUser
                              ? (viewModel.topUpPlugin as TransakPlugin)
                                  .widgetUrl
                              : (viewModel.topUpPlugin as RampInstantPlugin)
                                  .widgetUrl;
                          openDepositWebview(
                            withBack: true,
                            url: url,
                          );
                        }
                      },
                    ),
                    CustomTile(
                      title: 'USDC',
                      menuIcon: 'usdc',
                      subtitle:
                          '(${I10n.of(context).deposit_from_ethereum_or_BSC})',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CryptoDepositScreen(
                              link:
                                  'https://fuseswap.com/#/bridge?sourceChain=1&inputCurrencyId=0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48&recipient=${viewModel.walletAddress}',
                            ),
                          ),
                        );
                      },
                    ),
                    CustomTile(
                      title: 'Ethereum',
                      menuIcon: 'etheruem',
                      subtitle:
                          '(${I10n.of(context).deposit_from_ethereum_or_BSC})',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CryptoDepositScreen(
                              link:
                                  'https://fuseswap.com/#/bridge?sourceChain=1&inputCurrencyId=0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2&recipient=${viewModel.walletAddress}',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(
                        top: 5,
                        bottom: 5,
                      ),
                      onTap: () {
                        final Uri _emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'hello@fuse.io',
                        );
                        launchUrl(_emailLaunchUri.toString());
                      },
                      title: Text(
                        'Contact us for support',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        color: Colors.black,
                      ),
                      leading: SvgPicture.asset(
                        'assets/images/support.svg',
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}