plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe ir después de Android y Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app360e"
    // Forzamos la versión 34 para evitar errores de compatibilidad en la nube
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.app360e"
        
        // minSdk 21 asegura que funcione desde Android 5.0 en adelante
        minSdk = 21
        // targetSdk 34 es el estándar actual para Google Play y Samsung modernos
        targetSdk = 34
        
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // Usamos la configuración de debug para que GitHub pueda generar el APK sin pedirte certificados privados
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}