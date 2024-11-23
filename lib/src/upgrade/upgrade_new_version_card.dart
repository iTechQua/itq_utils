
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:itq_utils/src/upgrade/alert_style_widget.dart';
import 'package:itq_utils/src/upgrade/upgrade_new_version.dart';
import 'package:itq_utils/src/upgrade/upgrade_new_version_messages.dart';

/// A widget to display the upgrade card.
/// The only reason this is a [StatefulWidget] and not a [StatelessWidget] is that
/// the widget needs to rebulid after one of the buttons have been tapped.
/// Override the [createState] method to provide a custom class
/// with overridden methods.
class UpgradeNewVersionCard extends StatefulWidget {
  /// Creates a new [UpgradeNewVersionCard].
  UpgradeNewVersionCard({
    super.key,
    UpgradeNewVersion? upgradeAlert,
    this.margin,
    this.maxLines = 15,
    this.onIgnore,
    this.onLater,
    this.onUpdate,
    this.overflow = TextOverflow.ellipsis,
    this.showIgnore = true,
    this.showLater = true,
    this.showReleaseNotes = true,
  }) : upgrade = upgradeAlert ?? UpgradeNewVersion.sharedInstance;

  /// The upgrade used to configure the upgrade dialog.
  final UpgradeNewVersion upgrade;

  /// The empty space that surrounds the card.
  ///
  /// The default margin is [Card.margin].
  final EdgeInsetsGeometry? margin;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  final int? maxLines;

  /// Called when the ignore button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  final BoolCallback? onIgnore;

  /// Called when the later button is tapped or otherwise activated.
  final VoidCallback? onLater;

  /// Called when the update button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  final BoolCallback? onUpdate;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// Hide or show Ignore button on dialog (default: true)
  final bool showIgnore;

  /// Hide or show Later button on dialog (default: true)
  final bool showLater;

  /// Hide or show release notes (default: true)
  final bool showReleaseNotes;

  @override
  UpgradeNewVersionCardState createState() => UpgradeNewVersionCardState();
}

/// The [UpgradeNewVersionCard] widget state.
class UpgradeNewVersionCardState extends State<UpgradeNewVersionCard> {
  @override
  void initState() {
    super.initState();
    widget.upgrade.initialize();
  }

  /// Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    if (widget.upgrade.debugLogging) {
      if (kDebugMode) {
        print('upgradeAlert: build UpgradeCard');
      }
    }

    return StreamBuilder(
        initialData: widget.upgrade.evaluationReady,
        stream: widget.upgrade.evaluationStream,
        builder: (BuildContext context,
            AsyncSnapshot<UpgradeEvaluateNeed> snapshot) {
          if ((snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.active) &&
              snapshot.data != null &&
              snapshot.data!) {
            if (widget.upgrade.shouldDisplayUpgrade()) {
              return buildUpgradeCard(
                  context, const Key('upgrade_alert_card'));
            } else {
              if (widget.upgrade.debugLogging) {
                if (kDebugMode) {
                  print('upgradeAlert: UpgradeCard will not display');
                }
              }
            }
          }
          return const SizedBox.shrink();
        });
  }

  /// Build the UpgradeCard widget.
  Widget buildUpgradeCard(BuildContext context, Key? key) {
    final appMessages = widget.upgrade.determineMessages(context);
    final title = appMessages.message(upgradeAlertMessage.title);
    final message = widget.upgrade.body(appMessages);
    final releaseNotes = widget.upgrade.releaseNotes;

    if (widget.upgrade.debugLogging) {
      if (kDebugMode) {
        print('upgradeAlert: UpgradeCard: will display');
        print('upgradeAlert: UpgradeCard: showDialog title: $title');
        print('upgradeAlert: UpgradeCard: showDialog message: $message');
        print(
            'upgradeAlert: UpgradeCard: shouldDisplayReleaseNotes: $shouldDisplayReleaseNotes');

        print('upgradeAlert: UpgradeCard: showDialog releaseNotes: $releaseNotes');
      }
    }

    Widget? notes;
    if (shouldDisplayReleaseNotes && releaseNotes != null) {
      notes = Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(appMessages.message(upgradeAlertMessage.releaseNotes) ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                releaseNotes,
                maxLines: widget.maxLines,
                overflow: widget.overflow,
              ),
            ],
          ));
    }

    return Card(
      key: key,
      margin: widget.margin,
      child: AlertStyleWidget(
        title: Text(title ?? ''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(message),
            Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(appMessages.message(upgradeAlertMessage.prompt) ?? '')),
            if (notes != null) notes,
          ],
        ),
        actions: actions(appMessages),
      ),
    );
  }

  void forceRebuild() => setState(() {});

  List<Widget> actions(UpgradeAlertMessages appMessages) {
    final isBlocked = widget.upgrade.blocked();
    final showIgnore = isBlocked ? false : widget.showIgnore;
    final showLater = isBlocked ? false : widget.showLater;
    return <Widget>[
      if (showIgnore)
        TextButton(
            child: Text(
                appMessages.message(upgradeAlertMessage.buttonTitleIgnore) ?? ''),
            onPressed: () {
              // Save the date/time as the last time alerted.
              widget.upgrade.saveLastAlerted();

              onUserIgnored();
              forceRebuild();
            }),
      if (showLater)
        TextButton(
            child: Text(
                appMessages.message(upgradeAlertMessage.buttonTitleLater) ?? ''),
            onPressed: () {
              // Save the date/time as the last time alerted.
              widget.upgrade.saveLastAlerted();

              onUserLater();
              forceRebuild();
            }),
      TextButton(
          child: Text(
              appMessages.message(upgradeAlertMessage.buttonTitleUpdate) ?? ''),
          onPressed: () {
            // Save the date/time as the last time alerted.
            widget.upgrade.saveLastAlerted();

            onUserUpdated();
          }),
    ];
  }

  bool get shouldDisplayReleaseNotes =>
      widget.showReleaseNotes &&
      (widget.upgrade.releaseNotes?.isNotEmpty ?? false);

  void onUserIgnored() {
    if (widget.upgrade.debugLogging) {
      if (kDebugMode) {
        print('upgradeAlert: button tapped: ignore');
      }
    }

    // If this callback has been provided, call it.
    final doProcess = widget.onIgnore?.call() ?? true;

    if (doProcess) {
      widget.upgrade.saveIgnored();
    }

    forceRebuild();
  }

  void onUserLater() {
    if (widget.upgrade.debugLogging) {
      if (kDebugMode) {
        print('upgradeAlert: button tapped: later');
      }
    }

    // If this callback has been provided, call it.
    widget.onLater?.call();

    forceRebuild();
  }

  void onUserUpdated() {
    if (widget.upgrade.debugLogging) {
      if (kDebugMode) {
        print('upgradeAlert: button tapped: update now');
      }
    }

    // If this callback has been provided, call it.
    final doProcess = widget.onUpdate?.call() ?? true;

    if (doProcess) {
      widget.upgrade.sendUserToAppStore();
    }

    forceRebuild();
  }
}
