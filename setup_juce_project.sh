#!/bin/bash

echo "------------------------------------------"
echo " JUCE Project Setup Script"
echo "------------------------------------------"
echo ""

# Ask for the project name
read -p "Enter the project name: " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "Please provide a project name."
    exit 1
fi

# Ask for the project type
read -p "Do you want to create a [g]UI App or a [p]lugin? [g/p]: " PROJECT_TYPE_SHORT

# Convert short project type to full project type
if [ "$PROJECT_TYPE_SHORT" == "g" ]; then
    PROJECT_TYPE="GUI"
elif [ "$PROJECT_TYPE_SHORT" == "p" ]; then
    PROJECT_TYPE="Plugin"
else
    echo "Invalid project type. Please specify 'g' for GUI or 'p' for Plugin."
    exit 1
fi


PROJECT_DIR="./Projects"

# Create the project folder
PROJECT_PATH="$PROJECT_DIR/$PROJECT_NAME"
echo "Creating project folder at $PROJECT_PATH..."
mkdir -p "$PROJECT_PATH"

# Clone JUCE from GitHub only if it doesn't exist
if [ ! -d "JUCE" ]; then  
    echo "Cloning JUCE from GitHub..."
    git clone https://github.com/juce-framework/JUCE.git
fi

# Wechsel in den Projektordner, nachdem er erstellt wurde!
cd "$PROJECT_PATH" 

# Create a Source Directory
echo "Creating source directory..."
mkdir source
# Copy the CMake Template based on the project type
echo "Copying CMake Template..."
if [ "$PROJECT_TYPE" == "GUI" ]; then
    cp -r ../../JUCE/examples/CMake/GuiApp/* ./source
elif [ "$PROJECT_TYPE" == "Plugin" ]; then
    cp -r ../../JUCE/examples/CMake/AudioPlugin/* ./source
fi

cd source

# Customize CMakeLists.txt
echo "Customizing CMakeLists.txt..."

if [[ "$OSTYPE" == "darwin"* ]]; then  # Check if the OS is macOS
    SED_COMMAND="sed -i ''"
else
    SED_COMMAND="sed -i"
fi

if [ "$PROJECT_TYPE" == "GUI" ]; then
    $SED_COMMAND "s/project(GUI_APP_EXAMPLE VERSION 0.0.1)/project($PROJECT_NAME VERSION 0.0.1)/" CMakeLists.txt
    $SED_COMMAND "s/juce_add_gui_app(GuiAppExample/juce_add_gui_app($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_compile_definitions(GuiAppExample/target_compile_definitions($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_sources(GuiAppExample/target_sources($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/JUCE_APPLICATION_NAME_STRING=\"\$<TARGET_PROPERTY:GuiAppExample/JUCE_APPLICATION_NAME_STRING=\"\$<TARGET_PROPERTY:$PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/JUCE_APPLICATION_VERSION_STRING=\"\$<TARGET_PROPERTY:GuiAppExample/JUCE_APPLICATION_VERSION_STRING=\"\$<TARGET_PROPERTY:$PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_link_libraries(GuiAppExample/target_link_libraries($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/PRODUCT_NAME \"Gui App Example\")/PRODUCT_NAME \"$PROJECT_NAME\")/" CMakeLists.txt
elif [ "$PROJECT_TYPE" == "Plugin" ]; then
    $SED_COMMAND "s/juce_add_plugin(AudioPluginExample/juce_add_plugin($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/project(AUDIO_PLUGIN_EXAMPLE VERSION 0.0.1)/project($PROJECT_NAME VERSION 0.0.1)/" CMakeLists.txt
    $SED_COMMAND "s/target_compile_definitions(AudioPluginExample/target_compile_definitions($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_sources(AudioPluginExample/target_sources($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_link_libraries(AudioPluginExample/target_link_libraries($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/PRODUCT_NAME \"Audio Plugin Example\")/PRODUCT_NAME \"$PROJECT_NAME\")/" CMakeLists.txt
fi

cd ..

# Create a new CMakeLists.txt in the project root directory
echo "Creating new CMakeLists.txt in project root directory..."
cat << EOF > CMakeLists.txt
cmake_minimum_required(VERSION 3.22)
set(JUCE_ROOT "../../JUCE")
project($PROJECT_NAME VERSION 0.01)

# Create build folder for Juce if not exits

add_subdirectory(\${JUCE_ROOT} ./build)
add_subdirectory(source)
EOF

# create start.sh
if [ "$PROJECT_TYPE" == "GUI" ]; then
    echo "Creating start.sh script for GUI project..."
    cat << SCRIPT_EOF > start.sh
#!/bin/bash

# Read the last build type
BUILD_TYPE=\$(cat .last_build_type)

EXECUTABLE_PATH="./build/source/${PROJECT_NAME}_artefacts/\${BUILD_TYPE}/${PROJECT_NAME}"

if [ -f "\${EXECUTABLE_PATH}" ]; then
    echo "Starting \${BUILD_TYPE} build of ${PROJECT_NAME}..."
    "\${EXECUTABLE_PATH}"
else
    echo "Executable not found at \${EXECUTABLE_PATH}"
    echo "Please make sure you have built the project using ./build.sh"
fi
SCRIPT_EOF
    chmod +x start.sh
fi


# Create the build.sh script
cat << EOF > build.sh
#!/bin/bash

echo "------------------------------------------"
echo " Build Script for $PROJECT_NAME"
echo "------------------------------------------"
echo ""

# Remove the last build type file at the start
rm -f .last_build_type

# Set default build type to Debug
BUILD_TYPE="Debug"

# Function to validate build type
validate_build_type() {
    case \$1 in
        Debug|Release|RelWithDebInfo|MinSizeRel)
            return 0
            ;;
        *)
            echo "Error: Invalid build type '\$1'" >&2
            echo "Valid build types are: Debug, Release, RelWithDebInfo, MinSizeRel" >&2
            return 1
            ;;
    esac
}

# Parse command-line options
while getopts ":t:" opt; do
    case \${opt} in
        t)
            if validate_build_type "\$OPTARG"; then
                BUILD_TYPE=\$OPTARG
            else
                exit 1
            fi
            ;;
        \?)
            echo "Invalid option: -\$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -\$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

echo "Build type set to: \$BUILD_TYPE"
echo ""

# Save the current build type
echo "\$BUILD_TYPE" > .last_build_type

# Create a Build Directory
echo "Creating build directory..."
mkdir -p build
cd build
rm -f CMakeCache.txt

# Generate the Build System
echo "Generating the build system with build type \$BUILD_TYPE..."
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=\$BUILD_TYPE ..

# Build the project
echo "Building the project..."
cmake --build . --config \$BUILD_TYPE

# Copy compile instructions for neovim to root
echo "Copying compile instructions for neovim to root..."
cp compile_commands.json ..

cd ..

echo "------------------------------------------"
echo " Build Completed!"
echo "------------------------------------------"
EOF
# Make the build script executable
chmod +x build.sh

echo "------------------------------------------"
echo " JUCE project setup for '$PROJECT_NAME' as a $PROJECT_TYPE complete!"
echo " To build your project, run: ./build.sh"
if [ "$PROJECT_TYPE" == "GUI" ]; then
    echo " To start your GUI app, run: ./start.sh [BuildType] (e.g., ./start.sh Release)"
fi
echo "------------------------------------------"

