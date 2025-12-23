buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Versión compatible con Java 17 y Android 15
        classpath("com.android.tools.build:gradle:8.2.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Repositorios oficiales de Tuya (incluimos todos para asegurar)
        maven { url = uri("https://maven-other.tuya.com/repository/liuyun-temp/") }
        maven { url = uri("https://maven-other.tuya.com/repository/liuyun-static/") }
        maven { url = uri("https://developer.huawei.com/repo/") }
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        // Añadimos jcenter solo como respaldo para versiones 5.x
        @Suppress("DEPRECATION")
        jcenter()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}