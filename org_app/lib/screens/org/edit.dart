// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/org/form.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/future_builder.dart';
import 'package:org/widgets/profile_widget.dart';

import '../../server.dart';

typedef ResCallback = Future<Response> Function();

class EditOrg extends StatefulWidget {
  XFile? profileImage;
  XFile? backgroundImage;
  Org? orgdata;

  EditOrg({super.key});

  @override
  State<EditOrg> createState() => _EditOrgState();
}

class _EditOrgState extends State<EditOrg> {
  bool allowPress = true;
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    return RefreshIndicator(
      onRefresh: () async {
        widget.orgdata = mapOrg(await runFun(context, getProfile));
        setState(() {});
      },
      child: BuildFuture(
          callback: getProfile,
          mapper: mapOrg,
          builder: (data) {
            widget.orgdata = data;
            return Scaffold(
              appBar: buildAppBar(context, "Edit Account",
                  button: const BackButton()),
              body: FormBuilder(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ProfileWidget(
                      background: widget.backgroundImage,
                      profile: widget.profileImage,
                      bgPath: widget.orgdata!.orgBackgroundPic,
                      imagepath: widget.orgdata!.orgPic,
                      isEdit: true,
                      onClick: () async {
                        widget.profileImage =
                            await picker.pickImage(source: ImageSource.gallery);
                        setState(() {});
                      },
                      onClickbg: () async {
                        widget.backgroundImage =
                            await picker.pickImage(source: ImageSource.gallery);
                        setState(() {});
                      },
                    ),
                    OrgForm(
                      orgdata: widget.orgdata!,
                      resetSelectors: () {
                        if (widget.profileImage == null &&
                            widget.backgroundImage == null) {
                          snackbar(context, "No Image Has Been Selected", 2);
                          return;
                        }
                        widget.profileImage = null;
                        widget.backgroundImage = null;
                        setState(() {});
                        snackbar(context, "Cleared Selected Images", 3);
                      },
                      mainButton: () {
                        FormRequestHandler(
                            orgdata: widget.orgdata!,
                            formKey: _formKey,
                            requestHandler: (data, res) async {
                              return await appUpdateHandler(
                                  orgdata: widget.orgdata!,
                                  data: data,
                                  res: res,
                                  formkey: _formKey,
                                  context: context,
                                  profileImage: widget.profileImage,
                                  backgroundImage: widget.backgroundImage);
                            },
                            setState: () => setState(() {}),
                            context: context,
                            profileImage: widget.profileImage,
                            backgroundImage: widget.backgroundImage);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  bool didFieldsChange(GlobalKey<FormBuilderState> formkey, Org orgdata) {
    Map<String, dynamic> mapedOrg = {
      'name': orgdata.orgName,
      'email': orgdata.email,
      'phoneNumber': orgdata.phoneNumber.toString(),
      'org_type': orgdata.orgtype,
      'bio': orgdata.bio,
      'website': orgdata.website,
      'socialMedia': orgdata.socialMedia,
    };

    for (var key in mapedOrg.keys) {
      if (formkey.currentState!.fields[key]?.value != mapedOrg[key]) {
        return true;
      }
    }
    if (orgdata.location != getLocationString(context)) return true;

    return false;
  }

  Future<Response> appUpdateHandler(
      {required Org orgdata,
      required Response res,
      required Map<String, dynamic> data,
      required GlobalKey<FormBuilderState> formkey,
      required BuildContext context,
      required XFile? profileImage,
      required XFile? backgroundImage}) async {
    if (profileImage == null &&
        backgroundImage == null &&
        didFieldsChange(formkey, orgdata)) {
      res =
          await runFun(context, () async => await updateProfileNoImages(data));
    } else if (didFieldsChange(formkey, orgdata) ||
        profileImage != null ||
        backgroundImage != null) {
      res = await runFun(
        context,
        () async {
          return await formREQ(data, profileImage, backgroundImage,
              "$devServer/org/update", "PATCH");
        },
      );
    } else {
      res.statusCode = 201;
      res.status = "success";
      res.data = {"msg": "No Changes To Save"};
      return res;
    }
    return res;
  }
}