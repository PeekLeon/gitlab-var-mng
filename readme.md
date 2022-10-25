# Gitlab variables manager

Import, export or clean your CI/CD variables in your gitlab projects or groups on yml format.

# Parameters

You can use a environment varaibles or parameters. Parameters override environment variables.

Options: 

 ```bash
  --api-version=<value>       gitlab api version (default: 4)
  --group-id=<value>          gitlab group id [$GROUP_ID]
  --help                      show help (default: false)
  --push=<value>              push variables from file name [$PUSH]
  --pull=<value>              pull variables to file name [$PULL]
  --project-id=<value>        gitlab project id [$PROJECT_ID]
  --remove-all                Remove all variables
  --token=<value>             gitlab token [$TOKEN]
  --url=<value>               gitlab url (with http:// or https://) [$URL]
```

# Volume

Path `/data` contain the exports.

> If you use the `--remove-all` option, an export is automatically created in this path with the name `export_var_<ID>.yml` or with the `--pull` value.

# How to use

```shell
docker run --env-file gitlab-prod.env -v /<your_volume>/:/data gitlab-var-mng --help
```

push :
```shell
docker run --env-file gitlab-prod.env -v /<your_volume>/:/data gitlab-var-mng --push=my_var.yml
```

pull :
```shell
docker run --env-file gitlab-prod.env -v /<your_volume>/:/data gitlab-var-mng --pull=my_var.yml
```

push and pull :
```shell
docker run --env-file gitlab-prod.env -v /<your_volume>/:/data gitlab-var-mng --pull=my_var.yml --push=my_other_var.yml
```
> In the order : pull, remove-all and push.

Example of env file :

```
URL=http://gitlab.whatever.com
TOKEN=XXXXXXXXXXXXXXXXXX
PROJECT_ID=999
...
```
