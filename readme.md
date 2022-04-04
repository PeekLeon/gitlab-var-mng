# Gitlab variables manager

Import, export or clean your CI/CD variables in your gitlab projects or groups on yml format.

# Parameters

You can use a environment varaibles or parameters. Parameters override environment variables.

Options: 

 ```bash
  --api-version=<value>       gitlab api version (default: 4)
  --group-id=<value>          gitlab group id [$GROUP_ID]
  --help                      show help (default: false)
  --input=<value>             input file name [$INPUT]
  --output=<value>            output file name [$OUTPUT]
  --project-id=<value>        gitlab project id [$PROJECT_ID]
  --remove-all                Remove all variables
  --token=<value>             gitlab token [$TOKEN]
  --url=<value>               gitlab url (with http:// or https://) [$URL]
```

# Volume

Path `/data` contain the exports.

> If you use the `--remove-all` option, an export is automatically created in this path with the name `export_var_<ID>.yml` or with the `--output` value.

# How to use

```shell
docker run --env-file gitlab-prod.env -v /<your_volume>/:/data gitlab-var-mng --help
```

input :
```shell
docker run --env-file gitlab-prod.env -v /<your_volume>/:/data gitlab-var-mng --input=my_var.yml
```

output :
```shell
docker run --env-file gitlab-prod.env -v /<your_volume>/:/data gitlab-var-mng --output=my_var.yml
```

input and output :
```shell
docker run --env-file gitlab-prod.env -v /<your_volume>/:/data gitlab-var-mng --output=my_var.yml --input=my_other_var.yml
```
> In the order : output, remove-all and input.

Example of env file :

```
URL=http://gitlab.whatever.com
TOKEN=XXXXXXXXXXXXXXXXXX
PROJECT_ID=999
...
```
