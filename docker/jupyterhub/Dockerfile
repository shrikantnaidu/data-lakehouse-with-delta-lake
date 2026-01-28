FROM jupyterhub/jupyterhub:3.1.1

# Install DockerSpawner and NativeAuthenticator
RUN pip install dockerspawner jupyterhub-nativeauthenticator

COPY jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py 