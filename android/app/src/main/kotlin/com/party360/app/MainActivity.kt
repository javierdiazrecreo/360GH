package com.party360.app

import android.os.Bundle
import com.tuya.smart.home.sdk.TuyaHomeSdk
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // REEMPLAZA ESTO CON TU SECRET REAL DEL PANEL
        TuyaHomeSdk.init(application, "crjtnxhcsjxwvpv5jhku", "TU_SECRET_AQUI")
    }
}