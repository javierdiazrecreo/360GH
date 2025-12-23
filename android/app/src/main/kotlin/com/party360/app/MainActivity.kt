package com.party360.app

import android.os.Bundle
import com.tuya.smart.home.sdk.TuyaHomeSdk
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Inicialización del SDK de Tuya
        // REEMPLAZA "Tp4que4gthwrtpqw35s9xfdqeveagpmu5" con el de tu panel de Tuya
        TuyaHomeSdk.init(application, "crjtnxhcsjxwvpv5jhku", "TU_APP_SECRET_AQUI")
    }
}