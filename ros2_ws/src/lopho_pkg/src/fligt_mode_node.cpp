#include <humble.hpp>
#include <rclcpp/rclcpp.hpp>
#include <mavros_msgs/msg/state.hpp>

class FlightModeNode : public rclcpp::Node
{
public:
  FlightModeNode() : Node("flight_mode_node")
  {
    // Create a subscriber to the 'mavros/state' topic
    state_subscriber_ = this->create_subscription<mavros_msgs::msg::State>(
      "mavros/state", 10,
      [this](const mavros_msgs::msg::State::SharedPtr msg) {
        // Get the current flight mode
        std::string flight_mode = msg->mode;

        // Display the current flight mode
        RCLCPP_INFO(this->get_logger(), "Current flight mode: %s", flight_mode.c_str());
      });
  }

private:
  rclcpp::Subscription<mavros_msgs::msg::State>::SharedPtr state_subscriber_;
};

int main(int argc, char **argv)
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<FlightModeNode>());
  rclcpp::shutdown();
  return 0;
}