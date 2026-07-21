plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bggmeeple.bgg_meeple"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.bggmeeple.bgg_meeple"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val releaseKeystorePath = System.getenv("BGG_MEEPL_KEYSTORE_PATH")
                ?: "../keystore/bgg_meeple_release.keystore"
            storeFile = file(releaseKeystorePath)
            storePassword = System.getenv("BGG_MEEPL_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("BGG_MEEPL_KEY_ALIAS") ?: "bgg_meeple"
            keyPassword = System.getenv("BGG_MEEPL_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = if (
                System.getenv("BGG_MEEPL_KEYSTORE_PASSWORD") != null &&
                System.getenv("BGG_MEEPL_KEY_PASSWORD") != null
            ) {
                signingConfigs.getByName("release")
            } else {
                // Fall back to debug signing when release credentials are not available
                // (e.g. local development without a release keystore).
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
