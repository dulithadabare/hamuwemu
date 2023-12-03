import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hamuwemu/business_logic/model/app_contact.dart';
import 'package:hamuwemu/business_logic/model/phone_contact.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/add_friends_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/current_status_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/contact_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/styles.dart';
import 'package:hamuwemu/ui/widget/error_message.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:phone_number/phone_number.dart';
import 'package:provider/provider.dart';

class AddFriendsPage extends StatefulWidget {
  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  // TextEditingController searchController = TextEditingController();
  List<Contact>? _contacts;
  List<Contact>? _normalList;
  Set<AppContact> _addedFriendList = <AppContact>{};
  Map<String, AppContact> _appContacts = {};
  bool _permissionDenied = false;

  @override
  void dispose() {
    // searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _fetchContacts();
    // searchController.addListener(() {
    //   filterList();
    // });
  }

  void _remove(AppContact appContact) {
    _addedFriendList.remove(appContact);
  }

  // void _done(BuildContext context, AddFriendsViewModel model) {
  //   Set<int> friendIdList = <int>{};
  //   for (var appContact in model.addedFriendList) {
  //     friendIdList.add(appContact.user.userId!);
  //     print('Add friend ${appContact.user.userId!}');
  //   }
  //   Navigator.of(context).pop(friendIdList);
  // }

  void _done(BuildContext context, AddFriendsViewModel model) {
    Set<UserProfile> friendIdList = <UserProfile>{};
    for (var appContact in model.addedFriendList) {
      friendIdList.add(appContact.user);
      print('Add friend ${appContact.user.displayName!}');
    }
    Navigator.of(context).pop(friendIdList);
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final appContacts = await getAppContacts(contacts);
      // filterList();
      setState(() {
        _appContacts = appContacts;
        _contacts = contacts;
        _normalList = contacts;
      });
    }
  }

  Future<Map<String, AppContact>> getAppContacts(List<Contact> contacts) async {
    String code = await PhoneNumberUtil().carrierRegionCode();
    print('Current Region : $code');
    final contactList = <PhoneContact>[];
    for (var contact in contacts) {
      for (var phone in contact.phones) {
        String internationalFormat = phone.number;
        PhoneNumber phoneNumber;
        if (phone.number.characters.first != '+') {
          try {
            phoneNumber = await PhoneNumberUtil().parse(phone.number, regionCode: code);
            internationalFormat = phoneNumber.international;
          } catch (e) {
            print(e);
          }
        } else {
          try {
            phoneNumber = await PhoneNumberUtil().parse(phone.number);
            internationalFormat = phoneNumber.international;
          } catch (e) {
            print(e);
          }
        }
        // print('International Format : $internationalFormat');
        contactList.add(PhoneContact(displayName: contact.displayName, phoneNumber: internationalFormat));
      }
    }

    final data = await WebApi().getAppContacts(contactList);

    Map<String, AppContact> appContactMap = {};

    for (var appContact in data) {
      appContactMap[appContact.contactList.first.phoneNumber] = appContact;
    }

    return appContactMap;
  }

  // filterList() {
  //   List<Contact> contacts = [];
  //   contacts.addAll(_contacts ?? []);
  //   // favouriteList = [];
  //   _normalList = [];
  //   // strList = [];
  //   if (searchController.text.isNotEmpty) {
  //     contacts.retainWhere((contact) => contact.displayName
  //         .toLowerCase()
  //         .contains(searchController.text.toLowerCase()));
  //   }
  //   _normalList?.addAll(contacts);
  //   setState(() {});
  // }
  //
  // List<Chip> _buildChips() {
  //   return _addedFriendList.map((e) {
  //     final appUser = e.user;
  //     return Chip(
  //       onDeleted: () => _remove(e),
  //       labelPadding: EdgeInsets.all(2.0),
  //       avatar: CircleAvatar(
  //         backgroundColor: Colors.white70,
  //         child: Text(appUser.displayName![0].toUpperCase()),
  //       ),
  //       label: Text(
  //         appUser.displayName!,
  //         style: TextStyle(
  //           color: Colors.white,
  //         ),
  //       ),
  //       backgroundColor: Colors.orange,
  //       elevation: 6.0,
  //       shadowColor: Colors.grey[60],
  //       padding: EdgeInsets.all(8.0),
  //     );
  //   }).toList();
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddFriendsViewModel>(
      create: (_) => AddFriendsViewModel(),
      child: Consumer<AddFriendsViewModel>(
          builder: (context, model, child) {
            return Scaffold(
              appBar: AppBar(
                leading: CloseButton(color: Colors.black,),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: [
                  TextButton(onPressed: () => _done(context, model), child: Text('DONE'),),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16,right: 16,top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Add Friends",style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(top: 16,left: 16,right: 16),
                    //   child: TextField(
                    //     controller: searchController,
                    //     decoration: InputDecoration(
                    //       hintText: "Search",
                    //       hintStyle: TextStyle(color: Colors.grey.shade600),
                    //       prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
                    //       filled: true,
                    //       fillColor: Colors.grey.shade100,
                    //       contentPadding: EdgeInsets.all(8),
                    //       enabledBorder: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(20),
                    //           borderSide: BorderSide(
                    //               color: Colors.grey.shade100
                    //           )
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.only(top: 16,left: 16,right: 16),
                    //   child: Wrap(
                    //     children: _buildChips(),
                    //   ),
                    // ),
                    Expanded(
                      child: ContactList(
                        permissionDenied: _permissionDenied,
                        contacts: _normalList,
                        appContacts: _appContacts.values.toList(),
                        addedFriendList: _addedFriendList,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}

class RemoveButton extends StatefulWidget {
  const RemoveButton({Key? key}) : super(key: key);

  @override
  _RemoveButtonState createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<RemoveButton> {
  bool _loading = false;

  void _leave() async {
    setState(() {
      _loading = true;
    });
    final model = Provider.of<CurrentStatusViewModel>(context, listen: false);
    final message = model.currentStatus?.message;
    serviceLocator<AnalyticsService>().logRemoveCurrentStatus(message: message!);
    await model.removeStatus();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String buttonLabel = 'Remove';
    VoidCallback? onPressed = _loading ? null : () => _leave();

    return RoundedButton( buttonLabel: buttonLabel, onPressed: onPressed, loading: _loading, );
  }
}

class ContactList extends StatefulWidget {
  final bool permissionDenied;
  final Set<AppContact> addedFriendList;
  final List<Contact>? contacts;
  final List<AppContact> appContacts;
  const ContactList({Key? key, required this.permissionDenied, required this.contacts, required this.appContacts, required this.addedFriendList}) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  void _add(AppContact appContact) {
    this.widget.addedFriendList.add(appContact);
    setState(() {});
  }

  void _remove(AppContact appContact) {
    this.widget.addedFriendList.remove(appContact);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AddFriendsViewModel>(context);
    if (model.permissionDenied) return ErrorState(title: 'Permission Denied', subtitle: 'Add contact permission in Settings to view friends');
    if (model.status == ViewModelStatus.busy) return Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: model.appContacts.length,
      itemBuilder: (context, i) {

        final appContact = model.appContacts[i];
        bool added = model.addedFriendList.contains(appContact);
        String title = serviceLocator<ContactService>().getDisplayNameFromAppUser(appContact.user) ?? appContact.user.displayName!;
        String subtitle = appContact.user.phoneNumber ?? 'No Phone';

        return ListTile(
          title: Text(title, style: Styles.listTitle,),
          subtitle: Text(subtitle, style: Styles.listSubtitle,),
          trailing: TextButton(
            onPressed: added
                ? () => model.remove(appContact)
                : () => model.add(appContact),
            child: added ? Text('Remove') : Text('Add'),
          ),
        );
      },
    );


        // return ListTile(
        //   title: Text(contacts![i].displayName),
        //   subtitle: Text(contacts![i].phones.isNotEmpty
        //       ? contacts![i].phones.first.number
        //       : '(none)'),
        //   trailing: appContactKey != null
        //       ? TextButton(
        //           onPressed: added
        //               ? () => _remove(appContacts[appContactKey]!)
        //               : () => _add(appContacts[appContactKey]!),
        //           child: added ? Text('Remove') : Text('Add'),
        //         )
        //       : TextButton(
        //           onPressed: null,
        //           child: Text('Invite'),
        //         ),
        // );
  }
}






