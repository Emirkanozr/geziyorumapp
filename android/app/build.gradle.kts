plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Google Services plugin'ini buraya ekleyin:
    id("com.google.gms.google-services") // <-- BU SATIRI EKLEYİN
}

android {
    namespace = "com.example.geziyorum"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.geziyorum"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies { // <-- BU BLOK ZATEN VARDI, İÇİNE AŞAĞIDAKİLERİ EKLEYİN
    // Import the Firebase BoM (Bill of Materials)
    // Bu, Firebase bağımlılıklarının versiyonlarını otomatik olarak yönetir.
    implementation(platform("com.google.firebase:firebase-bom:32.7.4")) // <-- BU SATIRI EKLEYİN (versiyonu güncel tutun)

    // Declare the dependencies for the desired Firebase products
    // Authentication ve Firestore için temel bağımlılıklar
    implementation("com.google.firebase:firebase-auth") // <-- BU SATIRI EKLEYİN
    implementation("com.google.firebase:firebase-firestore") // <-- BU SATIRI EKLEYİN (Eğer Firestore kullanacaksanız, genel bir uygulama için sıkça kullanılır)
    // Diğer Firebase ürünlerini kullanacaksanız buraya ekleyebilirsiniz (örneğin Analytics)
    // implementation("com.google.firebase:firebase-analytics")
}