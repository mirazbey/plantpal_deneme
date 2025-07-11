// android/app/build.gradle.kts (NİHAİ VE EN GÜNCEL VERSİYON)

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.plantpal"
    // Gerekli en yüksek versiyon olan 35'e yükseltiyoruz
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.plantpal"
        minSdk = 21 // Çoğu paket için en az 21 gerekir.
        targetSdk = 35 
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}