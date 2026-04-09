import org.gradle.api.tasks.Delete

// 1️⃣ buildscript block (for plugins like Google Services)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0") // AGP version
        classpath("com.google.gms:google-services:4.3.15") // ✅ Google services plugin
    }
}

// 2️⃣ All projects repositories
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3️⃣ Optional: custom build directories
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// 4️⃣ Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}