////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import '../lib/src/configuration.dart' show ClientResetHandlerInternal, ClientResyncModeInternal, BeforeResetCallback, AfterResetCallback, ClientResetCallback;
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest("Configuration.flexibleSync set recoverOrDiscard as a default resync mode", (appConfiguration) async {
    final app = App(appConfiguration);
    final user = await getIntegrationUser(app);
    expect(
        Configuration.flexibleSync(
          user,
          [Task.schema, Schedule.schema],
          clientResetHandler: ManualRecoveryHandler((syncError) {}),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.manual);
    expect(
        Configuration.flexibleSync(
          user,
          [Task.schema, Schedule.schema],
          clientResetHandler: const DiscardUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.discardLocal);
    expect(
        Configuration.flexibleSync(
          user,
          [Task.schema, Schedule.schema],
          clientResetHandler: const RecoverUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.recover);

    expect(
        Configuration.flexibleSync(
          user,
          [Task.schema, Schedule.schema],
          clientResetHandler: const RecoverOrDiscardUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.recoverOrDiscard);

    expect(Configuration.flexibleSync(user, [Task.schema, Schedule.schema]).clientResetHandler.clientResyncMode, ClientResyncModeInternal.recoverOrDiscard);
  });

  baasTest('ManualRecoveryHandler error is reported in callback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final resetCompleter = Completer<ClientResetError>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((syncError) {
        resetCompleter.complete(syncError);
      }),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    await triggerClientReset(realm);

    final error = await resetCompleter.future;
    expect(error.message, contains('Bad client file identifier'));
  });

  baasTest('ManualRecoveryHandler with async callback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    int timeTakenForManualReset = 0;
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((syncError) async {
        final startDateTime = DateTime.now();
        await Future<void>.delayed(Duration(seconds: 2));
        final endDateTime = DateTime.now();
        timeTakenForManualReset = endDateTime.difference(startDateTime).inSeconds;
      }),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    await triggerClientReset(realm);
    await waitForCondition(() => timeTakenForManualReset > 0, timeout: Duration(seconds: 15));

    expect(timeTakenForManualReset, greaterThanOrEqualTo(2));
  }, skip: "Enable after async manual reset");

  baasTest('Initiate resetRealm on ManualRecoveryHandler callback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final resetCompleter = Completer<ClientResetError>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((clientResetError) {
        resetCompleter.complete(clientResetError);
      }),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    final resetRealmFuture = resetCompleter.future.then((ClientResetError clientResetError) {
      realm.close();
      clientResetError.resetRealm(app, config.path);
    });

    await triggerClientReset(realm);

    await resetRealmFuture;
    expect(File(config.path).existsSync(), isFalse);
  });

  baasTest('Initiate resetRealm on ManualRecoveryHandler callbach fails when Realm in use', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final resetCompleter = Completer<ClientResetError>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((clientResetError) {
        resetCompleter.complete(clientResetError);
      }),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    final resetRealmFuture = resetCompleter.future.then(
      (ClientResetError clientResetError) => clientResetError.resetRealm(app, config.path),
    );

    await triggerClientReset(realm);

    await expectLater(resetRealmFuture, throws<RealmException>("Realm file is in use"));
    expect(File(config.path).existsSync(), isTrue);
  }, skip: !Platform.isWindows);

  for (Type clientResetHandlerType in [
    RecoverOrDiscardUnsyncedChangesHandler,
    RecoverUnsyncedChangesHandler,
    DiscardUnsyncedChangesHandler,
  ]) {
    baasTest('$clientResetHandlerType.manualResetFallback invoked when throw an error on Before Callback', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onManualResetFallback = Completer<ClientResetError>();
      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            beforeResetCallback: (beforeFrozen) => throw Exception("This fails!"),
            manualResetFallback: (clientResetError) => onManualResetFallback.complete(clientResetError),
          ));

      final realm = await Realm.open(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await expectLater(await onManualResetFallback.future, isA<ClientResetError>());
    });

    baasTest('$clientResetHandlerType.manualResetFallback invoked when throw an error on After Callbacks', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onManualResetFallback = Completer<ClientResetError>();
      void afterResetCallback(Realm beforeFrozen, Realm after) {
        throw Exception("This fails!");
      }

      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            afterRecoveryCallback: clientResetHandlerType != DiscardUnsyncedChangesHandler ? afterResetCallback : null,
            afterDiscardCallback: clientResetHandlerType == DiscardUnsyncedChangesHandler ? afterResetCallback : null,
            manualResetFallback: (clientResetError) => onManualResetFallback.complete(clientResetError),
          ));

      final realm = await Realm.open(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await expectLater(await onManualResetFallback.future, isA<ClientResetError>());
    });

    baasTest('$clientResetHandlerType.Before and After callbacks are invoked', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onBeforeCompleter = Completer<void>();
      final onAfterCompleter = Completer<void>();
      void afterResetCallback(Realm beforeFrozen, Realm after) {
        onAfterCompleter.complete();
      }

      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            beforeResetCallback: (beforeFrozen) => onBeforeCompleter.complete(),
            afterRecoveryCallback: clientResetHandlerType != DiscardUnsyncedChangesHandler ? afterResetCallback : null,
            afterDiscardCallback: clientResetHandlerType == DiscardUnsyncedChangesHandler ? afterResetCallback : null,
          ));

      final realm = await Realm.open(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await onBeforeCompleter.future;
      await onAfterCompleter.future;
    });
  }
  baasTest('AfterDiscard callbacks is invoked for RecoverOrDiscardUnsyncedChangesHandler', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final onBeforeCompleter = Completer<void>();
    final onAfterCompleter = Completer<void>();
    bool recovery = false;
    bool discard = false;

    final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
        clientResetHandler: RecoverOrDiscardUnsyncedChangesHandler(
          beforeResetCallback: (beforeFrozen) => onBeforeCompleter.complete(),
          afterRecoveryCallback: (Realm beforeFrozen, Realm after) {
            onAfterCompleter.complete();
            recovery = true;
          },
          afterDiscardCallback: (Realm beforeFrozen, Realm after) {
            onAfterCompleter.complete();
            discard = true;
          },
        ));

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    await disableAutomaticRecovery();
    await triggerClientReset(realm);

    await onBeforeCompleter.future;
    await onAfterCompleter.future;
    expect(recovery, isFalse);
    expect(discard, isTrue);
  });

  baasTest('DiscardUnsyncedChangesHandler notifications', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);
    int beforeResetCallbackOccured = 0;
    int afterDiscardCallbackOccured = 0;
    final onBeforeCompleter = Completer<void>();
    final onAfterCompleter = Completer<void>();

    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: DiscardUnsyncedChangesHandler(
        beforeResetCallback: (beforeFrozen) {
          beforeResetCallbackOccured++;
          onBeforeCompleter.complete();
        },
        afterResetCallback: (beforeFrozen, after) {
          afterDiscardCallbackOccured++;
          onAfterCompleter.complete();
        },
      ),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>());
    });
    await realm.subscriptions.waitForSynchronization();
    await realm.syncSession.waitForDownload();
    final tasksCount = realm.all<Task>().length;
    realm.syncSession.pause();

    realm.write(() => realm.add(Task(ObjectId())));
    expect(tasksCount, lessThan(realm.all<Task>().length));

    final notifications = <RealmResultsChanges>[];
    final subscription = realm.all<Task>().changes.listen((event) {
      notifications.add(event);
    });

    await waitForCondition(() => notifications.length == 1);
    await triggerClientReset(realm, restartSession: false);
    realm.syncSession.resume();

    await onBeforeCompleter.future;
    await onAfterCompleter.future;
    expect(beforeResetCallbackOccured, 1);
    expect(afterDiscardCallbackOccured, 1);

    await waitForCondition(() => notifications.length == 2);

    await subscription.cancel();
    expect(notifications.firstWhere((n) => n.deleted.isNotEmpty), isNotNull);
  });

  baasTest('Async BeforeResetCallback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);
    int beforeResetCallbackOccured = 0;
    int afterResetCallbackOccured = 0;
    final onAfterCompleter = Completer<void>();

    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: DiscardUnsyncedChangesHandler(
        beforeResetCallback: (beforeFrozen) async {
          await Future<void>.delayed(Duration(seconds: 1));
          beforeResetCallbackOccured++;
        },
        afterResetCallback: (beforeFrozen, after) {
          if (beforeResetCallbackOccured == 0) {
            onAfterCompleter.completeError(Exception("BeforeResetCallback is still not completed"));
          }
          afterResetCallbackOccured++;
          onAfterCompleter.complete();
        },
      ),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();
    await triggerClientReset(realm);

    await onAfterCompleter.future;
    expect(afterResetCallbackOccured, 1);
    expect(beforeResetCallbackOccured, 1);
  });

  baasTest('Async AfterResetCallback and ManualResetFallback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);
    int beforeResetCallbackOccured = 0;
    int afterResetCallbackOccured = 0;
    int manualResetFallbacOccured = 0;

    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: DiscardUnsyncedChangesHandler(
        beforeResetCallback: (beforeFrozen) {
          beforeResetCallbackOccured++;
        },
        afterResetCallback: (beforeFrozen, after) async {
          await Future<void>.delayed(Duration(seconds: 1));
          afterResetCallbackOccured++;
          throw Exception("Cause manualResetFallback");
        },
        manualResetFallback: (clientResetError) async {
          if (afterResetCallbackOccured == 0) {
            throw Exception("AfterResetCallback is still not completed");
          }
          await Future<void>.delayed(Duration(seconds: 1));
          manualResetFallbacOccured++;
        },
      ),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();
    await triggerClientReset(realm);

    await waitForCondition(() => manualResetFallbacOccured == 1, timeout: Duration(seconds: 15));

    expect(manualResetFallbacOccured, 1);
    expect(afterResetCallbackOccured, 1);
    expect(beforeResetCallbackOccured, 1);
  });
}

class Creator {
  static final _constructors = {
    RecoverOrDiscardUnsyncedChangesHandler: (
            {BeforeResetCallback? beforeResetCallback,
            AfterResetCallback? afterRecoveryCallback,
            AfterResetCallback? afterDiscardCallback,
            ClientResetCallback? manualResetFallback}) =>
        RecoverOrDiscardUnsyncedChangesHandler(
            beforeResetCallback: beforeResetCallback,
            afterRecoveryCallback: afterRecoveryCallback,
            afterDiscardCallback: afterDiscardCallback,
            manualResetFallback: manualResetFallback),
    RecoverUnsyncedChangesHandler: (
            {BeforeResetCallback? beforeResetCallback,
            AfterResetCallback? afterRecoveryCallback,
            AfterResetCallback? afterDiscardCallback,
            ClientResetCallback? manualResetFallback}) =>
        RecoverUnsyncedChangesHandler(
          beforeResetCallback: beforeResetCallback,
          afterResetCallback: afterRecoveryCallback,
          manualResetFallback: manualResetFallback,
        ),
    DiscardUnsyncedChangesHandler: (
            {BeforeResetCallback? beforeResetCallback,
            AfterResetCallback? afterRecoveryCallback,
            AfterResetCallback? afterDiscardCallback,
            ClientResetCallback? manualResetFallback}) =>
        DiscardUnsyncedChangesHandler(
          beforeResetCallback: beforeResetCallback,
          afterResetCallback: afterDiscardCallback,
          manualResetFallback: manualResetFallback,
        ),
  };
  static ClientResetHandler create(Type type,
      {BeforeResetCallback? beforeResetCallback,
      AfterResetCallback? afterRecoveryCallback,
      AfterResetCallback? afterDiscardCallback,
      ClientResetCallback? manualResetFallback}) {
    return _constructors[type]!(
        beforeResetCallback: beforeResetCallback,
        afterRecoveryCallback: afterRecoveryCallback,
        afterDiscardCallback: afterDiscardCallback,
        manualResetFallback: manualResetFallback);
  }
}
