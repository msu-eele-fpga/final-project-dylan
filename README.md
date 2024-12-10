## Table of Contents
- [About](#-about)
- [How to Build](#-how-to-build)
- [Documentation](#-documentation)


## About

The goal of this project was to create a system that can change the RGB color values of an RGB LED by turning their corresponding potentiometers. Additionally, I added on a hardware servo motor that changes its position based on software that checks what color the RGB LED is, sending over a corresponding pwm signal to the servo motor. The servo motor's arm is part of a gauge chart that lists the various RGB color possibilities, as can be seen in the picture below.

![cool_pic](assets/chart_pic.jpg)

## 📝 How to Build

Note: this build section was created with the assumption that the user has followed the course up to the final project.

### Hardware:

The following is a wiring diagram for this project:

![wiring_dg](assets/467_FP_wiring.png)

Check the DE10 Nano User Manual for pin locations.

### Software:

Here's a 

Here's a load-up guide for the software side of this project.

1. Plug in the FPGA's micro AB port on the ethernet side to your PC.
2. Plug in the FPGA's ethernet port to your PC.
3. Load up PUTTY with the your DE10 Nano Saved Session.
4. Plug in the FPGA's power cord.
5. Wait for the autoboot...
6. Log in as soc.
7. Run the following commands to load up the device drivers
```
sudo insmod rgb_controller.ko
sudo insmod servo_controller.ko
sudo insmod de10nano_adc.ko
```
8. Run the following command to run the software's C program
` sudo ./pot_RGB_Servo `
9. The terminal should tell you that you can now move your potentiometers for RGB LED lightup and Servo Movement!


To build the packages, follow these steps:

```shell
# Open a terminal (Command Prompt or PowerShell for Windows, Terminal for macOS or Linux)

# Ensure Git is installed
# Visit https://git-scm.com to download and install console Git if not already installed

# Clone the repository
git clone https://github.com/Abblix/Oidc.Server.git

# Navigate to the project directory
cd Oidc.Server

# Check if .NET SDK is installed
dotnet --version  # Check the installed version of .NET SDK
# Visit the official Microsoft website to install or update it if necessary

# Restore dependencies
dotnet restore

# Compile the project
dotnet build

```
## 📚 Documentation 

### Getting Started
Explore the [Getting Started Guide](https://docs.abblix.com/docs/getting-started-guide).
In this guide, you will create a working solution step by step, building an OpenID Connect Provider using ASP.NET MVC and the Abblix OIDC Server solution.

To better understand the Abblix OIDC Server product, we recommend visiting our [Documentation](https://docs.abblix.com/docs) site. There, you will find useful information about the product and the OpenID Connect standard.

### Abblix OIDC Server Helper

The [**Abblix OIDC Server Helper**](https://chat.openai.com/g/g-1icXaNyOR-abblix-oidc-server-helper) is a specialized ChatGPT [![Abblix OIDC Server Helper](https://resources.abblix.com/imgs/svg/openai-black-15x15.svg)](https://chat.openai.com/g/g-1icXaNyOR-abblix-oidc-server-helper) designed to assist users and developers working with the Abblix OIDC Server. This tool is equipped with comprehensive documentation and various supporting documents, enabling it to provide precise and detailed assistance on a range of topics. Here are the key areas it can help with:

- **Integration**: Guidance on how to integrate the Abblix OIDC Server with your .NET project.
- **Configuration**: Best practices and settings for configuring the server.
- **Technical Support**: Troubleshooting common issues and implementing features.
- **Licensing and Pricing**: Detailed information on different licensing plans and costs.
- **Features and Benefits**: Overview of the server's features and their advantages.
- **Security and Compliance**: Ensuring your implementation is secure and compliant with standards.
- **Extending and Customizing**: Guidelines for extending the functionality of the server.

and much more.

This tool is ideal for both new users and experienced developers seeking specific technical details or support.

## 🤝 Feedback and Contributions

We've made every effort to implement all the main aspects of the OpenID protocol in the best possible way. However, the development journey doesn't end here, and your input is crucial for our continuous improvement.

> [!IMPORTANT]
> Whether you have feedback on features, have encountered any bugs, or have suggestions for enhancements, we're eager to hear from you. Your insights help us make the Abblix OIDC Server library more robust and user-friendly.

Please feel free to contribute by [submitting an issue](https://github.com/Abblix/Oidc.Server/issues) or [joining the discussions](https://github.com/orgs/Abblix/discussions). Each contribution helps us grow and improve.

We appreciate your support and look forward to making our product even better with your help!

## 📃 License

This product is distributed under a proprietary license. You can review the full license agreement at the following link: [Standard License Agreement for Abblix OIDC Server](https://resources.abblix.com/docs/eng/standard-license-agreement-abblix-oidc-server.pdf).

For non-commercial use, this product is available for free.

## 🗨️ Contacts

For more details about our products, services, or any general information regarding the Abblix OIDC Server, feel free to reach out to us. We are here to provide support and answer any questions you may have. Below are the best ways to contact our team:

- **Email**: Send us your inquiries or support requests at [support@abblix.com](mailto:support@abblix.com).
- **Website**: Visit the official Abblix OIDC Server page for more information: [Abblix OIDC Server](https://www.abblix.com/abblix-oidc-server).

Subscribe to our LinkedIn and Twitter:

[![LinkedIn](https://img.shields.io/badge/subscribe-white.svg?logo=data:image/svg%2bxml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTIwLjQ0NyAyMC40NTJoLTMuNTU0di01LjU2OWMwLTEuMzI4LS4wMjctMy4wMzctMS44NTItMy4wMzctMS44NTMgMC0yLjEzNiAxLjQ0NS0yLjEzNiAyLjkzOXY1LjY2N0g5LjM1MVY5aDMuNDE0djEuNTYxaC4wNDZjLjQ3Ny0uOSAxLjYzNy0xLjg1IDMuMzctMS44NSAzLjYwMSAwIDQuMjY3IDIuMzcgNC4yNjcgNS40NTV2Ni4yODZ6TTUuMzM3IDcuNDMzYTIuMDYyIDIuMDYyIDAgMCAxLTIuMDYzLTIuMDY1IDIuMDY0IDIuMDY0IDAgMSAxIDIuMDYzIDIuMDY1em0xLjc4MiAxMy4wMTlIMy41NTVWOWgzLjU2NHYxMS40NTJ6TTIyLjIyNSAwSDEuNzcxQy43OTIgMCAwIC43NzQgMCAxLjcyOXYyMC41NDJDMCAyMy4yMjcuNzkyIDI0IDEuNzcxIDI0aDIwLjQ1MUMyMy4yIDI0IDI0IDIzLjIyNyAyNCAyMi4yNzFWMS43MjlDMjQgLjc3NCAyMy4yIDAgMjIuMjIyIDBoLjAwM3oiIGZpbGw9IiMwQTY2QzIiLz48cGF0aCBzdHlsZT0iZmlsbDojZmZmO3N0cm9rZS13aWR0aDouMDIwOTI0MSIgZD0iTTQuOTE3IDcuMzc3YTIuMDUyIDIuMDUyIDAgMCAxLS4yNC0zLjk0OWMxLjEyNS0uMzg0IDIuMzM5LjI3NCAyLjY1IDEuNDM3LjA2OC4yNS4wNjguNzY3LjAwMSAxLjAxYTIuMDg5IDIuMDg5IDAgMCAxLTEuNjIgMS41MSAyLjMzNCAyLjMzNCAwIDAgMS0uNzktLjAwOHoiLz48cGF0aCBzdHlsZT0iZmlsbDojZmZmO3N0cm9rZS13aWR0aDouMDIwOTI0MSIgZD0iTTQuOTE3IDcuMzc3YTIuMDU2IDIuMDU2IDAgMCAxLTEuNTItMi42NyAyLjA0NyAyLjA0NyAwIDAgMSAzLjQxOS0uNzU2Yy4yNC4yNTQuNDIuNTczLjUxMi45MDguMDY1LjI0LjA2NS43OCAwIDEuMDItLjA1MS4xODYtLjE5Ny41MDQtLjMuNjUyLS4wOS4xMzItLjMxLjM2Mi0uNDQzLjQ2NC0uNDYzLjM1Ny0xLjEuNTAzLTEuNjY4LjM4MlpNMy41NTcgMTQuNzJWOS4wMDhoMy41NTd2MTEuNDI0SDMuNTU3Wk05LjM1MyAxNC43MlY5LjAwOGgzLjQxMXYuNzg1YzAgLjYxNC4wMDUuNzg0LjAyNi43ODMuMDE0IDAgLjA3LS4wNzMuMTI0LS4xNjIuNTI0LS44NjUgMS41MDgtMS40NzggMi42NS0xLjY1LjI3NS0uMDQyIDEtLjA0NyAxLjMzMi0uMDA5Ljc5LjA5IDEuNDUxLjMxNiAxLjk0LjY2NC4yMi4xNTcuNTU3LjQ5My43MTQuNzEzLjQyLjU5Mi42OSAxLjQxMi44MDggMi40NjQuMDc0LjY2My4wODQgMS4yMTUuMDg1IDQuNTc4djMuMjU4aC0zLjUzNnYtMi45ODZjMC0yLjk3LS4wMS0zLjQ3NC0uMDc0LTMuOTA4LS4wOS0uNjA2LS4zMTQtMS4wODItLjYzNC0xLjM0Mi0uMzk1LS4zMjItMS4wMjktLjQzNy0xLjcwMy0uMzA5LS44NTguMTYzLTEuMzU1Ljc1LTEuNTIzIDEuNzk3LS4wNzYuNDcxLS4wODQuODQ1LS4wODQgMy44MzR2Mi45MTRIOS4zNTN6Ii8+PC9zdmc+)](https://www.linkedin.com/company/103540510/)
[![X](https://img.shields.io/badge/subscribe-white.svg?logo=data:image/svg%2bxml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTE4LjkwMSAxLjE1M2gzLjY4bC04LjA0IDkuMTlMMjQgMjIuODQ2aC03LjQwNmwtNS44LTcuNTg0LTYuNjM4IDcuNTg0SC40NzRsOC42LTkuODNMMCAxLjE1NGg3LjU5NGw1LjI0MyA2LjkzMlpNMTcuNjEgMjAuNjQ0aDIuMDM5TDYuNDg2IDMuMjRINC4yOThaIi8+PHBhdGggc3R5bGU9ImZpbGw6I2ZmZjtzdHJva2Utd2lkdGg6LjAyMDkyNDEiIGQ9Ik0xMS4wMzYgMTIuMDI4IDQuMzg3IDMuMzM0bC0uMDYtLjA4SDYuNDhsNi41MTYgOC42MTQgNi41NzUgOC42OTQuMDYuMDhoLTIuMDA2eiIvPjwvc3ZnPg==)](https://twitter.com/OIDCServer)

We look forward to assisting you and ensuring your experience with our products is successful and enjoyable!

[Back to top](#top)
