plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.party360.app"
    compileSdk = 34 // Ajustado a 34 para estabilidad con el SDK de Tuya

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    copy {
        // Esto ayuda a Flutter a encontrar las dependencias nativas
    }

    defaultConfig {
        applicationId = "com.party360.app"
        // El SDK de Tuya requiere mínimo API 23
        minSdk = 23 
        targetSdk = 34
        versionCode = 4
        versionName = "1.0"
        
        // Necesario porque el SDK de Tuya es grande
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            // Usamos la firma de debug para pruebas rápidas en GitHub
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

// AQUÍ ES DONDE VAN LAS LIBRERÍAS DE TUYA
dependencies {
    // SDK principal de Tuya / Smart Life
    implementation("com.tuya.smart:tuyasmart:6.11.0")
    
    // Soporte para Kotlin y MultiDex
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Librerías de soporte necesarias para el SDK
    implementation("com.squareup.okhttp3:okhttp:3.14.9")
    implementation("com.alibaba:fastjson:1.1.67.android")
}