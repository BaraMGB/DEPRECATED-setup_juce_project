# Deprecated - Please use [new-repo](https://github.com/BaraMGB/JuMake) instead.



## JUCE Project Setup Script

This script is designed to automate the creation and setup of new JUCE projects, either GUI applications or plugins. It streamlines the process of preparing the project environment, cloning the JUCE framework, setting up the project structure, and initializing a build system.

## Prerequisites

Before running this script, ensure you have the following installed on your system:
- Bash shell (typically available on Linux and macOS systems)
- Git
- CMake (version 3.22 or higher)
- A C++ compiler compatible with JUCE requirements (GCC, Clang, or MSVC)

## Usage

To use the script, follow these steps:

1. **Download the Script**: Save the script to a directory of your choice. For the purpose of this documentation, we'll refer to the script as `setup_juce_project.sh`.

2. **Make the Script Executable**: You might need to grant execution permissions to the script. You can do this by running the following command in your terminal:
   
```
chmod +x setup_juce_project.sh
```

3. **Run the Script**: Navigate to the directory where the script is saved and execute it by running:
   
```
./setup_juce_project.sh
```

Follow the on-screen prompts to enter your project name and specify the project type (GUI App or Plugin).

4. **Build Process**: The script will automatically initiate the build process. Once completed, your project setup is ready for development.

## Features

- **Interactive Project Configuration**: Prompts for project name and type to customize the setup.
- **Automated Directory Structure Creation**: Sets up the recommended directory structure for a JUCE project.
- **JUCE Cloning**: Automatically clones the JUCE framework from its GitHub repository.
- **CMake Template Customization**: Depending on the project type, the script customizes and copies the relevant CMake template for GUI applications or plugins.
- **Build Initialization**: Prepares and initiates the build process, creating a ready-to-use development environment.

## Additional Notes

- The script is intended for use on systems where Bash is available. It has been tested on Linux and macOS.
- If you encounter any permissions issues when running the script, ensure that you have execution permissions set correctly.
- This script assumes you have an internet connection to clone the JUCE framework from GitHub.
- Ensure that all prerequisites are met to avoid errors during the setup process.

## Contributing

Your contributions are welcome! If you have suggestions for improving this script, please feel free to open an issue or a pull request in the repository where this script is maintained.
