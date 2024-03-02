#include "rclcpp/rclcpp.hpp"
#include "mavros_msgs/mavros_msgs/msg"

class ArduPilotController : public rclcpp::Node
{
public:
    ArduPilotController()
    : Node("ardupilot_controller")
    {
        set_mode_pub_ = this->create_publisher<mavros_msgs::msg::SetMode>("/mavros/set_mode", 10);
    }

    void setFlightMode(const std::string& mode)
    {
        auto set_mode_msg = std::make_shared<mavros_msgs::msg::SetMode>();
        set_mode_msg->custom_mode = mode;
        set_mode_pub_->publish(set_mode_msg);
        RCLCPP_INFO(this->get_logger(), "Flight mode set to: %s", mode.c_str());
    }

private:
    rclcpp::Publisher<mavros_msgs::msg::SetMode>::SharedPtr set_mode_pub_;
};

int main(int argc, char *argv[])
{
    rclcpp::init(argc, argv);
    auto node = std::make_shared<ArduPilotController>();

    // Set flight mode to "GUIDED"
    node->setFlightMode("GUIDED");
    rclcpp::spin_some(node);

    // Set flight mode to "AUTO"
    node->setFlightMode("AUTO");
    rclcpp::spin_some(node);

    // Set flight mode to "RTL" (Return to Launch)
    node->setFlightMode("RTL");
    rclcpp::spin_some(node);

    rclcpp::shutdown();

    return 0;
}
