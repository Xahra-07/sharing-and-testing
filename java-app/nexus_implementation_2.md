# 📦 Building a Java App & Publishing to Nexus — A Complete Beginner's Guide

> **Who is this for?** A student using **Ubuntu**, **VS Code**, and **Sonatype Nexus** running on **AWS**.
>
> **What will you do?** Build a Java Spring Boot application using Gradle, produce a `.jar` file, and upload (publish) it to your Nexus `maven-snapshots` repository.

---

## Table of Contents

1. [Understanding the Project](#1-understanding-the-project)
2. [Setting Up — Files You Need to Create First](#2-setting-up--files-you-need-to-create-first)
3. [Checking & Installing Gradle](#3-checking--installing-gradle)
4. [Building the Application](#4-building-the-application)
5. [Publishing the JAR to Nexus](#5-publishing-the-jar-to-nexus)
6. [Verifying the Upload in Nexus](#6-verifying-the-upload-in-nexus)

---

## 1. Understanding the Project

Your `java-app` directory is a **Gradle-based Java Spring Boot** project. Here's what the key files do:

| File / Folder | Purpose |
|---|---|
| `build.gradle` | The main build configuration — defines dependencies, plugins, and how to publish to Nexus |
| `settings.gradle` | Tells Gradle the name of this project (`java-app`) |
| `gradle.properties` | Stores your **Nexus credentials** (username & password) — ⚠️ **not tracked by Git** |
| `src/` | Your Java source code lives here |
| `gradlew` / `gradlew.bat` | The **Gradle Wrapper** — a script that downloads and uses the correct version of Gradle for this project |
| `.gitignore` | Lists files/folders that should **not** be pushed to GitHub |
| `Dockerfile` | Used later to containerise the app (not needed for this task) |

### How the Publishing Works

Inside `build.gradle`, there is a `publishing` block that tells Gradle:
- **What** to publish → the JAR file at `build/libs/java-app-1.0-SNAPSHOT.jar`
- **Where** to publish → your Nexus `maven-snapshots` repository URL
- **With what credentials** → read from `gradle.properties` (`repoUser` and `repoPassword`)

---

## 2. Setting Up — Files You Need to Create First

### Why This Step Matters

Look at the `.gitignore` file in the project:

```
.DS_Store
.idea/*
.gradle
build
out
gradle.properties
```

Notice that **`gradle.properties`** is listed here. This means it is **intentionally excluded from Git** — because it contains sensitive credentials (your Nexus username and password). When you clone this repo from GitHub, **this file will not exist**. You must create it yourself.

> [!CAUTION]
> **Never commit credentials to Git.** The `gradle.properties` file is in `.gitignore` for a reason. If you accidentally push it, your Nexus password will be exposed to anyone with access to the repository.

### Step 2.1 — Open Your Terminal in VS Code

1. Open VS Code
2. Open the `java-app` folder (File → Open Folder → select `java-app`)
3. Open the integrated terminal: press **Ctrl + `** (backtick) or go to **Terminal → New Terminal**

### Step 2.2 — Navigate to the Project Directory

If your terminal is not already inside the `java-app` folder:

```bash
cd ~/path/to/java-app
```

> **What this does:** Changes your current directory to the project root. All subsequent commands assume you are inside `java-app`.

### Step 2.3 — Create the `gradle.properties` File

In VS Code, right-click in the **Explorer** panel (the file tree on the left) inside the `java-app` folder and select **"New File..."**. Name it:

```
gradle.properties
```

Alternatively, you can create it from the terminal:

```bash
code gradle.properties
```

> **What this does:** Opens (or creates) a file called `gradle.properties` in VS Code for editing.

Now type the following into the file:

```properties
repoUser = <your-nexus-username>
repoPassword = <your-nexus-password>
```

> [!IMPORTANT]
> Replace `<your-nexus-username>` and `<your-nexus-password>` with the **actual credentials** for a user that has permission to upload to the `maven-snapshots` repository on your Nexus server. For example:
> ```properties
> repoUser = developer1
> repoPassword = dev@2026
> ```

**Save the file:**
- Press **Ctrl + S** to save in VS Code

### Step 2.4 — Verify the File Was Created

```bash
cat gradle.properties
```

> **What this does:** Prints the contents of `gradle.properties` to the terminal so you can double-check it looks correct.

You should see your username and password printed out.

### Step 2.5 — Verify the Nexus URL in `build.gradle`

Open `build.gradle` and check the `url` inside the `publishing > repositories > maven` block:

```bash
cat build.gradle
```

Look for this section:

```groovy
repositories {
    maven {
        name = 'nexus'
        url = 'http://<YOUR-NEXUS-IP>:8081/repository/maven-snapshots/'
        allowInsecureProtocol = true
        credentials {
            username project.repoUser
            password project.repoPassword
        }
    }
}
```

> [!IMPORTANT]
> Make sure the **IP address** in the `url` matches the **public IP of your Nexus server on AWS**. AWS EC2 instances can change their public IP when restarted, so always verify this. If it has changed, update the URL:
> Open `build.gradle` in VS Code (click it in the Explorer panel), change the IP address to your current Nexus server IP, and press **Ctrl + S** to save.

---

## 3. Checking & Installing Gradle

### Why This Step Matters

Gradle is the **build tool** that compiles your Java code, runs tests, packages it into a JAR file, and publishes it to Nexus. Without it, none of the build commands will work.

> [!TIP]
> This project includes the **Gradle Wrapper** (`gradlew`), which is a script that automatically downloads the correct Gradle version. You can use `./gradlew` instead of `gradle` and it will work even without Gradle installed globally. However, it's good practice to have Gradle installed on your system too.

### Step 3.1 — Check if Gradle is Already Installed

```bash
gradle --version
```

> **What this does:** Asks the system to print the installed version of Gradle. If Gradle is installed, you'll see version information. If not, you'll see an error like `command not found`.

**If you see version information** → Skip to [Section 4](#4-building-the-application). ✅

**If you see `command not found`** → Continue to Step 3.2. ❌

### Step 3.2 — Install Gradle (if not installed)

First, update your package list:

```bash
sudo apt update
```

> **What this does:** Refreshes the list of available packages from Ubuntu's repositories. This ensures you install the latest available version. `sudo` runs the command with administrator (root) privileges, which is required for installing software.

Then install Gradle:

```bash
sudo apt install -y gradle
```

> **What this does:** Installs Gradle from Ubuntu's package manager. The `-y` flag automatically answers "yes" to any confirmation prompts, so the installation proceeds without pausing.

### Step 3.3 — Verify the Installation

```bash
gradle --version
```

You should now see output showing the Gradle version, Groovy version, JVM version, etc.

> [!NOTE]
> If you need a newer version of Gradle than what Ubuntu provides, you can use [SDKMAN](https://sdkman.io/) to install a specific version:
> ```bash
> curl -s "https://get.sdkman.io" | bash
> source "$HOME/.sdkman/bin/sdkman-init.sh"
> sdk install gradle 8.5
> ```

### Step 3.4 — Check that Java is Installed

Gradle needs Java to compile your code. Verify it:

```bash
java -version
```

> **What this does:** Shows the installed Java version. This project requires **Java 17** (set in `build.gradle` as `sourceCompatibility = 17`).

If Java is not installed or is the wrong version:

```bash
sudo apt install -y openjdk-17-jdk
```

> **What this does:** Installs the Java 17 Development Kit, which includes both the compiler (`javac`) and the runtime (`java`).

---

## 4. Building the Application

### Why This Step Matters

Building the application **compiles** your Java source code into bytecode and **packages** it into a `.jar` (Java Archive) file. This JAR file is what gets uploaded to Nexus — it's the deployable artefact.

### Step 4.1 — Make the Gradle Wrapper Executable

```bash
chmod +x gradlew
```

> **What this does:** On Linux, scripts need "execute permission" to run. This command grants that permission to the `gradlew` script. Without this, you'll get a "Permission denied" error. You only need to do this once.

### Step 4.2 — Build the Project

```bash
./gradlew build
```

> **What this does:** This is the main build command. It does several things in order:
> 1. **Downloads dependencies** — pulls Spring Boot and other libraries defined in `build.gradle` from Maven Central
> 2. **Compiles** your Java source code in `src/`
> 3. **Runs tests** — executes any unit tests in the project
> 4. **Packages** everything into a JAR file
>
> The `./` prefix means "run the script in the current directory". We use `gradlew` (the wrapper) instead of `gradle` to ensure we use the exact Gradle version this project was designed for.

### Step 4.3 — Verify the JAR Was Created

```bash
ls -la build/libs/
```

> **What this does:** Lists all files in the `build/libs/` directory with detailed information (file size, date, permissions).

You should see a file named:

```
java-app-1.0-SNAPSHOT.jar
```

> [!TIP]
> The filename comes from `build.gradle`:
> - `java-app` → from `rootProject.name` in `settings.gradle`
> - `1.0-SNAPSHOT` → from `version '1.0-SNAPSHOT'` in `build.gradle`
>
> The `-SNAPSHOT` suffix is a Maven/Gradle convention meaning "this is a development version, not a final release". That's why it goes to the `maven-snapshots` repository, not `maven-releases`.

🎉 **Congratulations!** Your application is built and the JAR file is ready.

---

## 5. Publishing the JAR to Nexus

### Why This Step Matters

Nexus is a **repository manager** — think of it like a private warehouse for your artefacts. By publishing your JAR to Nexus, other team members, CI/CD pipelines, or deployment tools can pull and use your application from a central, reliable location instead of passing files around manually.

### Step 5.1 — Publish to Nexus

```bash
./gradlew publish
```

> **What this does:** This command uses the `maven-publish` plugin (configured in `build.gradle`) to:
> 1. Take the JAR file from `build/libs/java-app-1.0-SNAPSHOT.jar`
> 2. Connect to your Nexus server at the URL specified in `build.gradle`
> 3. Authenticate using the credentials from `gradle.properties`
> 4. Upload the JAR to the `maven-snapshots` repository
>
> If everything is configured correctly, you'll see a `BUILD SUCCESSFUL` message.

### Troubleshooting Common Errors

| Error | Cause | Fix |
|---|---|---|
| `Could not resolve host` | Nexus server IP is wrong or server is down | Check the IP in `build.gradle` and verify your EC2 instance is running |
| `401 Unauthorized` | Wrong username or password | Check `gradle.properties` — ensure the credentials match a valid Nexus user |
| `403 Forbidden` | User doesn't have upload permission | Log into Nexus UI as admin and give the user the `nx-repository-view-maven2-maven-snapshots-*` privilege |
| `Connection refused` | Nexus is not running or port 8081 is blocked | SSH into your AWS instance and run `sudo systemctl status nexus`. Also check your EC2 Security Group allows inbound traffic on port 8081 |
| `Could not find build/libs/java-app-1.0-SNAPSHOT.jar` | You haven't built yet | Run `./gradlew build` first (Section 4) |

> [!NOTE]
> You can combine both steps into a single command:
> ```bash
> ./gradlew build publish
> ```
> This builds the JAR first, then immediately publishes it to Nexus.

---

## 6. Verifying the Upload in Nexus

### Why This Step Matters

You should always verify that your artefact actually made it to Nexus. Don't just trust the terminal output — check with your own eyes!

### Step 6.1 — Open the Nexus Web UI

In your browser, navigate to:

```
http://<YOUR-NEXUS-IP>:8081
```

> Replace `<YOUR-NEXUS-IP>` with the public IP of your AWS EC2 instance (the same one in your `build.gradle` URL).

### Step 6.2 — Log In

Click **"Sign In"** (top-right corner) and enter your Nexus admin credentials.

> [!NOTE]
> The **admin** credentials are different from the developer credentials in `gradle.properties`. The default admin password for a fresh Nexus install is stored in:
> ```
> /opt/sonatype-work/nexus3/admin.password
> ```
> on the AWS server. After the first login, Nexus asks you to set a new password.

### Step 6.3 — Browse the Repository

1. Click the **gear icon ⚙️** (Server Administration) in the top navigation bar
2. In the left sidebar, click **"Repositories"** under **Repository**
3. Find and click on **`maven-snapshots`**
4. Click the **"URL"** link to browse the repository contents

**OR** use the simpler method:

1. Click the **cube icon 📦** ("Browse") in the top navigation bar
2. Select **`maven-snapshots`** from the list
3. Navigate through the folder structure: **`com` → `example` → `java-app` → `1.0-SNAPSHOT`**

### Step 6.4 — Confirm Your Artefact

You should see your uploaded file:

```
java-app-1.0-SNAPSHOT.jar
```

Along with metadata files like `.pom` and `.md5`/`.sha1` checksums that Gradle generated automatically.

✅ **If you can see the JAR file here — you're done! You've successfully built your Java application and published it to your Nexus repository.**

---

## 📋 Quick Reference — All Commands in Order

```bash
# 1. Navigate to your project
cd ~/path/to/java-app

# 2. Create the credentials file (not in Git!)
code gradle.properties
# Add:  repoUser = <your-username>
#       repoPassword = <your-password>

# 3. Check/install Gradle
gradle --version
sudo apt update && sudo apt install -y gradle    # only if not installed

# 4. Check Java is installed
java -version
sudo apt install -y openjdk-17-jdk               # only if not installed

# 5. Make wrapper executable
chmod +x gradlew

# 6. Build the project
./gradlew build

# 7. Verify the JAR exists
ls -la build/libs/

# 8. Publish to Nexus
./gradlew publish

# 9. Open Nexus in browser to verify
# http://<YOUR-NEXUS-IP>:8081 → Browse → maven-snapshots
```

---

## 🔑 Key Concepts Recap

| Term | Meaning |
|---|---|
| **Gradle** | A build automation tool for Java (like `npm` for JavaScript). It compiles, tests, and packages your code |
| **Gradle Wrapper (`gradlew`)** | A script bundled with the project that downloads and uses the exact Gradle version the project needs |
| **JAR file** | A Java Archive — a packaged, runnable version of your Java application |
| **SNAPSHOT** | A version suffix meaning "this is a work-in-progress, not a final release" |
| **Nexus** | A repository manager — a server that stores and serves build artefacts (JARs, WARs, Docker images, etc.) |
| **`maven-snapshots`** | A Nexus repository specifically for SNAPSHOT (development) versions |
| **`gradle.properties`** | A file where Gradle reads project-level variables — used here to store Nexus credentials securely (outside of Git) |
| **`maven-publish` plugin** | A Gradle plugin that adds the ability to publish artefacts to Maven-compatible repositories like Nexus |
