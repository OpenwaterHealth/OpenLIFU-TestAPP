# OpenLIFU Test Application

## Using the Resource File QRC
This Embed resources and ensures that assets are packaged with the application supporting portability, while simplifying paths

### Steps to Compile and Use
1. Compile the QRC File: Run the following command to generate the Python resource file
    ```bash
    pyside6-rcc -o resources_rc.py resources.qrc
    ```
2. Import the Generated Resource File: Add this to the top of your main.py
    ```bash
    import resources_rc
    ```
3. Reference the Resources in QML: Use the qrc:/ prefix to access the resources
    ```bash
    // Reference an image
    Image {
        source: "qrc:/images/OpenwaterLogo.png"
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }

    // Reference a font
    FontLoader {
        id: iconFont
        source: "qrc:/fonts/keenicons-outline.ttf"
    }
    ```

