#include "rclcpp/rclcpp.hpp"
#include "actuator_control.h"
#include "gpsrtk.h"
#include "play_tune_v2.h"
#include "position_target.h"
#include "radio_status.h"
#include "rc_in.h"
#include "rc_out.h"
// Include other headers as needed...

class ArduPilotController : public rclcpp::Node
{
public:
    ArduPilotController()
    : Node("ardupilot_controller")
    {
        arm_cmd_pub_ = this->create_publisher<ActuatorControl>("/mavros/cmd/arming", 10);
        takeoff_cmd_pub_ = this->create_publisher<PositionTarget>("/mavros/cmd/takeoff", 10);
        land_cmd_pub_ = this->create_publisher<PositionTarget>("/mavros/cmd/land", 10);
    }

    void sendArmCommand(bool arm)
    {
        auto arm_cmd = std::make_shared<ActuatorControl>();
        arm_cmd->value = arm;
        arm_cmd_pub_->publish(*arm_cmd);
        RCLCPP_INFO(this->get_logger(), "Arming command sent: %s", arm ? "true" : "false");
    }

    void sendTakeoffCommand(float altitude)
    {
        auto takeoff_cmd = std::make_shared<PositionTarget>();
        // Populate takeoff command fields as needed...
        takeoff_cmd_pub_->publish(*takeoff_cmd);
        RCLCPP_INFO(this->get_logger(), "Takeoff command sent: altitude=%.2f", altitude);
    }

    void sendLandCommand()
    {
        auto land_cmd = std::make_shared<PositionTarget>();
        // Populate land command fields as needed...
        land_cmd_pub_->publish(*land_cmd);
        RCLCPP_INFO(this->get_logger(), "Land command sent");
    }

private:
    rclcpp::Publisher<ActuatorControl>::SharedPtr arm_cmd_pub_;
    rclcpp::Publisher<PositionTarget>::SharedPtr takeoff_cmd_pub_;
    rclcpp::Publisher<PositionTarget>::SharedPtr land_cmd_pub_;
};

int main(int argc, char *argv[])
{
    rclcpp::init(argc, argv);
    auto node = std::make_shared<ArduPilotController>();

    // Send arm command
    node->sendArmCommand(true);
    rclcpp::spin_some(node);

    // Send takeoff command
    node->sendTakeoffCommand(5.0); // Altitude: 5 meters
    rclcpp::spin_some(node);

    // Send land command
    node->sendLandCommand();
    rclcpp::spin_some(node);

    rclcpp::shutdown();

    return 0;
}
