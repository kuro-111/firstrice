pragma Singleton

import qs.utils
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias appearance: adapter.appearance

    ElapsedTimer {
        id: timer
    }

    FileView {
        path: `${Paths.config}/shell.json`
        watchChanges: true
        onFileChanged: {
            timer.restart();
            reload();
        }
        onLoaded: {
            try {
                JSON.parse(text());
            } catch (e) {
                console.log("Failed to load config");
            }
        }
        onLoadFailed: err => {
            if (err !== FileViewError.FileNotFound)
                console.log("Failed to read config file");
        }
        onSaveFailed: err => console.log("Failed to save config")

        JsonAdapter {
            id: adapter

            property AppearanceConfig appearance: AppearanceConfig {}
        }
    }
}
