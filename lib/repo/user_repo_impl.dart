import 'package:sharebridge/model/user_model.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepoImpl implements UserRepo {

  final auth = FirebaseAuth.instance;                            // instance sabai function ko lagi banaunu parcha
  final firestore = FirebaseFirestore.instance;

//firestore create code
  @override
  Future<void> addUser(UserModel userModel) {
    return firestore
        .collection("users")
        .doc(userModel.id)
        .set(userModel.toMap());
  }

  @override
  Future<void> deleteUser(String id) {
    return firestore
        .collection("users")
        .doc(id)
        .delete();
  }

  @override
  Future<void> editProfile(UserModel userModel) {
    return firestore
        .collection("users")
        .doc(userModel.id)
        .update(userModel.toMap());
  }

  @override
  Future<void> forgetpassword(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {            // backend sanga interact garnu lai function garnu paracha. Note: database sanga connect garnu lai repo_impl banako. (parameter not passed here because for all u dont need to do it)
    final users = await firestore
        .collection("users")
        .get();
    List<UserModel> data = [];      // empty list banako

    for (int i = 0; i <= users.docs.length; i++) {            // derai data (list of data) .docs bhaneh object ma auncha ani euta matrai data ho bhaneh .data ma auncha
      data.add(UserModel.fromMap(users.docs[i].data()));      // yo for loop ma document ko length jati cha teti samma for loop run huncha. ani everytime for loop use hunda hamro data yo data bhanneh variable ma bascha.
    }
    return data;
  }

  @override
  Future<UserModel> getUserById(String id) async {   // repo leh fetch gareko data usermodel ma rakhcha (passes in parameter string id) (parameter selective cha so specific userid pathako)
    final users = await firestore
        .collection("users")
        .doc(id)                                // yo id parameter pass bata ako hamro parameter ma just id cha. so id lekheko
        .get();
    final data = users.data();                  // database bata ako data yo data bhitra auncha

    if (data == null) {
      throw Exception("unable to fetch data");
    }
    return UserModel.fromMap(data);             // database bata ako data yo data bhitra auncha ani tyo data lai chai fetch gareko data bata access gareko
  }

  // Login ko backend code ho yo
  @override
  Future<String> login(String email, String password) async {    // yesma parameter email ra password huncha after writing auth.signInWithEmailAndPassword ehich is we are using authentication ko signInWithEmailAndPassword function
    final user = await auth.signInWithEmailAndPassword(          // final user = await auth.signInWithEmailAndPassword, yo firebaseauth ko function automatically auncha                   // auth is authentication ko instance ho                                        // signInWithEmailAndPassword yo firebaseauth ko function automatically auncha
        email: email, password: password);    // email ma parameter bata ako email pass garneh
    final userId = user.user?.uid;            // after login .user variable ma sabai login ko data is stored inside it.       //(user ko pichadi "?" symbol rakheko so it becomes nullable. userid ma value aunu pani sakcha naaunu pani sakcha)        Note: before we didn't add "?" symbol garyp bhaneh error auncha yo userid lai nullable bana bhanera so we added "?" symbol
    if (userId == null) {                // id userid ma value ayena bhane throw login failed else if userid ma value cha bhaneh login successful huncha
      throw Exception("Login failed");
    }
    return userId;                 // yesleh userId return garyo bhaneh login successful huncha
  }

  // after login sabai data login ma bhako will store in this variable (.user) ma store gareko. Login bhaisakehpachi user ko sabai details (.user) bhanne variable bhitra store bhako huncha. login bhaisakeh pachi user ko instance yo user bhanneh variable auncha. for now just logic ko lagi userid matrai chaheko so userid rakheko (user id bhaneko primary key so rakheko) login ko lagi userid chahincha so userid(uid) rakheko


  @override
  Future<void> logout() {
    return auth.signOut();
  }

  @override
  Future<String> signup(String email, String password) async {     // jaba register button thicha hamro 2 function call huncha auth and firestore database . auth function leh email and password lancha ani register gardincha register garera usleh tyo user chai kun userid ma register bhayo tyo response ma dincah hamilai eg: abc123 . aba yo userid lai chai hami database ma as a primary key rakhchau ani usko associated details haru(eg: name, email etc) tyo bhitra rakhchau
    final user = await auth.createUserWithEmailAndPassword(            // auth.createUserWithEmailAndPassword leh email ra password matrai lancha ani response ma euta userid dincha. now yo email bhako user kun userid ma register bhayo bhanera tesko userid cha hami sanga.
        email: email, password: password);
    final userId = user.user?.uid;                     // yo userid lai hami as a primary key liyera ani database ma primary key rakhinchau ani tyo primary key bhitra baki ko details eg: name etc

    if (userId == null) {
      throw Exception("Registration failed");
    }
    return userId;
  }
}

// register garda createUserWithEmailAndPassword (login garda signin, register garda create account ho similar ho just copy paste gareko code logic and then just added createUserWithEmailAndPassword )



// 1st ko authenctication function call huncha ani yesleh hamro email ra password matra lancha. ani response ma userid dincha.
// 2nd ma firestore (database) ma tyo userid lai liyera as a primary key database ma rakcham. ani baki ko details tei "users" bhanneh table bhitra add garcham .

// how data is stored in signup ko lagi: 1st authentication call huncha in signup function ani 2nd firestore ko lagi yo add user function call huncha
