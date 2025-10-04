# Fetch a new image from archlinux
FROM alpine

# install build tools from our stm32g0 microcontroller and openocd to flash our device
RUN apk add --no-cache openocd

# run openocd as soon the contanier start and bind to the same container IP address 
# using its name
ENTRYPOINT [ "openocd", "-f", "board/st_nucleo_g0.cfg", "-c", "bindto open_server" ]