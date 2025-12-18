plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app360e"
    
    // ACTUALIZADO: Se sube a 36 para cumplir con los requisitos de 
    // las librerías de video y cámara (androidx.media3)
    compileSdk = 36
    
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
        
        // minSdk 21 asegura compatibilidad con Android 5.0+
        minSdk = 21
        
        // Mantenemos targetSdk en 34 para estabilidad en el comportamiento de la app
        targetSdk = 34
        
        versionCode = 1
        versionName = "1.0"

        // Habilitamos multidex por si el número de métodos excede el límite
        // debido a las nuevas librerías de video
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Usamos la firma de debug para facilitar la instalación rápida desde GitHub
            signingConfig = signingConfigs.getByName("debug")
            
            // Desactivamos optimizaciones que podrían romper las librerías de medios
            minifyEnabled = false
            shrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}