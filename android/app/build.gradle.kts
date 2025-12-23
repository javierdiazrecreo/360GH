plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.party360.app"
    // ACTUALIZADO A 36 PARA EVITAR ERRORES DE PLUGINS (Cámara, Video, etc)
    compileSdk = 36

    defaultConfig {
        applicationId = "com.party360.app"
        minSdk = 23 
        targetSdk = 36
        versionCode = 4
        versionName = "1.0"
        
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            // Usamos la firma de debug para que GitHub compile sin pedir certificados
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
    // SDK de Tuya / Smart Life
    implementation("com.tuya.smart:tuyasmart:6.11.0")
    
    // Soporte para Kotlin y Multidex
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Librerías de red que el SDK de Tuya requiere obligatoriamente
    implementation("com.squareup.okhttp3:okhttp:3.14.9")
    implementation("com.squareup.okio:okio:1.17.5")
    implementation("com.alibaba:fastjson:1.1.67.android")
}