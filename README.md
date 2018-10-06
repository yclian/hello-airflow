
## First time

Get the HelloAirflow keyset. It was generated this way:

```bash
$ aws ec2 create-key-pair --key-name HelloAirflow --output json
```

## Build/Launch Packer image

```bash
$ packer build packer.json
```

Then, launch it, e.g.

```bash
$ aws ec2 run-instances --count 1 \
  --image-id $(head -1 AMI) \
  --instance-type t3.small \
  --key-name HelloAirflow \
  --subnet-id subnet-48a82d31

$ aws ec2 create-tags \
  --resources i-03a053f71c805467b \
  --tags Key=Name,Value=hello-airflow Key=Creator,Value=yclian
```

