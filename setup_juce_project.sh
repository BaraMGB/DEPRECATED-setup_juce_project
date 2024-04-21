#!/bin/bash

#  Ask for the project name
read -p "Enter the project name: " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "Please provide a project name."
    exit 1
fi

# Ask for the project type
echo "Do you want to create a GUI App or a Plugin? [GUI/Plugin]"
read PROJECT_TYPE

if [ "$PROJECT_TYPE" != "GUI" ] && [ "$PROJECT_TYPE" != "Plugin" ]; then
    echo "Invalid project type. Please specify 'GUI' or 'Plugin'."
    exit 1
fi

#  Create a Project Folder
echo "Creating project folder..."
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

#  Clone JUCE from GitHub
echo "Cloning JUCE from GitHub..."
git clone https://github.com/juce-framework/JUCE.git

#  Create a Source Directory
echo "Creating source directory..."
mkdir source

#  Copy the CMake Template based on the project type
echo "Copying CMake Template..."
if [ "$PROJECT_TYPE" == "GUI" ]; then
    cp -r JUCE/examples/CMake/GuiApp/* ./source
elif [ "$PROJECT_TYPE" == "Plugin" ]; then
    cp -r JUCE/examples/CMake/AudioPlugin/* ./source
fi

cd source

#  Customize CMakeLists.txt
echo "Customizing CMakeLists.txt..."

if [ "$PROJECT_TYPE" == "GUI" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then  # Prüft, ob das Betriebssystem macOS ist
        SED_COMMAND="sed -i ''"
    else
        SED_COMMAND="sed -i"
    fi

    $SED_COMMAND "s/project(GUI_APP_EXAMPLE VERSION 0.0.1)/project($PROJECT_NAME VERSION 0.0.1)/" CMakeLists.txt
    $SED_COMMAND "s/juce_add_gui_app(GuiAppExample/juce_add_gui_app($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_compile_definitions(GuiAppExample/target_compile_definitions($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_sources(GuiAppExample/target_sources($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/JUCE_APPLICATION_NAME_STRING=\"\$<TARGET_PROPERTY:GuiAppExample/JUCE_APPLICATION_NAME_STRING=\"\$<TARGET_PROPERTY:$PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/JUCE_APPLICATION_VERSION_STRING=\"\$<TARGET_PROPERTY:GuiAppExample/JUCE_APPLICATION_VERSION_STRING=\"\$<TARGET_PROPERTY:$PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_link_libraries(GuiAppExample/target_link_libraries($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/PRODUCT_NAME \"Gui App Example\")/PRODUCT_NAME \"$PROJECT_NAME\")/" CMakeLists.txt
elif [ "$PROJECT_TYPE" == "Plugin" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SED_COMMAND="sed -i ''"
    else
        SED_COMMAND="sed -i"
    fi

    $SED_COMMAND "s/juce_add_plugin(AudioPluginExample/juce_add_plugin($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/project(project(AUDIO_PLUGIN_EXAMPLE VERSION 0.0.1)/project($PROJECT_NAME VERSION 0.0.1)/" CMakeLists.txt
    $SED_COMMAND "s/target_compile_definitions(AudioPluginExample/target_compile_definitions($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_sources(AudioPluginExample/target_sources($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/target_link_libraries(AudioPluginExample/target_link_libraries($PROJECT_NAME/" CMakeLists.txt
    $SED_COMMAND "s/PRODUCT_NAME \"Audio Plugin Example\")/PRODUCT_NAME \"$PROJECT_NAME\")/" CMakeLists.txt
fi

cd ..

#  Create a new CMakeLists.txt in the source subdirectory
echo "Creating new CMakeLists.txt in 'source' subdirectory..."
cat << EOF > CMakeLists.txt
cmake_minimum_required(VERSION 3.22)

project($PROJECT_NAME VERSION 0.01)

add_subdirectory(JUCE)
add_subdirectory(source)
EOF

cat << EOF > build.sh
#  Create a Build Directory
echo "Creating build directory..."
mkdir -p build
cd build
rm CMakeCache.txt
#  Generate the Build System
echo "Generating the build system..."
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo .. 
echo "Building the project..."
cmake --build . 
echo "copy compile Instructiones for neovim to root..."
cp ./compile_commands.json ../
EOF

bash build.sh

echo "JUCE project setup for '$PROJECT_NAME' as a $PROJECT_TYPE complete!"

