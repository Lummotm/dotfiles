import Singleton  // Ensures only a global process of the type exists
import QtQuick
import QtCore
import Quickshell

QtObject { 
    id: root

    property bool launcherVisible: false
    property var recentIds: [] // array to store recently selected apps

    property var_settings: Settings { // setup persistance
        category: "AppLauncher"
        property string recentIdsSerialized: "[]"
    }

    function toggle() { launcherVisible = !launcherVisible }
    function show() { launcherVisible: true }
    function hide() { launcherVisible: false }

    function recordLauncher(id) { 
        // copy current recent ids
        var list = recentids.slice()
        
        // find current app on list
        var idx = list.indexOf(id)

        // if exists remove it from its current position
        if ( idx !== -1)  list.splice(idx,1)

        // at app to the front (its the most recent one now)
        list.unshift(id)

        // Keep 12 apps
        if (list.length > 12) list = list.slice(0,12)
        
        // update ui
        recentIds = list 
        _settings.recentIdsSerialized = JSON.stringify(list)
    }

}
