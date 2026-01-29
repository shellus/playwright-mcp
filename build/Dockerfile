FROM mcr.microsoft.com/playwright/mcp:latest

USER root

# Install TigerVNC, websockify, Chinese fonts and input method
# Note: noVNC installed from source for clipboard support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # VNC (TigerVNC supports dynamic resolution)
    tigervnc-standalone-server tigervnc-common tigervnc-tools websockify \
    x11-xserver-utils \
    # Window manager (required for Chrome to maximize/resize properly)
    openbox \
    # Chinese locale and fonts
    locales fonts-noto-cjk fonts-noto-cjk-extra fonts-wqy-zenhei fonts-wqy-microhei \
    # Clipboard sync
    autocutsel \
    # Input method
    fcitx fcitx-googlepinyin fcitx-ui-classic dbus-x11 im-config \
    # Auth proxy
    nginx && \
    # Generate Chinese locale
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    # Clean up
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Chrome browser
RUN npm install -g playwright && npx playwright install chrome --with-deps

# Pre-configure fcitx
RUN mkdir -p /root/.config/fcitx && \
    echo '[Profile]' > /root/.config/fcitx/profile && \
    echo 'IMName=googlepinyin' >> /root/.config/fcitx/profile && \
    echo 'EnabledIMList=fcitx-keyboard-us:True,googlepinyin:True,pinyin:False' >> /root/.config/fcitx/profile && \
    echo 'PreeditStringInClientWindow=False' >> /root/.config/fcitx/profile

# Configure fcitx settings
RUN mkdir -p /root/.config/fcitx/conf && \
    echo '[Hotkey]' > /root/.config/fcitx/config && \
    echo 'TriggerKey=CTRL_SPACE' >> /root/.config/fcitx/config && \
    echo 'SwitchKey=Disabled' >> /root/.config/fcitx/config && \
    echo '[Program]' >> /root/.config/fcitx/config && \
    echo 'DelayStart=2' >> /root/.config/fcitx/config && \
    echo 'ShareStateAmongWindow=All' >> /root/.config/fcitx/config

# Copy noVNC v1.6.0 (with auto clipboard support)
COPY novnc-src/ /usr/share/novnc/

# Copy patches
COPY patches/ /patches/

# Configure fontconfig for Chinese fonts (system-wide)
RUN mkdir -p /etc/fonts/conf.d && \
    cp /patches/fonts.conf /etc/fonts/local.conf && \
    fc-cache -fv

COPY entrypoint.sh /entrypoint.sh
COPY nginx/nginx.conf.template /etc/nginx/nginx.conf.template
RUN chmod +x /entrypoint.sh

EXPOSE 8931 6080

ENTRYPOINT ["/entrypoint.sh"]
