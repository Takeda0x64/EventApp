// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../models/org.dart';
import '../../utilities/shared.dart';
import '../../widgets/future_builder.dart';
import '../../widgets/profile_widget.dart';

class OrgView extends StatefulWidget {
  Org orgdata = const Org();
  String orgId;
  OrgView({super.key, required this.orgId});

  @override
  State<OrgView> createState() => _OrgViewState();
}

class _OrgViewState extends State<OrgView> {
  List orgtypes = ['Organization', 'University', 'Company'];
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.orgdata = toOrg(await runFun(context, getOrg));
        setState(() {});
      },
      child: BuildFuture(
        callback: () {
          return getOrg(orgId: widget.orgId);
        },
        mapper: toOrg,
        builder: (data) {
          widget.orgdata = data;
          return Scaffold(
            appBar: buildAppBar(context, "Account Information",
                button: const BackButton()),
            body: FormBuilder(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ProfileWidget(
                    bgPath: widget.orgdata.orgBackgroundPic,
                    imagepath: widget.orgdata.orgPic,
                    onClick: () {},
                    isEdit: false,
                    onClickbg: () {},
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  buildTitle(widget.orgdata.orgName, widget.orgdata.email),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        child: ElevatedButton(
                            child: const Text(
                              "View Headquarters On Mapps",
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: () async {
                              Console.log(widget.orgdata.location.toString());
                              try {
                                showOnMap(context, widget.orgdata.location);
                              } catch (e) {
                                Console.log(widget.orgdata.location.toString());
                                Console.logError(e.toString());
                                snackbar(context, "Error Opping Mapps", 2);
                              }
                            }),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5),
                        child: ElevatedButton(
                            child: const Text(
                              "Open Website",
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: () async {
                              try {
                                String website = widget.orgdata.website;
                                launchUrl(Uri.parse("https://$website"),
                                    mode: LaunchMode.externalApplication);
                              } catch (e) {
                                Console.logError(e.toString());
                                snackbar(context, "Error Opping Website", 2);
                              }
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  buildViewInfo("Phone Number", widget.orgdata.phoneNumber),
                  const SizedBox(
                    height: 30,
                  ),
                  buildViewInfo("Website", widget.orgdata.website),
                  const SizedBox(
                    height: 30,
                  ),
                  buildViewInfo("Soical Media", widget.orgdata.socialMedia),
                  const SizedBox(
                    height: 30,
                  ),
                  buildViewInfo(
                      "Organization Type", orgtypes[widget.orgdata.orgtype]),
                  const SizedBox(
                    height: 30,
                  ),
                  buildViewInfo("Bio", widget.orgdata.bio),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}