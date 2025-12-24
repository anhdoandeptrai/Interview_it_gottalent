allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Force consistent Java and Kotlin versions for all subprojects
    afterEvaluate {
        if (project.hasProperty("android")) {
            extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        
        // Configure Kotlin compilation for consistency
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
            kotlinOptions {
                jvmTarget = "17"
                suppressWarnings = true  // Suppress unchecked warnings
                freeCompilerArgs = listOf(
                    "-Xjvm-default=all",
                    "-Xno-param-assertions"
                )
            }
        }
        
        // Configure Java compilation to suppress warnings
        tasks.withType<JavaCompile> {
            options.compilerArgs.addAll(listOf(
                "-Xlint:-deprecation",
                "-Xlint:-unchecked"
            ))
            options.encoding = "UTF-8"
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
