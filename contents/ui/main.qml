import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

PlasmoidItem {
    id: root
    width: 800
    height: 400

    property var osymData: []
    property var lastData: []

    Timer {
        interval: 1000 // 5 saniye
        running: true
        repeat: true
        onTriggered: {
            root.loadData()
        }
    }

    Component.onCompleted: {
        root.loadData()
    }

    function loadData() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://raw.githubusercontent.com/codermert/ais_duyurular/main/sonuc.json", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var newData = JSON.parse(xhr.responseText);
                    if (JSON.stringify(newData) !== JSON.stringify(root.lastData)) {
                        var newItems = findNewItems(newData, root.lastData);
                        if (newItems.length > 0) {
                            root.osymData = newData;
                            sendNotifications(newItems);
                        }
                        root.lastData = newData;
                    }
                } else {
                    console.error("Veri yüklenemedi");
                }
            }
        }
        xhr.send();
    }

    function findNewItems(newData, oldData) {
        return newData.filter(item => !oldData.some(oldItem => 
            oldItem.sinav === item.sinav && 
            oldItem.islemtipi === item.islemtipi && 
            oldItem.sinavtarihi === item.sinavtarihi
        ));
    }

    function sendNotifications(newItems) {
        newItems.forEach(item => {
            var message = item.sinav + " - " + item.islemtipi + " - " + item.sinavtarihi;
            sendNotification("Yeni ÖSYM güncellemesi", message);
        });
    }

    function sendNotification(title, message) {
        var process = Qt.createQProcess();
        process.start("notify-send", [title, message]);
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        ListView {
            width: parent.width
            model: root.osymData
            delegate: ItemDelegate {
                width: parent.width
                height: 40
                contentItem: RowLayout {
                    spacing: 8

                    PlasmaComponents.Label {
                        text: modelData.sinav
                        Layout.preferredWidth: parent.width * 0.25
                        elide: Text.ElideRight
                    }
                    PlasmaComponents.Label {
                        text: modelData.islemtipi
                        Layout.preferredWidth: parent.width * 0.15
                        elide: Text.ElideRight
                    }
                    PlasmaComponents.Label {
                        text: modelData.sinavtarihi
                        Layout.preferredWidth: parent.width * 0.15
                        elide: Text.ElideRight
                    }
                    PlasmaComponents.Label {
                        text: modelData.durum
                        Layout.preferredWidth: parent.width * 0.18
                        elide: Text.ElideRight
                    }
                }
            }

            header: Rectangle {
                width: parent.width
                height: 40
                color: "#4a90e2" // Mavi renk

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5

                    PlasmaComponents.Label {
                        text: "SINAV / TERCİH ADI"
                        font.bold: true
                        color: "white"
                        Layout.preferredWidth: parent.width * 0.25
                    }
                    PlasmaComponents.Label {
                        text: "İŞLEM TİPİ"
                        font.bold: true
                        color: "white"
                        Layout.preferredWidth: parent.width * 0.15
                    }
                    PlasmaComponents.Label {
                        text: "SINAVIN TARİHİ"
                        font.bold: true
                        color: "white"
                        Layout.preferredWidth: parent.width * 0.15
                    }
                    PlasmaComponents.Label {
                        text: "DURUMU"
                        font.bold: true
                        color: "white"
                        Layout.preferredWidth: parent.width * 0.18
                    }
                }
            }
        }
    }
}
