cmake_minimum_required(VERSION 3.8)
project(my_package)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)
find_package(mavros_msgs REQUIRED)

# uncomment the following section in order to fill in
# further dependencies manually.
# find_package(<dependency> REQUIRED)



# Define the executable target
add_executable(hello_node src/my_node.cpp)
add_executable(apm_controller src/apm_controller.cpp)

# Specify dependencies for the target (if any)
ament_target_dependencies(hello_node rclcpp std_msgs)
ament_target_dependencies(apm_controller rclcpp std_msgs mavros_msgs)

# Install the executable target
install(TARGETS
  hello_node
  apm_controller
  DESTINATION lib/${PROJECT_NAME}
)

install (DIRECTORY
  launch
  DESTINATION share/${PROJECT_NAME}
)



if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # comment the line when a copyright and license is added to all source files
  set(ament_cmake_copyright_FOUND TRUE)
  # the following line skips cpplint (only works in a git repo)
  # comment the line when this package is in a git repo and when
  # a copyright and license is added to all source files
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
