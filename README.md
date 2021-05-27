# NodeApp
Testing app.

Scripted jenkinsfile pipeline which:
- builds a new image from git repo
- runs cbctl image validate against 'image-baseline' policy
- posts pipeline and cbctl results to slack

config/deployment:
- deployment.yaml for testing app

