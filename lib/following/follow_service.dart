import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'models/Follow.dart';

class FollowService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot lastFollow;
  DocumentSnapshot lastNotification;

  /// fetch follows
  Stream<List<Follow>> fetchFollowing(
      {@required String uid, @required int pageSize}) {
    return firestore
        .collection('profiles')
        .doc(uid)
        .collection('following')
        .orderBy('time')
        .limit(pageSize)
        .snapshots()
        .map(
      (list) {
        if (list.docs.isNotEmpty) {
          lastFollow = list.docs.last;
        }    
        return list.docs
            .map((document) => Follow.fromFirestore(document))
            .toList();
      },
    );
  }

  /// fetch and return more follows, from current last. If no more follows return null
  Future<List<Follow>> fetchMoreFollowing(
      {@required String uid, @required int pageSize}) async {
    final follows = await firestore
        .collection('profiles')
        .doc(uid)
        .collection('following')
        .orderBy('time')
        .startAfterDocument(lastFollow)
        .limit(pageSize)
        .get();
    if (follows.docs.isNotEmpty) {
      lastFollow = follows.docs.last;
    }
    return follows.docs
        .map((document) => Follow.fromFirestore(document))
        .toList();
  }

  /// return id of all followings, useful if needed to subscribe or unsubscribe
  Future<List<String>> getAllFollowingIds(String uid) async {
    final follows = await firestore
        .collection('profiles')
        .doc(uid)
        .collection('following')
        .get();
    return follows.docs.map((document) => document.id).toList();
  }

  /// follow to a spesific book
  Future<void> follow({@required String uid, @required Follow follow}) {
    return firestore
        .collection('profiles')
        .doc(uid)
        .collection('following')
        .doc(follow.pid)
        .set(follow.toMap(), SetOptions(merge: true));
  }

  /// get following status stream
  Stream<bool> getFollowingStatus({@required String uid, @required String id}) {
    return firestore
        .collection('profiles')
        .doc(uid)
        .collection('following')
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// remove a profile follow
  Future<void> removeFollowing({@required String id, @required String uid}) {
    return firestore
        .collection('profiles')
        .doc(uid)
        .collection('following')
        .doc(id)
        .delete();
  }

  /// remove a notification for a spesific followed book
  Future<void> removeFollowingNotification(
      {@required String uid, @required String id}) async {
    await firestore
        .collection('profiles')
        .doc(uid)
        .collection('following')
        .doc(id)
        .update({'notification': false});
  }
}
