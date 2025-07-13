// android/app/build.gradle.kts (TÜM HATALARI ÇÖZEN NİHAİ VERSİYON)

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.plantpal"
    // Gerekli en yüksek versiyon olan 35'e yükseltiyoruz
    compileSdk = 34

    compileOptions {
        // Desugaring özelliğini aktif hale getiriyoruz
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.plantpal"
        // Firebase Auth için minSdk'yı 23'e yükseltiyoruz
        minSdk = 23
        // targetSdk'yı da 35 yapıyoruz
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Desugaring için gerekli kütüphane bağımlılığı
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}