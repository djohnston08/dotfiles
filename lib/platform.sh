#!/usr/bin/env bash

#################################
# Platform Detection Library
# Provides utilities for detecting the current OS
# and architecture
#################################

# Detect the operating system
detect_os() {
    local os=""
    case "$(uname -s)" in
        Darwin*)    os="macos" ;;
        Linux*)     os="linux" ;;
        CYGWIN*)    os="cygwin" ;;
        MINGW*)     os="mingw" ;;
        *)          os="unknown" ;;
    esac
    echo "$os"
}

# Detect the Linux distribution if on Linux
detect_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "redhat"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# Get the package manager for the current system
get_package_manager() {
    local os=$(detect_os)
    
    if [[ "$os" == "macos" ]]; then
        echo "brew"
    elif [[ "$os" == "linux" ]]; then
        local distro=$(detect_linux_distro)
        case "$distro" in
            ubuntu|debian)  echo "apt" ;;
            fedora|redhat|centos) echo "yum" ;;
            arch|manjaro)   echo "pacman" ;;
            opensuse)       echo "zypper" ;;
            *)              echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

# Check if running on macOS
is_macos() {
    [[ "$(detect_os)" == "macos" ]]
}

# Check if running on Linux
is_linux() {
    [[ "$(detect_os)" == "linux" ]]
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get architecture
get_arch() {
    case "$(uname -m)" in
        x86_64)     echo "amd64" ;;
        aarch64)    echo "arm64" ;;
        armv7l)     echo "armv7" ;;
        i686)       echo "386" ;;
        *)          echo "unknown" ;;
    esac
}

# Export functions for use in other scripts
export -f detect_os
export -f detect_linux_distro
export -f get_package_manager
export -f is_macos
export -f is_linux
export -f command_exists
export -f get_arch