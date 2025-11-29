# GIMP Streaming Container
# Multi-stage build for production-ready GIMP with VNC streaming support

# Build stage
FROM ubuntu:22.04 AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    python3-dev \
    python3-pip \
    pkg-config \
    libnss3-dev \
    libatk-bridge2.0-dev \
    libdrm2 \
    libxkbcommon-dev \
    libxcomposite-dev \
    libxdamage-dev \
    libxrandr-dev \
    libgbm-dev \
    libxss-dev \
    libasound2-dev \
    && rm -rf /var/lib/apt/lists/*

# Build webrtc-native from source
RUN git clone https://github.com/webrtc-native/webrtc-native.git /tmp/webrtc-native \
    && cd /tmp/webrtc-native \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && make install

# Production stage
FROM ubuntu:22.04

# Set labels
LABEL maintainer="GIMP Streaming Platform <platform@gimp-streaming.com>"
LABEL description="GIMP with VNC and WebRTC streaming support"
LABEL version="1.0.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV VNC_PASSWORD=vnc_password
ENV NOVNC_PORT=6080
ENV USER=gimp
ENV HOME=/home/gimp
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create user
RUN groupadd -r gimp && useradd -r -g gimp -d $HOME -s /bin/bash gimp \
    && mkdir -p $HOME \
    && chown -R gimp:gimp $HOME

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # GIMP dependencies
    gimp \
    gimp-plugin-registry \
    gimp-data-extras \
    # VNC server
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    # Window manager
    openbox \
    # Audio support
    pulseaudio \
    pulseaudio-utils \
    alsa-utils \
    # Fonts
    fonts-dejavu-core \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    # System utilities
    supervisor \
    curl \
    wget \
    git \
    nano \
    vim-tiny \
    htop \
    # Image processing dependencies
    libpng16-16 \
    libjpeg-turbo8 \
    libtiff5 \
    libwebp7 \
    # Graphics libraries
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    libpango-1.0-0 \
    libcairo2 \
    libglib2.0-0 \
    # Python for automation
    python3 \
    python3-pip \
    python3-gi \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    # Copy/paste support
    autocutsel \
    # File system utilities
    rsync \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    pillow \
    numpy \
    opencv-python \
    requests \
    websockets \
    asyncio

# Copy webrtc-native from builder stage
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
RUN ldconfig

# Install noVNC for web-based VNC access
RUN cd /tmp \
    && wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | tar xz \
    && mv noVNC-1.4.0 /opt/noVNC \
    && cd /opt/noVNC \
    && npm install -g http-server \
    && ln -s vnc.html index.html

# Install websockify for noVNC
RUN cd /tmp \
    && wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v0.12.0.tar.gz | tar xz \
    && mv websockify-0.12.0 /opt/websockify \
    && cd /opt/websockify \
    && python3 setup.py install

# Create directories
RUN mkdir -p $HOME/.vnc \
    && mkdir -p $HOME/.config/gimp \
    && mkdir -p $HOME/Desktop \
    && mkdir -p $HOME/.config/autostart \
    && mkdir -p /opt/gimp-scripts \
    && mkdir -p /var/log/supervisor \
    && chown -R gimp:gimp $HOME

# Copy configuration files
COPY config/vnc/xstartup /home/gimp/.vnc/xstartup
COPY config/vnc/config.d /home/gimp/.vnc/config.d
COPY config/openbox/rc.xml /home/gimp/.config/openbox/rc.xml
COPY config/openbox/autostart /home/gimp/.config/openbox/autostart
COPY config/gimp/gimprc /home/gimp/.config/GIMP/2.10/gimprc
COPY config/pulse/default.pa /home/gimp/.config/pulse/default.pa

# Copy scripts
COPY scripts/ /opt/gimp-scripts/
RUN chmod +x /opt/gimp-scripts/*.sh

# Copy supervisor configuration
COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create VNC password
RUN mkdir -p $HOME/.vnc \
    && echo "$VNC_PASSWORD" | vncpasswd -f > $HOME/.vnc/passwd \
    && chmod 600 $HOME/.vnc/passwd \
    && chown -R gimp:gimp $HOME/.vnc

# Set permissions
RUN chown -R gimp:gimp $HOME \
    && chmod +x $HOME/.vnc/xstartup \
    && chmod +x /opt/gimp-scripts/*.sh

# Create startup script
RUN cat > /opt/gimp-scripts/start-gimp.sh << 'EOF'
#!/bin/bash
set -e

# Initialize pulseaudio
pulseaudio --start --log-target=syslog

# Set up audio
export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native

# Start D-Bus
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

# Wait for X server to be ready
until xdpyinfo -display :1 >/dev/null 2>&1; do
    echo "Waiting for X server..."
    sleep 1
done

# Start window manager
openbox --startup /opt/gimp-scripts/openbox-startup.sh &

# Start GIMP
exec gimp "$@"
EOF

RUN chmod +x /opt/gimp-scripts/start-gimp.sh

# Expose ports
EXPOSE 5901 6080 8080

# Set working directory
WORKDIR $HOME

# Switch to user
USER gimp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${NOVNC_PORT}/healthcheck || exit 1

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]