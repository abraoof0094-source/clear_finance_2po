allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    // ...
    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.4" apply false
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

// 1. REGISTER THE FIX FIRST (Before evaluation depends on app)
subprojects {
    afterEvaluate {
        // Fix for libraries (like Isar) missing namespace in newer AGP
        if (plugins.hasPlugin("com.android.library")) {
            // We use 'extensions.findByType' to avoid crashing if the extension isn't found
            val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android != null && android.namespace == null) {
                android.namespace = project.group.toString()
            }
        }
    }
}

// 2. REGISTER TASKS
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// 3. DEPENDENCY LOGIC LAST
subprojects {
    project.evaluationDependsOn(":app")
}
