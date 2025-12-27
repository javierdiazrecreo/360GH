plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.party360.app"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.party360.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 4
        versionName = "1.0"

        // Flutter maneja multidex automáticamente si es necesario
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Usamos la firma debug por ahora (válido para GitHub Actions)
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ❌ NO agregar nada aquí manualmente
    // Flutter, Firebase y plugins se inyectan automáticamente
}
