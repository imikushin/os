FROM rancher/os-base
COPY console.sh docker-init update-ssh-keys rancheros-install /usr/sbin/
COPY build/lsb-release /etc/
RUN sed -i 's/rancher:!/rancher:*/g' /etc/shadow && \
    sed -i 's/docker:!/docker:*/g' /etc/shadow && \
    sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 180/g' /etc/ssh/sshd_config && \
    echo '## allow password less for rancher user' >> /etc/sudoers && \
    echo 'rancher ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo '## allow password less for docker user' >> /etc/sudoers && \
    echo 'docker ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    ln -sf /usr/bin/docker.dist /usr/bin/docker && \
    ln -sf /usr/bin/docker-containerd.dist /usr/bin/docker-containerd && \
    ln -sf /usr/bin/docker-containerd-shim.dist /usr/bin/docker-containerd-shim && \
    ln -sf /usr/bin/docker-runc.dist /usr/bin/docker-runc
COPY prompt.sh /etc/profile.d/
CMD ["/usr/sbin/console.sh"]
