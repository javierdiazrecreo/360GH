plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'
}

android {
    namespace "com.javierdiazrecreo.app360"
    compileSdk 34

    defaultConfig {
        applicationId "com.javierdiazrecreo.app360"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation platform("com.google.firebase:firebase-bom:33.5.1")
    implementation "com.google.firebase:firebase-storage"
}
