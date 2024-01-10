FROM alpine:latest

# Set up an Alpine Linux machine running an SSH server.
RUN apk add --update --no-cache openssh sudo

COPY sshd_config /etc/ssh

# Autogenerate missing host keys.
RUN ssh-keygen -A

# Create a password-authenticated user for SSH access
ENV PASSWORD_USER=password_user
RUN adduser -D $PASSWORD_USER
RUN echo 'password_user:secret' | chpasswd
RUN mkdir -p /home/$PASSWORD_USER/.ssh && \
    chmod 700 /home/$PASSWORD_USER/.ssh && \
    chown -R $PASSWORD_USER:$PASSWORD_USER /home/$PASSWORD_USER/.ssh

# Create a pubkey-authenticated user for SSH access
ENV PUBKEY_USER=pubkey_user
RUN adduser -D $PUBKEY_USER
RUN echo 'pubkey_user:password' | chpasswd
RUN mkdir -p /home/$PUBKEY_USER/.ssh && \
    chmod 700 /home/$PUBKEY_USER/.ssh && \
    chown -R $PUBKEY_USER:$PUBKEY_USER /home/$PUBKEY_USER/.ssh

# Copy pubkey_user pub key
COPY --chown=pubkey_user:pubkey_user --chmod=600 pubkey_user.pub /home/$PUBKEY_USER/.ssh/authorized_keys

RUN echo hello_password_user > /home/$PASSWORD_USER/world.txt
RUN echo hello_pubkey_user > /home/$PUBKEY_USER/world.txt

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
