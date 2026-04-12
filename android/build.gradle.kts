allprojects {
    repositories {
        google()
        mavenCentral()
    }
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
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    project.plugins.withId("com.android.library") {
        val android = project.extensions.getByName("android")
        try {
            val getNamespace = android.javaClass.getMethod("getNamespace")
            val namespace = getNamespace.invoke(android)
            if (namespace == null) {
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                setNamespace.invoke(android, "dev.isar.isar_flutter_libs")
            }
        } catch (e: Exception) {
        }
    }
}

subprojects {
    val configureAndroid = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                val setCompileSdkVersion = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdkVersion.invoke(android, 36)
            } catch (e: Exception) { }
        }
    }
    
    if (project.state.executed) {
        configureAndroid()
    } else {
        project.afterEvaluate { configureAndroid() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
