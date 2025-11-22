allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
   project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}