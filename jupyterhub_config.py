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

# Mount the real user's Docker volume on the host to the notebook user's
# notebook directory in the container
c.DockerSpawner.volumes = {
    '/srv/notebooks': notebook_dir
}

# Configure the hub to listen on all interfaces
c.JupyterHub.hub_ip = '0.0.0.0'
c.JupyterHub.port = 8000

# Use simple password authentication
c.JupyterHub.authenticator_class = 'jupyterhub.auth.DummyAuthenticator'
c.DummyAuthenticator.password = "jupyter"

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

# Set container permissions
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.extra_create_kwargs = {
    'user': 'jovyan'
} 