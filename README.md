# k8s-routines

Make the following changes every time you build a new image:
- **.drone.yml**: Give a new version number to ``.settings.tags`` in step ``docker``.

  ```yaml
  steps:
  - name: docker
    image: plugins/docker
    settings:
      repo: ensaas/k8s-routines
      username: ensaas
      password:
        from_secret: docker_password
      tags:
        - latest
        - 0.2.6
  ```

- **k8s/deployment.yaml**: Change the tag for the image used accordingly.

  ```yaml
  containers:
    - name: routines
      image: ensaas/k8s-routines:0.2.6
      ports:
        - containerPort: 3000
  ```