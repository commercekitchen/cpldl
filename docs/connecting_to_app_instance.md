# Connecting to application container

## Connect to Bastian server

### Preqrequisites
- Obtain a private key from dev team lead and save 
  - ex/ `~/.ssh/bastian-key.pem` - *do not save key in project folder*
- Change key file permissions
  - `chmod 400 /path/to/bastian-key.pem`
- Look up and note bastian instance public IPv4 address in AWS
  - Choose correct bastian instance. There are 4 (Learners and Trainers/Staging and Prod)
- Look up and note app-instance private IPv4
  - Choose correct app instance. There are 4 (Learners and Trainers/Staging and Prod)

### Connect to Bastian
`ssh -i "path/to/bastian-key.pem" ubuntu@<bastian public IPv4 DNS>`

### Connect to app instance
`ssh -i .ssh/app-instance-key.pem ec2-user@<app instance private IPv4 DNS>`

### Connect to container
- List containers with `docker ps`
- Copy container name
- `docker exec -it <container name> [command]`
