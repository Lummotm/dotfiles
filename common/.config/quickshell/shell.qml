import Quickshell
import Quickshell.Io // for Process
import QtQuick

PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 20

  Text {
    // give the text an ID we can refer to elsewhere in the file
    id: clock
    anchors.centerIn: parent

    // create a process management object
    Process {
      // the command it will run, every argument is its own string
      id: dateProc
      command: ["date"]
      // run the command immediately
      running: true
      // process the stdout stream using a StdioCollector
      // Use StdioCollector to retrieve the text the process sends
      // to stdout.
      stdout: StdioCollector {
        // Listen for the streamFinished signal, which is sent
        // when the process closes stdout or exits.
        onStreamFinished: clock.text = text // `this` can be omitted
      }
    }
    Timer {
        interval: 1000 //time in ms 
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
  }
}
