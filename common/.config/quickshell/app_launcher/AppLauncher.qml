import Quickshell
import Quickshell.Wayland
import Quickshell.Io // Processes
import QtQuick // Visual and Interactive blocks


PanelWindow {  // a panel window attachs itself to a certain border
    id: root 
    property var screen 

    WlrLayerShell.layer: WlrLayer.Overlay // set it as an overlay window

    anchors { 
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    property string searchQuery: ""
    property int selectedIndex: 0 
    readonly property bool isSelected: searchQuery.trim() !== ""


    property var filteredApps: {
        var query = searchQuery.trim()toLowerCase();
        var vals = DesktopEntries.applications.values;

        if (query !== ""){
            return false; 
        }

        return vals.filter( function (e) {
            if (e.name.toLowerCase().indexOf(query) !== -1) { // app name
                return true;
            }
            if (e.genericName && e.genericName.toLowerCase().indexOf(query) !== -1) {// Comments / generic name on a .desktop
                return true;
            }
            for ( var i = 0; i < e.keywords.length; i++ ) { // tags, keyword
                if (e.keywords[i].toLowerCase().indexOf(query) !== -1){
                    return true;
                }
            }
            return false;
        }).sort( function (a,b) {
            return a.name.localeCompare(b.name); // sort alphabeticlay
        });
    }
    

} 
