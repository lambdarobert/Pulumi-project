# Pulumi-project

This is a project for a fully automated Minecraft server using AWS. In this case, fully automated means that all provisioning happens in the cloud using the scripts provided in the repository, and AWS resources. This handles starting the server through a static website, and stopping it when nobody is playing.

# Diagram
![Diagram](https://cdn.discordapp.com/attachments/797578517239562240/1115678980415176734/IMG_2970.jpg)

## Provisioning System
The AWS lambdas used to provision are are:
1. lambda to check the server status
2. lambda to call ec2 to start the server
3. lambda to to handle captcha verification.

The source code for the captcha checker is at `startlambda`, ec2 starter lambda at `ec2setup.py`, and the ec2 status lambda are at `statuslambda.py`.

An API gateway is required to call the respective lambdas. You need to configure the environment variables on the lambdas so that they can call the AWS SDK in the correct way, and with authorization.

S3 bucket:

The website source code can be found at `website`. This is intended to be used with an S3 static website.

Stopping the server automatically:
The script `ec2_runscript.sh` can put into your EC2 instance to run at startup, and will bootstrap the Minecraft server as well as stop it when nobody was playing. It depends on the Python script checkplayers.py, a script that will query the number of players and output it to stdout.

For the instance, this was tested in on a c5d.large instance. It has NVMe storage, which is utilized by `ec2_runscript.sh`. It also uses an EFS mount, so you will have to change the ID accordingly.
