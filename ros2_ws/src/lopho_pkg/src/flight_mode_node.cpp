#include "rclcpp/rclcpp.hpp"
#include "mavros_msgs/msg/state.hpp"

class MavrosStateReader : public rclcpp::Node
{
private:
    rclcpp::Subscription<mavros_msgs::msg::State>::SharedPtr subscription_;
public:
    MavrosStateReader() : Node("mavros_state_reader")
    {
        // Subscribe to mavros state topic
        subscription_ = this->create_subscription<mavros_msgs::msg::State>(
            "mavros/state", 10, [this](const mavros_msgs::msg::State::SharedPtr msg) {
                // Callback function to print mavros state
                RCLCPP_INFO(this->get_logger(), "Mavros state: %s", msg->mode.c_str());
            });
    }
};

int main(int argc, char *argv[])
{
    std::cout << "Starting MavrosStateReader node" << std::endl;
    rclcpp::init(argc, argv);
    auto node = std::make_shared<MavrosStateReader>();
    
    // Spin the node to keep it alive and process messages
    rclcpp::spin(node);
    // std::cout << "Starting MavrosStateReader node" << std::endl;
    RCLCPP_INFO(node->get_logger(), "Kill to end");

    rclcpp::shutdown();
    return 0;
}
