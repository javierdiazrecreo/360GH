buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Versión de Gradle compatible con SDK 36 y Java 17
        classpath("com.android.tools.build:gradle:8.2.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Repositorio oficial de Tuya / Smart Life
        maven { url = uri("https://maven-other.tuya.com/repository/liuyun-temp/") }
        // Repositorio adicional por si faltan dependencias de soporte
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
}

// Configuración de directorios de construcción para Flutter
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