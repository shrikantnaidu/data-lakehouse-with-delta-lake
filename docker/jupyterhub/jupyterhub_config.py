import os

c = get_config()

# Enable debug logs
c.JupyterHub.log_level = 'DEBUG'
c.Spawner.debug = True

# Use DockerSpawner
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'

# Spawn containers from this image
c.DockerSpawner.image = os.environ['DOCKER_JUPYTER_IMAGE']

# Connect containers to this Docker network
c.DockerSpawner.network_name = os.environ['DOCKER_NETWORK_NAME']

# Explicitly set notebook directory
notebook_dir = '/home/jovyan/work'
c.DockerSpawner.notebook_dir = notebook_dir

# Mount user-specific notebooks directory for persistence
# The host path ./data/notebooks is mapped to /srv/notebooks in the hub container
# Spawned containers should mount directly from the host
def notebook_dir_hook(spawner):
    import os
    import subprocess
    
    username = spawner.user.name
    
    # Create user directory on the hub container's mapped volume
    # This corresponds to ./data/notebooks/{username} on the host
    user_dir = f"/srv/notebooks/{username}"
    shared_dir = "/srv/notebooks/shared"
    
    # Create user directory
    if not os.path.exists(user_dir):
        os.makedirs(user_dir, exist_ok=True)
        os.chmod(user_dir, 0o777)
        try:
            subprocess.run(['chown', '1000:100', user_dir], check=False)
        except:
            pass
    
    # Create shared directory
    if not os.path.exists(shared_dir):
        os.makedirs(shared_dir, exist_ok=True)
        os.chmod(shared_dir, 0o777)
        try:
            subprocess.run(['chown', '1000:100', shared_dir], check=False)
        except:
            pass
    
    spawner.log.info(f"Created/verified directories for user: {username}")
    
    # Set volume mounts for this user's spawned container
    # Mount user's personal directory + shared directory
    spawner.volumes = {
        user_dir: {'bind': notebook_dir, 'mode': 'rw'},
        shared_dir: {'bind': '/home/jovyan/shared', 'mode': 'rw'}
    }

c.DockerSpawner.pre_spawn_hook = notebook_dir_hook

# Configure the hub to listen on all interfaces
c.JupyterHub.hub_ip = '0.0.0.0'
c.JupyterHub.port = 8000

# Use native authenticator for proper multi-user support
# Use DummyAuthenticator for testing persistence
c.JupyterHub.authenticator_class = 'jupyterhub.auth.DummyAuthenticator'
c.DummyAuthenticator.password = "test1234"

# Admin users
c.Authenticator.admin_users = {'admin', 'dummy_user'}

# Allow all authenticated users to access the hub
c.Authenticator.allow_all = True

# Allow named servers
c.JupyterHub.allow_named_servers = True

# Additional Docker configurations
c.DockerSpawner.remove = True  # remove containers when they are stopped
c.DockerSpawner.extra_host_config = {
    'network_mode': os.environ['DOCKER_NETWORK_NAME']
}

# Configure container environment
c.DockerSpawner.environment = {
    'JUPYTER_ENABLE_LAB': 'yes',
    'SPARK_HOME': '/usr/local/spark',
    'PYTHONPATH': '/usr/local/spark/python',
    'PYSPARK_PYTHON': '/opt/conda/bin/python'
}

# Container permissions - use jupyter/docker-stacks built-in permission handling
# The entrypoint will:
# 1. Start as root (default for docker-stacks)
# 2. Adjust jovyan UID/GID to match NB_UID/NB_GID
# 3. Chown home directory and CHOWN_EXTRA paths
# 4. Drop privileges and run as jovyan
c.DockerSpawner.use_internal_ip = True

# Environment variables for secure permission handling
c.DockerSpawner.environment.update({
    'NB_UID': '1000',
    'NB_GID': '100',
    'CHOWN_HOME': 'yes',
    'CHOWN_HOME_OPTS': '-R',
    'CHOWN_EXTRA': '/home/jovyan/work,/home/jovyan/shared',
    'CHOWN_EXTRA_OPTS': '-R'
}) 