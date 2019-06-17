## IOT Plartform Service & Mobile app deployment and configuration

The purpose of this guide is to provide the four steps to setting up the Iot Platform service and a sample registered Android device, which will send accelrometer data to the IoT Platform.

### A. Register Device in the IBM Cloud IoTservice

1. Log in to the [IBM Cloud account](https://cloud.ibm.com).
2. On your dashboard locate Resource List tile and Click **_Cloud Foundry Services_**
3. In the Resource List click the **_>_** next to Cloud Foundry Services and locate the IoT service you created with Terraform under the name **_IoT_test_**, click **_IoT_test_** name.
4. Next page will show the IOT service management page, Click the **_Launch_** button to open the Watson IoT Platform dashboard. The IBM Watson IoT Platform dashboard is displayed, which is a service that is independent of the IBM Cloud. An organization ID is assigned to the app, and we will need this ID later when developing the mobile app. In this scenario, the organization ID is `vaf7mh`, which is displayed under the login information in the upper right corner of the dashboard.
5. On the left menu, which pops out when we hover over it, click **_Devices_**. Then, click **_Add a device type_**. In the organization, we can have multiple device types each with multiple devices. A device type is a group of devices that share characteristics; for example, they might provide the same sensor data. In our case, the device type name must be “Android” (this device type name is required by the app that we will use later).
6. Click **_Next_**. A page is displayed where we can enter metadata about the device type, such as a serial number or model. we don’t need to specify this information for this demo. Just click **_Done_**.
7. Click **_Register Devices_**. Enter the device ID. The device ID can be, for example, the MAC address of the smartphone. However, it must be unique within the organization only. Therefore, we might enter, as I did here, something like “priyank-s7”.
8. Click **_Next_**. A page is displayed where we could enter metadata about the device. Leave it blank, and click **_Next_**.
9. Provide a value for the authentication token. Remember this value for later. Then, click **_Next_**.
10. Click **_Done_**.
11. Click **_Back_**.

### B. Install the Android app

We will use the IoT Starter for Android app to read and send sensor data on the smartphone. The source code and documentation of the app are in the [iot-starter-for-android GitHub project](https://github.com/ibm-watson-iot/iot-starter-for-android).

1. On the phone, go to **_Settings > Security_**. Under Device Administration, enable **_Unknown sources_**. Now we can install .apk files from outside of Google Play. This step might vary depending upon the version of the Android OS, as in recent releases of Android, this permission needs to be given on per app basis.
2. Open the browser on the phone, and enter this URL: https://github.com/deveops/iot-starter-for-android/releases
3. Search for the **_iotstarter-v2.1.0.apk_** link, and click the link to download the .apk file.
4. Click the downloaded file, and confirm that we want to install the app.
5. The IoT Starter app is now installed on the phone

### C. Configure your Android app

1. Start the IoT Starter app.
2. Click **_Skip tutorial_**.
3. Enter the following parameters: Organization: The organization ID that was displayed on the IBM IoT server (at the start of ” “). For example, vaf7mh in this scenario. Device ID: The device ID that was configured, at the end of section A step 10 For example, priyank-s7 in this scenario. Auth Token: The authorization token that was specified in ” .” Check Use SSL.
4. Click **_Activate Sensor_**. Now the app collects data from the acceleration sensor in the smartphone and sends the data to the IBM IoT server. The app displays the accelerometer data and the number of messages that were published or received.

### D. Creating the API Key and Auth token for the Rickshaw4IoT application

1. In the Watson IoT Platform dashboard, go to **_Apps > API Keys_**.
2. Click **_Generate API Key_**.<br/>
   **_Important:_** Make a note of the API key and token pair. Authentication tokens are non-recoverable. If you lose or forget this token, you will need to re-register the API key to generate a new authentication token.
   - An example of an API key is a-organization_id-a84ps90Ajs
   - An example of a token is MP\$08VKz!8rXwnR-Q\*
3. Add a comment to identify the API key in the dashboard, for example: Key to connect Rickshaw4IoT.
4. Click **_Finish_**.
