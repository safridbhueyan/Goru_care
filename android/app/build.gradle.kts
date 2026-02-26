plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.goru_care"
    // Bumping to 36 as required by your camera and YOLO plugins
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.goru_care"
        minSdk = 24 
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    androidResources {
        noCompress.addAll(listOf("tflite", "lite"))
    }
}

flutter {
    source = "../.."
}