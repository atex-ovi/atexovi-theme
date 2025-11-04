#!/usr/bin/env bash
# banner.sh — custom banner by Atex Ovi

magenta="\033[1;35m"
green="\033[1;32m"
white="\033[1;37m"
blue="\033[1;34m"
red="\033[1;31m"
black="\033[1;40;30m"
yellow="\033[1;33m"
cyan="\033[1;36m"
reset="\033[0m"
bgyellow="\033[1;43;33m"
bgwhite="\033[1;47;37m"

c0=${reset}; c1=${magenta}; c2=${green}; c3=${white}; c4=${blue}
c5=${red}; c6=${yellow}; c7=${cyan}; c8=${black}; c9=${bgyellow}; c10=${bgwhite}

# System info functions
getCodeName(){ codename="$(getprop ro.product.board)"; }
getClientBase(){ client_base="$(getprop ro.com.google.clientidbase)"; }
getModel(){ model="$(getprop ro.product.brand) $(getprop ro.product.model)"; }
getDistro(){ os="Android $(getprop ro.build.version.release)"; }
getKernel(){ kernel="$(uname -r)"; }
getDeviceStatus() {
    if command -v su >/dev/null 2>&1; then
        if su -c whoami >/dev/null 2>&1; then
            device_status="Rooted"
        else
            device_status="Non-Root"
        fi
    else
        device_status="Non-Root"
    fi
}
getShell(){ shell=$(ps -o comm= -p $$); }
getUptime(){ uptime="$(uptime --pretty | sed 's/up //')"; }
getMemoryUsage(){
    line=$(free --mega | grep Mem:)
    total=$(echo $line | awk '{print $2}')
    used=$(echo $line | awk '{print $3}')
    memory="${used}MB / ${total}MB"
}
getDiskUsage(){
    line=$(df -h /data | tail -1)
    size=$(echo $line | awk '{print $2}')
    used=$(echo $line | awk '{print $3}')
    avail=$(echo $line | awk '{print $4}')
    usep=$(echo $line | awk '{print $5}')
    storage="${used}B / ${size}B = ${avail}B (${usep})"
}

# Gather all info
getCodeName; getClientBase; getModel; getDistro; getKernel
getDeviceStatus
getShell; getUptime; getMemoryUsage; getDiskUsage

# Display banner
cols=$(tput cols)
echo -e "\n"
echo -e "  ┏━━━━━━━━━━━━━━━━━━━━━━┓"
echo -e "  ┃ ${c1}a${c2}t${c7}e${c4}x${c5}-${c6}o${c7}v${c1}i${c0}     ${c5}${c0}  ${c6}${c0}  ${c7}${c0} ┃  ${codename}${c5}@${c0}${client_base}"
echo -e "  ┣━━━━━━━━━━━━━━━━━━━━━━┫"
echo -e "  ┃                      ┃  ${c1}phone${c0}  ${model}"
echo -e "  ┃          ${c3}•${c8}${c3}•${c0}          ┃  ${c2}os${c0}     ${os}"
echo -e "  ┃          ${c8}${c0}${c9}oo${c0}${c8}|${c0}         ┃  ${c7}ker${c0}    ${kernel}"
echo -e "  ┃         ${c8}/${c0}${c10} ${c0}${c8}'\\'${c0}        ┃  ${c4}Device${c0} ${device_status}"
echo -e "  ┃        ${c9}(${c0}${c8}\\_;/${c0}${c9})${c0}        ┃  ${c5}sh${c0}     ${shell}"
echo -e "  ┃                      ┃  ${c6}up${c0}     ${uptime}"
echo -e "  ┃   Powered ${c1}by${c0} Linux   ┃  ${c1}ram${c0}    ${memory}"
echo -e "  ┃                      ┃  ${c2}disk${c0}   ${storage}"
echo -e "  ┗━━━━━━━━━━━━━━━━━━━━━━┛  ${c1}━━━${c2}━━━${c3}━━━${c4}━━━${c5}━━━${c6}━━━${c7}━━━"
echo -e "\n"
