// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.1.0") // Kendi Gradle plugin versiyonunuz
        // Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.20") // Kendi Kotlin versiyonunuz

        // Firebase Google Services plugin'ini BURAYA EKLEYİN:
        classpath("com.google.gms:google-services:4.4.1") // <-- BU SATIRI EKLEYİN (Versiyonu güncel tutun!)
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // jcenter() // Eğer varsa, genellikle kaldırılması önerilir.
    }
}

// Sizin paylaştığınız diğer kısımlar muhtemelen buranın altında yer alıyor.
// Örneğin:
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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