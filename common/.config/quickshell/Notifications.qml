import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "config.js" as Config

Scope { // Quickshell plain non visual container so that later can instanciate it with the bar / pill
  id: root
  property bool centerOpen: false

  // Stores past notifications for the center. Populated in onNotification,
  // separate from server.trackedNotifications which holds the live popups.
  ListModel {
    id: history
  }

  NotificationServer {
    id: server
    actionsSupported: true // If notification actions should be advertised as supported by the notification server.
    bodySupported: true // If notification body text should be advertised as supported by the notification server.
    imageSupported: true // If the notification server should advertise that it supports images.

    // qml takes any object and converts it on a viewed one via on + Capitalization
    onNotification: n => {
      history.insert( 0, {
          summary: n.summary,
          body: n.body,
          appName: n.appName,
          urgency: n.urgency,
          time: Qt.formatDateTime(new Date(), "HH:mm")
      })
      n.tracked = true
    }
  }

  IpcHandler {
    target: "notifications"
    function toggle(): void { root.centerOpen = !root.centerOpen }
    function show(): void { root.centerOpen = true }
    function hide(): void { root.centerOpen = false }
  }

  // Notification center
  PanelWindow {
    visible: root.centerOpen
    anchors { top: true; right: true }
    margins { top: 12; right: 12 }

    implicitWidth: 380
    // Grow with the history list, capped at 600 so it never covers the whole screen.
    implicitHeight: Math.min(centerCol.implicitHeight + 24, 600)
    color: "transparent"

    Rectangle {
      anchors.fill: parent
      radius: 10
      color: Config.colors.bg
      border.width: 2
      border.color: Config.colors.purple
      clip: true // Keep rounded corners: don't let the list bleed outside the border.

      ColumnLayout {
        id: centerCol
        anchors { fill: parent; margins: 12 } // Content padded from the border.
        spacing: 10

        RowLayout {
          Layout.fillWidth: true

          Text {
            Layout.fillWidth: true
            text: "Notifications"
            color: Config.colors.cyan
            font.family: Config.bar.fontFamily
            font.pixelSize: Config.bar.fontSize + 2
            font.bold: true
          }
          Text {
            text: "Clear All"
            visible: history.count > 0
            color: Config.colors.red
            font.family: Config.bar.fontFamily
            font.pixelSize: Config.bar.fontSize - 1

            MouseArea {
              anchors.fill: parent
              onClicked: history.clear()
            }
          }
        }

        // Scrollable list of past notifications. modelData is not used here
        // because ListModel exposes each entry's fields as role properties
        // (summary, body, time...), unlike the popup's ObjectModel below.
        ListView {
          Layout.fillWidth: true
          // Rough height estimate (70px per card), capped so it scrolls.
          Layout.preferredHeight: Math.min(history.count * 70, 400)
          clip: true
          spacing: 10
          model: history

          delegate: Rectangle {
            id: hcard
            required property string summary
            required property string body
            required property string appName
            required property var urgency
            required property string time

            width: ListView.view.width
            height: 60
            radius: 8
            color: Config.colors.bgDark
            border.width: 2
            border.color: urgency === NotificationUrgency.Critical
            ? Config.colors.red : Config.colors.purple

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 10
              spacing: 2

              RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text { // Title
                  Layout.fillWidth: true
                  text: hcard.summary
                  color: Config.colors.cyan
                  font.family: Config.bar.fontFamily
                  font.pixelSize: Config.bar.fontSize
                  font.bold: true
                  elide: Text.ElideRight
                }

                Text { // Time
                  text: hcard.time
                  color: Config.colors.muted
                  font.family: Config.bar.fontFamily
                  font.pixelSize: Config.bar.fontSize - 2
                }
              }

              Text { // Body
                Layout.fillWidth: true
                visible: text !== ""
                text: hcard.body
                color: Config.colors.fg
                font.family: Config.bar.fontFamily
                font.pixelSize: Config.bar.fontSize - 1
                elide: Text.ElideRight
              }
            }
          }
        }
      }
    }
  }

  // Notifications
  PanelWindow {
    // Hide the popups while the center is open so they don't overlap it.
    visible: !root.centerOpen
    anchors { top: true; right: true }
    margins { top: 12; right: 12 }

    implicitWidth: 380
    implicitHeight: Math.max(1, column.implicitHeight)
    color: "transparent"

    ColumnLayout {
      id: column
      width: parent.width
      spacing: 10

      Repeater {
        model: server.trackedNotifications

        delegate: Rectangle {
          id: card
          required property var modelData

          Timer {
            running: card.modelData.urgency !== NotificationUrgency.Critical
            interval: Config.notifications.timeout
            onTriggered: card.modelData.dismiss()
          }

          Layout.fillWidth: true
          Layout.preferredHeight: 60
          radius: 8
          color: Config.colors.bg
          border.width: 2
          border.color: modelData.urgency === NotificationUrgency.Critical
          ? Config.colors.red : Config.colors.purple

          RowLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Image {
              Layout.preferredHeight: 36
              Layout.preferredWidth: 36
              Layout.alignment: Qt.AlignTop
              fillMode: Image.PreserveAspectFit
              visible: source.toString() !== ""
              source: card.modelData.image || card.modelData.appIcon || ""
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2

              Text { // Title
                Layout.fillWidth: true
                text: card.modelData.summary
                color: Config.colors.cyan
                font.family: Config.bar.fontFamily
                font.pixelSize: Config.bar.fontSize
                font.bold: true
                elide: Text.ElideRight
              }

              Text { // Body
                Layout.fillWidth: true
                visible: text !== ""
                text: card.modelData.body
                color: Config.colors.fg
                font.family: Config.bar.fontFamily
                font.pixelSize: Config.bar.fontSize - 1
                wrapMode: Text.WordWrap
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: card.modelData.dismiss()
          }
        }
      }
    }
  }
}
