package com.party360.app

import android.os.Bundle
import com.tuya.smart.home.sdk.TuyaHomeSdk
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Inicializa el SDK con tus credenciales
        // AppKey: crjtnxhcsjxwvpv5jhku
        // Reemplaza "TU_APP_SECRET" por el valor de tu panel de Tuya
        TuyaHomeSdk.init(application, "crjtnxhcsjxwvpv5jhku", "TU_APP_SECRET")
    }
}