// android/app/build.gradle.kts (TÜM HATALARI ÇÖZEN NİHAİ VERSİYON)

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.plantpal"
    // Gerekli en yüksek versiyon olan 35'e yükseltiyoruz
    compileSdk = 35

    compileOptions {
        // <<<--- HATA ÇÖZÜMÜ 1: Desugaring özelliğini aktif hale getiriyoruz
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.plantpal"
        // Firebase Auth için minSdk'yı 23'e yükseltiyoruz
        minSdk = 23
        // targetSdk'yı da 35 yapıyoruz
        targetSdk = 35
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
    // <<<--- HATA ÇÖZÜMÜ 2: Desugaring için gerekli kütüphane bağımlılığı
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}